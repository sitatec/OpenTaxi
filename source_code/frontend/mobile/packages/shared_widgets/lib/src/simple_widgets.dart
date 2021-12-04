import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_widgets/shared_widgets.dart';

class OutLinedTextField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final Widget? prefixIcon;
  final Color? fillColor;
  final String? hintText;
  final double borderRadius;
  final Color borderColor;
  final EdgeInsets prefixPadding;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;

  const OutLinedTextField({
    Key? key,
    required this.onChanged,
    this.prefixIcon,
    this.fillColor,
    this.hintText,
    this.borderRadius = 10,
    this.borderColor = gray,
    this.prefixPadding = const EdgeInsets.only(left: 15, right: 13),
    this.inputFormatters,
    this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 16.5),
        prefixIcon: Padding(
          padding: prefixPadding,
          child: prefixIcon,
        ),
        prefixIconConstraints: const BoxConstraints(
          minHeight: 24,
          minWidth: 24,
        ),
        fillColor: fillColor,
        hintText: hintText,
        filled: fillColor != null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: borderColor,
            width: 0.6,
          ),
        ),
      ),
    );
  }
}

class RoundedCornerButton extends StatelessWidget {
  Color? disabledColor, enabledColor;
  final VoidCallback? onPressed;
  final Widget child;
  final BorderSide borderSide;

  RoundedCornerButton(
      {Key? key,
      this.disabledColor,
      this.enabledColor,
      this.onPressed,
      this.borderSide = BorderSide.none,
      this.child = const Text(
        "Continue",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      )})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    disabledColor ??= theme.disabledColor;
    enabledColor ??= theme.primaryColor;
    return SizedBox(
      height: 54,
      child: TextButton(
        onPressed: onPressed,
        child: SizedBox(
          width: double.infinity,
          child: child,
        ),
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: borderSide,
            ),
          ),
          backgroundColor: MaterialStateProperty.resolveWith(
            (states) => states.contains(MaterialState.disabled)
                ? disabledColor
                : enabledColor,
          ),
        ),
      ),
    );
  }
}

class Gender extends StatelessWidget {
  final String genderName;
  final Color? backgroundColor;
  final ValueChanged<String>? onClicked;

  const Gender(this.genderName,
      {Key? key, this.backgroundColor, this.onClicked})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => onClicked?.call(genderName),
      icon: SvgPicture.asset(
        "assets/images/${genderName.toLowerCase()}.svg",
        package: "shared_widgets",
      ),
      label: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          genderName[0].toUpperCase() + genderName.substring(1),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(backgroundColor ?? lightGray),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: backgroundColor ?? const Color(0xFFACACAC),
              width: 0.6,
            ),
          ),
        ),
      ),
    );
  }
}
