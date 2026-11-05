import 'package:flutter/widgets.dart';

class AdvancedSwitch extends StatefulWidget {
  const AdvancedSwitch({
    Key? key,
    this.controller,
    this.activeColor = const Color(0xFF4CAF50),
    this.inactiveColor = const Color(0xFF9E9E9E),
    this.activeChild,
    this.inactiveChild,
    this.activeImage,
    this.inactiveImage,
    this.decoration = const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(15)),
    ),
    this.width = 50.0,
    this.height = 30.0,
    this.enabled = true,
    this.disabledOpacity = 0.5,
    this.thumb,
    this.thumbPadding = 1.0,
    this.initialValue = false,
    this.onChanged,
  }) : super(key: key);

  /// Whether the switch is enabled.
  ///
  /// If false, the switch will be displayed with reduced opacity and will not
  /// respond to user interactions.
  ///
  /// Defaults to true.
  final bool enabled;

  /// Controls the state of the switch.
  ///
  /// If provided, the switch will use this controller to manage its state.
  /// When the controller's value changes, the switch will animate to the new state.
  ///
  /// If null, the switch will manage its own internal state using [initialValue].
  final ValueNotifier<bool>? controller;

  /// The background color when the switch is in the active (on) state.
  ///
  /// Defaults to green (0xFF4CAF50).
  final Color activeColor;

  /// The background color when the switch is in the inactive (off) state.
  ///
  /// Defaults to grey (0xFF9E9E9E).
  final Color inactiveColor;

  /// A widget to display on the left side when the switch is active.
  ///
  /// Typically a Text or Icon widget. This child is visible when the switch
  /// is in the on state and slides with the thumb.
  final Widget? activeChild;

  /// A widget to display on the right side when the switch is inactive.
  ///
  /// Typically a Text or Icon widget. This child is visible when the switch
  /// is in the off state and slides with the thumb.
  final Widget? inactiveChild;

  /// An optional background image to display when the switch is active.
  ///
  /// If provided, this image will be displayed behind the switch content
  /// when in the on state.
  final ImageProvider? activeImage;

  /// An optional background image to display when the switch is inactive.
  ///
  /// If provided, this image will be displayed behind the switch content
  /// when in the off state.
  final ImageProvider? inactiveImage;

  /// The decoration to apply to the switch container.
  ///
  /// Typically used to set the border radius and shape of the switch.
  /// The color from this decoration will be overridden by [activeColor]
  /// and [inactiveColor].
  ///
  /// Defaults to a rounded rectangle with 15px radius.
  final BoxDecoration decoration;

  /// The width of the switch.
  ///
  /// Defaults to 50.0.
  final double width;

  /// The height of the switch.
  ///
  /// The thumb size is automatically calculated based on this value.
  ///
  /// Defaults to 30.0.
  final double height;

  /// The opacity to apply when the switch is disabled.
  ///
  /// Only applied when [enabled] is false.
  ///
  /// Defaults to 0.5.
  final double disabledOpacity;

  /// A custom widget to use as the thumb (the sliding part of the switch).
  ///
  /// If null, a default white rounded rectangle with a shadow will be used.
  final Widget? thumb;

  /// The padding around the thumb.
  ///
  /// This creates space between the thumb and the switch edges.
  /// The thumb's border radius is automatically adjusted based on this value.
  ///
  /// Defaults to 1.0.
  final double thumbPadding;

  /// The initial state of the switch when [controller] is not provided.
  ///
  /// This value is only used when [controller] is null. If a controller is
  /// provided, its value will be used instead.
  ///
  /// Defaults to false (off state).
  final bool initialValue;

  /// Called when the user toggles the switch.
  ///
  /// The switch will call this callback with the new value when the user
  /// taps on it. If null and no [controller] is provided, the switch will
  /// be disabled.
  final ValueChanged? onChanged;

  @override
  _AdvancedSwitchState createState() => _AdvancedSwitchState();
}

