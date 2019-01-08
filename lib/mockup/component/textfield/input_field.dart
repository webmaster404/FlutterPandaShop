import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../constants/constant_colors.dart';
import '../../constants/constant_spacing.dart';

abstract class InputFieldDelegate {
  inputFieldTextDidChanged(InputField inputField, String value);
  inputFieldTextDidEndEditing(InputField inputField, String value);
  bool inputFieldShouldChangedText(InputField inputField, String newValue);
}

class InputField extends StatefulWidget {
  final String text;
  final int maxLength;
  final TextStyle textStyle;
  final String placeHolderText;
  final Widget prefixView;
  final Widget suffixView;
  final bool obscureMode;
  final InputFieldDelegate delegate;

  const InputField({
    Key key,
    this.placeHolderText = "",
    this.text = "",
    this.prefixView,
    this.suffixView,
    this.obscureMode = false,
    @required this.delegate,
    this.textStyle,
    this.maxLength = -1,
  }) : super(key: key);

  @override
  _InputFieldState createState() => _InputFieldState(this, new TextEditingController(text: text));
}

class _InputFieldState extends State<InputField> {
  final InputField view;

  final TextEditingController _controller;
  String _oldValue = "";
  FocusNode _focus;

  _InputFieldState(this.view, this._controller) {
    this._focus = FocusNode();
    this._controller.addListener(_textFieldWatcher);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    this._controller.dispose();
    super.dispose();
  }

  void _textFieldWatcher() {
    String newValue = this._controller.text;
    if (newValue == _oldValue) {
      return;
    }

    if (null == this.view.delegate) {
      return;
    }

    if (false == this.view.delegate.inputFieldShouldChangedText(this.view, newValue)) {
      this._controller.text = this._oldValue;
      this._controller.selection = TextSelection(baseOffset: this._oldValue.length, extentOffset: this._oldValue.length);
      return;
    }

    this.view.delegate.inputFieldTextDidChanged(this.view, newValue);
    _oldValue = newValue;
  }

  void _textFieldDidEndEditing(BuildContext context, String value) {
    if (null == this.view.delegate) {
      return;
    }

    if (true == this.view.delegate.inputFieldShouldChangedText(this.view, value)) {
      this._oldValue = value;
    }

    this.view.delegate.inputFieldTextDidEndEditing(this.view, value);
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> prefixIcon = List<Widget>();
    List<Widget> suffixIcon = List<Widget>();

    if (this.view.prefixView != null) {
      prefixIcon.add(this.view.prefixView);
    }

    if (this.view.suffixView != null) {
      suffixIcon.add(this.view.suffixView);
    }

    return Container(
      child: TextField(
        focusNode: this._focus,
        style: this.view.textStyle,
        controller: this._controller,
        onEditingComplete: () => _textFieldDidEndEditing(context, this._oldValue),
        onSubmitted: (value) => _textFieldDidEndEditing(context, value),
        obscureText: this.view.obscureMode,
        decoration: InputDecoration(
          prefixIcon: Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            children: prefixIcon,
          ),
          suffixIcon: Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            children: suffixIcon,
          ),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(width: Spacing.xxxs, color: Colours.dark)),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(width: Spacing.xxxs, color: Colours.dark)),
        ),
      ),
    );
  }
}