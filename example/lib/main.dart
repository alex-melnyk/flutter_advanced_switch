import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _value00 = false;
  bool _value01 = false;
  bool _value02 = false;
  bool _value03 = false;
  bool _value04 = false;
  bool _value05 = false;
  bool _value06 = false;
  bool _value07 = false;
  bool _value08 = false;
  bool _value09 = false;
  bool _value10 = false;
  bool _value11 = false;
  bool _value12 = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Advanced Switch'),
        ),
        body: Container(
          width: double.infinity,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              vertical: 40,
            ),
            physics: ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildLabel('Default Switch'),
                AdvancedSwitch(
                  value: _value00,
                  onChanged: (value) => setState(() {
                    _value00 = value;
                  }),
                ),
                _buildLabel('Disabled Switch'),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AdvancedSwitch(
                      value: false,
                    ),
                    SizedBox(width: 25),
                    AdvancedSwitch(
                      value: true,
                    ),
                  ],
                ),
                _buildLabel('Number Switch'),
                AdvancedSwitch(
                  activeLabel: '1',
                  inactiveLabel: '0',
                  value: _value01,
                  onChanged: (value) => setState(() {
                    _value01 = value;
                  }),
                ),
                _buildLabel('ON/OFF Switch'),
                AdvancedSwitch(
                  activeLabel: 'ON',
                  inactiveLabel: 'OFF',
                  width: 70,
                  value: _value02,
                  onChanged: (value) => setState(() {
                    _value02 = value;
                  }),
                ),
                _buildLabel('COLOR Switch'),
                AdvancedSwitch(
                  activeColor: Colors.yellow,
                  inactiveColor: Colors.indigo,
                  activeLabel: 'Yellow',
                  inactiveLabel: 'Indigo',
                  width: 90,
                  value: _value03,
                  onChanged: (value) => setState(() {
                    _value03 = value;
                  }),
                ),
                _buildLabel('ON/OFF Rounded Switch'),
                AdvancedSwitch(
                  activeLabel: 'ON',
                  inactiveLabel: 'OFF',
                  borderRadius: BorderRadius.circular(5),
                  width: 76,
                  value: _value04,
                  onChanged: (value) => setState(() {
                    _value04 = value;
                  }),
                ),
                _buildLabel('ON/OFF Rect Switch'),
                AdvancedSwitch(
                  activeLabel: 'true',
                  inactiveLabel: 'false',
                  borderRadius: BorderRadius.zero,
                  width: 76,
                  value: _value05,
                  onChanged: (value) => setState(() {
                    _value05 = value;
                  }),
                ),
                _buildLabel('XXS Switch'),
                AdvancedSwitch(
                  width: 16,
                  height: 8,
                  value: _value06,
                  onChanged: (value) => setState(() {
                    _value06 = value;
                  }),
                ),
                _buildLabel('XS Switch'),
                AdvancedSwitch(
                  width: 32,
                  height: 16,
                  value: _value07,
                  onChanged: (value) => setState(() {
                    _value07 = value;
                  }),
                ),
                _buildLabel('Small Switch'),
                AdvancedSwitch(
                  width: 48,
                  height: 24,
                  value: _value08,
                  onChanged: (value) => setState(() {
                    _value08 = value;
                  }),
                ),
                _buildLabel('Medium Switch'),
                AdvancedSwitch(
                  width: 56,
                  height: 28,
                  value: _value09,
                  onChanged: (value) => setState(() {
                    _value09 = value;
                  }),
                ),
                _buildLabel('Large Switch'),
                AdvancedSwitch(
                  width: 72,
                  height: 36,
                  value: _value10,
                  borderRadius: BorderRadius.circular(18),
                  onChanged: (value) => setState(() {
                    _value10 = value;
                  }),
                ),
                _buildLabel('XL Switch'),
                AdvancedSwitch(
                  width: 96,
                  height: 48,
                  value: _value11,
                  borderRadius: BorderRadius.circular(24),
                  onChanged: (value) => setState(() {
                    _value11 = value;
                  }),
                ),
                _buildLabel('XXL Switch'),
                AdvancedSwitch(
                  width: 112,
                  height: 56,
                  value: _value12,
                  borderRadius: BorderRadius.circular(29),
                  onChanged: (value) => setState(() {
                    _value12 = value;
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String value) {
    return Container(
      margin: EdgeInsets.only(
        top: 25,
        bottom: 5,
      ),
      child: Text(
        '$value',
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
    );
  }
}
