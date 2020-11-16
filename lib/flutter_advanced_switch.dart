import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

class AdvancedSwitch extends StatefulWidget {
  const AdvancedSwitch({
    Key key,
    @required this.value,
    this.activeColor = Colors.green,
    this.inactiveColor = Colors.grey,
    this.activeLabel,
    this.inactiveLabel,
    this.activeTextStyle,
    this.inactiveTextStyle,
    this.activeImage,
    this.inactiveImage,
    this.borderRadius = const BorderRadius.all(const Radius.circular(14)),
    this.width = 56.0,
    this.height = 28.0,
    this.onChanged,
  })  : assert(value != null),
        super(key: key);

  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Color inactiveColor;
  final String activeLabel;
  final String inactiveLabel;
  final TextStyle activeTextStyle;
  final TextStyle inactiveTextStyle;
  final ImageProvider activeImage;
  final ImageProvider inactiveImage;
  final BorderRadius borderRadius;
  final double width;
  final double height;

  @override
  _AdvancedSwitchState createState() => _AdvancedSwitchState();
}

class _AdvancedSwitchState extends State<AdvancedSwitch> with SingleTickerProviderStateMixin {
  final _duration = Duration(milliseconds: 250);
  AnimationController _animationController;
  Animation<Color> _colorAnimation;
  Animation<Offset> _positionAnimation;

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this,
        duration: _duration,
        value: widget.value ? 1.0 : 0.0,
        animationBehavior: AnimationBehavior.preserve);

    _initAnimation();

    super.initState();
  }

  void _initAnimation() {
    _positionAnimation = Tween<Offset>(
      begin: Offset(-(widget.width / 2) + (widget.height / 2), 0),
      end: Offset((widget.width / 2) - (widget.height / 2), 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: widget.inactiveColor,
      end: widget.activeColor,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(AdvancedSwitch oldWidget) {
    if (oldWidget.value == widget.value) {
      return;
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
    final checked = widget.value;

    final switchSize = widget.height;
    final labelSize = widget.width - switchSize;
    final contentSize = labelSize * 2 + switchSize;

    return GestureDetector(
      onTap: widget.onChanged != null ? () => widget.onChanged(!checked) : null,
      child: Opacity(
        opacity: widget.onChanged != null ? 1 : 0.5,
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
              if (widget.activeImage != null || widget.inactiveImage != null) _buildBackgroundImage(),
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: _positionAnimation.value,
                    child: child,
                  );
                },
                child: OverflowBox(
                  minWidth: contentSize,
                  maxWidth: contentSize,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLabel(
                        widget.activeLabel,
                        labelSize,
                      ),
                      _buildThumb(switchSize),
                      _buildLabel(
                        widget.inactiveLabel,
                        labelSize,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return AnimatedCrossFade(
      crossFadeState: widget.value ? CrossFadeState.showSecond : CrossFadeState.showFirst,
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

  Widget _buildLabel(
    String value,
    double labelSize, {
    TextStyle textStyle,
  }) {
    return Container(
      width: labelSize,
      height: widget.height,
      alignment: Alignment.center,
      child: Text(
        value ?? '',
        textAlign: TextAlign.center,
        overflow: TextOverflow.clip,
        maxLines: 1,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ).merge(textStyle),
      ),
    );
  }

  Widget _buildThumb(double switchSize) {
    final size = Size(
      switchSize - 2,
      switchSize - 2,
    );

    return Container(
      margin: EdgeInsets.all(1),
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: widget.borderRadius.subtract(BorderRadius.circular(1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
          )
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