class _AdvancedSwitchState extends State<AdvancedSwitch>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 250);
  /// Internal notifier, only created (and owned) when [AdvancedSwitch.controller] is null.
  ValueNotifier<bool>? _controller;
  late AnimationController _animationController;
  late CurvedAnimation _curvedAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Color?> _colorAnimation;
  late double _thumbSize;

  @override
  void initState() {
    super.initState();

    if (widget.controller == null) {
      _controller = ValueNotifier<bool>(widget.initialValue);
    }
    _animationController = AnimationController(
      vsync: this,
      duration: _duration,
      value: _valueController.value ? 1.0 : 0.0,
    );
    _curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _valueController.addListener(_handleControllerValueChanged);

    _initAnimation();
  }

  @override
  void didUpdateWidget(covariant AdvancedSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _controller!)
          .removeListener(_handleControllerValueChanged);
      if (widget.controller == null) {
        // Continue from the parent's last value, as TextField does.
        _controller = ValueNotifier<bool>(oldWidget.controller!.value);
      } else {
        _controller?.dispose();
        _controller = null;
      }
      _valueController.addListener(_handleControllerValueChanged);
      _animationController.value = _valueController.value ? 1.0 : 0.0;
    }

    _initAnimation();
  }

  @override
  void dispose() {
    _valueController.removeListener(_handleControllerValueChanged);
    _controller?.dispose();
    _curvedAnimation.dispose();
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labelSize = widget.width - _thumbSize;
    final containerSize = (labelSize * 2) + _thumbSize;
    final effectiveThumbPadding = EdgeInsets.all(widget.thumbPadding);

    return MouseRegion(
      cursor:
          _isEnabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      child: GestureDetector(
        onTap: _handlePressed,
        child: Opacity(
          opacity: _isEnabled ? 1 : widget.disabledOpacity,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (_, child) {
              return Container(
                clipBehavior: Clip.antiAlias,
                decoration: widget.decoration.copyWith(
                  color: _colorAnimation.value,
                ),
                width: widget.width,
                height: widget.height,
                child: child,
              );
            },
            child: Stack(
              children: [
                if (widget.activeImage != null || widget.inactiveImage != null)
                  ValueListenableBuilder<bool>(
                    valueListenable: _valueController,
                    builder: (_, value, ___) {
                      return AnimatedCrossFade(
                        crossFadeState: value
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: _duration,
                        firstChild: Image(
                          width: widget.width,
                          height: widget.height,
                          image: widget.inactiveImage ?? widget.activeImage!,
                          fit: BoxFit.cover,
                        ),
                        secondChild: Image(
                          width: widget.width,
                          height: widget.height,
                          image: widget.activeImage ?? widget.inactiveImage!,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: _slideAnimation.value,
                      child: child,
                    );
                  },
                  child: OverflowBox(
                    minWidth: containerSize,
                    maxWidth: containerSize,
                    minHeight: widget.height,
                    maxHeight: widget.height,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconTheme(
                          data: const IconThemeData(
                            color: Color(0xFFFFFFFF),
                            size: 20,
                          ),
                          child: DefaultTextStyle(
                            style: const TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                            child: Container(
                              width: labelSize,
                              height: widget.height,
                              alignment: Alignment.center,
                              child: widget.activeChild,
                            ),
                          ),
                        ),
                        Container(
                          margin: effectiveThumbPadding,
                          width: _thumbSize - effectiveThumbPadding.horizontal,
                          height: _thumbSize - effectiveThumbPadding.vertical,
                          child: widget.thumb ??
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFFFF),
                                  borderRadius: widget.decoration.borderRadius
                                      ?.subtract(BorderRadius.all(
                                    Radius.circular(widget.thumbPadding),
                                  )),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x42000000),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                        ),
                        IconTheme(
                          data: const IconThemeData(
                            color: Color(0xFFFFFFFF),
                            size: 20,
                          ),
                          child: DefaultTextStyle(
                            style: const TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                            child: Container(
                              width: labelSize,
                              height: widget.height,
                              alignment: Alignment.center,
                              child: widget.inactiveChild,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ValueNotifier<bool> get _valueController => widget.controller ?? _controller!;

  bool get _isEnabled =>
      widget.enabled && (widget.controller != null || widget.onChanged != null);

  void _initAnimation() {
    _thumbSize = widget.height;
    final offset = widget.width / 2 - _thumbSize / 2;

    _slideAnimation = Tween<Offset>(
      begin: Offset(-offset, 0),
      end: Offset(offset, 0),
    ).animate(_curvedAnimation);

    _colorAnimation = ColorTween(
      begin: widget.inactiveColor,
      end: widget.activeColor,
    ).animate(_curvedAnimation);
  }

  void _handleControllerValueChanged() {
    final nextValue = _valueController.value;
    widget.onChanged?.call(nextValue);

    if (nextValue) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _handlePressed() {
    if (!_isEnabled) {
      return;
    }

    _valueController.value = !_valueController.value;
  }
}
