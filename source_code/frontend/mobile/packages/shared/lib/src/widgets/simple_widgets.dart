import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../shared.dart';

class OutLinedTextField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final Widget? prefixIcon;
  final String? prefixText;
  final Color? fillColor;
  final String? hintText;
  final double borderRadius;
  final Color borderColor;
  final EdgeInsets prefixPadding;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? errorMessage;

  const OutLinedTextField({
    Key? key,
    required this.onChanged,
    this.prefixIcon,
    this.fillColor,
    this.prefixText,
    this.hintText,
    this.borderRadius = 10,
    this.borderColor = gray,
    this.prefixPadding = const EdgeInsets.only(left: 15, right: 10),
    this.inputFormatters,
    this.keyboardType,
    this.errorMessage,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: maxLines,
      onChanged: onChanged,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
      decoration: InputDecoration(
        errorText: errorMessage,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.5,
          horizontal: 16,
        ),
        prefixIcon: prefixIcon != null
            ? Padding(padding: prefixPadding, child: prefixIcon)
            : null,
        prefixIconConstraints: const BoxConstraints(
          minHeight: 24,
          minWidth: 24,
        ),
        fillColor: fillColor,
        hintText: hintText,
        prefixText: prefixText,
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
  final double borderRadius;

  RoundedCornerButton(
      {Key? key,
      this.disabledColor,
      this.borderRadius = 10,
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
              borderRadius: BorderRadius.circular(borderRadius),
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

class SmallRoundedCornerButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final String text;
  final EdgeInsets? padding;
  const SmallRoundedCornerButton(
    this.text, {
    Key? key,
    this.onPressed,
    this.backgroundColor,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        padding: padding,
      ),
    );
  }
}

class GenderWidget extends StatelessWidget {
  final String genderName;
  final Color? backgroundColor;
  final ValueChanged<String>? onClicked;

  const GenderWidget(this.genderName,
      {Key? key, this.backgroundColor, this.onClicked})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => onClicked?.call(genderName),
      icon: SvgPicture.asset(
        "assets/images/${genderName.toLowerCase()}.svg",
        package: "shared",
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
        backgroundColor:
            MaterialStateProperty.all(backgroundColor ?? lightGray),
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
