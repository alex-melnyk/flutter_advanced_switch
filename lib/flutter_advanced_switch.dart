import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

class AdvancedSwitch extends StatefulWidget {
  const AdvancedSwitch({
    Key key,
    @required this.value,
    this.activeColor = Colors.green,
    this.inactiveColor = Colors.grey,
    this.activeChild,
    this.inactiveChild,
    this.activeImage,
    this.inactiveImage,
    this.borderRadius = const BorderRadius.all(const Radius.circular(15)),
    this.width = 50.0,
    this.height = 30.0,
    this.onChanged,
  })  : assert(value != null),
        super(key: key);

  /// Determines current state.
  final bool value;

  /// Determines background color for the active state.
  final Color activeColor;

  /// Determines background color for the inactive state.
  final Color inactiveColor;

  /// Determines label for the active state.
  final Widget activeChild;

  /// Determines label for the inactive state.
  final Widget inactiveChild;

  /// Determines background image for the active state.
  final ImageProvider activeImage;

  /// Determines background image for the inactive state.
  final ImageProvider inactiveImage;

  /// Determines border radius.
  final BorderRadius borderRadius;

  /// Determines width.
  final double width;

  /// Determines height.
  final double height;

  /// Called on interaction.
  final ValueChanged<bool> onChanged;

  @override
  _AdvancedSwitchState createState() => _AdvancedSwitchState();
}

class _AdvancedSwitchState extends State<AdvancedSwitch>
    with SingleTickerProviderStateMixin {
  final _duration = Duration(milliseconds: 250);
  AnimationController _animationController;
  Animation<Offset> _slideAnimation;
  Animation<Color> _colorAnimation;
  double _thumbSize;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: _duration,
      value: widget.value ? 1.0 : 0.0,
    );

    _initAnimation();

    super.initState();
  }

  void _initAnimation() {
    _thumbSize = widget.height;
    final offset = widget.width / 2 - _thumbSize / 2;

    final animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(-offset, 0),
      end: Offset(offset, 0),
    ).animate(animation);

    _colorAnimation = ColorTween(
      begin: widget.inactiveColor,
      end: widget.activeColor,
    ).animate(animation);
  }

  @override
  void didUpdateWidget(AdvancedSwitch oldWidget) {
    if (oldWidget.value == widget.value) {
      return super.didUpdateWidget(oldWidget);
    }

    if (widget.value) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onChanged != null
          ? () => widget.onChanged(!widget.value)
          : null,
      child: Opacity(
        opacity: widget.onChanged != null ? 1.0 : 0.5,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (_, child) {
            return Container(
              width: widget.width,
              height: widget.height,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius,
                color: _colorAnimation.value,
              ),
              child: child,
            );
          },
          child: Stack(
            children: [
              if (widget.activeImage != null || widget.inactiveImage != null)
                _buildBackgroundImage(),
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: _slideAnimation.value,
                    child: child,
                  );
                },
                child: _buildSlider(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlider() {
    final labelSize = widget.width - _thumbSize;
    final containerSize = labelSize * 2 + _thumbSize;

    return OverflowBox(
      minWidth: containerSize,
      maxWidth: containerSize,
      minHeight: widget.height,
      maxHeight: widget.height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLabel(widget.activeChild, labelSize),
          _buildThumb(),
          _buildLabel(widget.inactiveChild, labelSize),
        ],
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return AnimatedCrossFade(
      crossFadeState:
          widget.value ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: _duration,
      firstChild: Image(
        width: widget.width,
        height: widget.height,
        image: widget.inactiveImage ?? widget.activeImage,
        fit: BoxFit.cover,
      ),
      secondChild: Image(
        width: widget.width,
        height: widget.height,
        image: widget.activeImage ?? widget.inactiveImage,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildLabel(Widget child, double labelSize) {
    return IconTheme(
      data: IconThemeData(
        color: Colors.white,
        size: 20,
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        child: Container(
          width: labelSize,
          height: widget.height,
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }

  Widget _buildThumb() {
    return Container(
      margin: EdgeInsets.all(2),
      width: _thumbSize - 4,
      height: _thumbSize - 4,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: widget.borderRadius.subtract(BorderRadius.circular(1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }
}
