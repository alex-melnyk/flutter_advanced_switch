import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

class AdvancedSwitch extends StatefulWidget {
  const AdvancedSwitch({
    Key key,
    @required this.value,
    @required this.onChanged,
    this.activeColor = Colors.green,
    this.inactiveColor = Colors.grey,
    this.activeLabel,
    this.inactiveLabel,
    this.activeTextStyle,
    this.inactiveTextStyle,
    this.borderRadius = const BorderRadius.all(const Radius.circular(14)),
    this.width = 56.0,
    this.height = 28.0,
  })  : assert(value != null),
        assert(onChanged != null),
        super(key: key);

  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Color inactiveColor;
  final String activeLabel;
  final String inactiveLabel;
  final TextStyle activeTextStyle;
  final TextStyle inactiveTextStyle;
  final BorderRadius borderRadius;
  final double width;
  final double height;

  @override
  _AdvancedSwitchState createState() => _AdvancedSwitchState();
}

class _AdvancedSwitchState extends State<AdvancedSwitch> with TickerProviderStateMixin {
  AnimationController _switchAnimController;

  @override
  void initState() {
    _switchAnimController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 250,
      ),
      value: widget.value ? 1.0 : 0.0,
    );

    super.initState();
  }

  @override
  void didUpdateWidget(AdvancedSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value == widget.value) {
      return;
    }

    if (widget.value) {
      _switchAnimController.forward();
    } else {
      _switchAnimController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final checked = widget.value;

    final animation = ColorTween(
      begin: widget.inactiveColor,
      end: widget.activeColor,
    ).animate(_switchAnimController);

    final dWidth = widget.width;
    final dHeight = widget.height;

    final switchSize = dHeight;
    final labelSize = dWidth - switchSize;
    final contentSize = labelSize * 2 + switchSize;

    return AnimatedBuilder(
      animation: _switchAnimController,
      builder: (_, child) {
        return Container(
          width: dWidth,
          height: dHeight,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            color: animation.value,
          ),
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: widget.borderRadius,
          onTap: () => widget.onChanged(!checked),
          child: AnimatedBuilder(
            animation: _switchAnimController,
            builder: (context, child) {
              return Transform.translate(
                offset: Tween<Offset>(
                  begin: Offset(-(dWidth / 2) + (switchSize / 2), 0),
                  end: Offset((dWidth / 2) - (switchSize / 2), 0),
                ).animate(_switchAnimController).value,
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
                  _buildSwitch(switchSize),
                  _buildLabel(
                    widget.inactiveLabel,
                    labelSize,
                    right: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(
    String value,
    double labelSize, {
    bool right = false,
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

  Widget _buildSwitch(double switchSize) {
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
      ),
    );
  }
}
