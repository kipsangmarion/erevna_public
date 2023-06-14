// ignore_for_file: file_names

import 'package:flutter/material.dart';

class ETextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final String? labelText;
  const ETextField({Key? key, this.controller, this.labelText, this.validator})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      style: const TextStyle(fontSize: 25),
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Colors.white,
        // focusedBorder: const OutlineInputBorder(
        //   borderRadius: BorderRadius.all(Radius.circular(30)),
        //   borderSide: BorderSide(width: 1, color: Colors.red),
        // ),
        // disabledBorder: const OutlineInputBorder(
        //   borderRadius: BorderRadius.all(Radius.circular(30)),
        //   borderSide: BorderSide(width: 1, color: Colors.orange),
        // ),
        // enabledBorder: const OutlineInputBorder(
        //   borderRadius: BorderRadius.all(Radius.circular(30)),
        //   borderSide: BorderSide(width: 1, color: Colors.green),
        // ),
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide(
              width: 1,
            )),
        // errorBorder: const OutlineInputBorder(
        //     borderRadius: BorderRadius.all(Radius.circular(30)),
        //     borderSide: BorderSide(width: 1, color: Colors.black)),
        // focusedErrorBorder: const OutlineInputBorder(
        //     borderRadius: BorderRadius.all(Radius.circular(30)),
        //     borderSide: BorderSide(width: 1, color: Colors.yellowAccent)),
        hintText: labelText!,
        hintStyle: const TextStyle(fontSize: 25, color: Color(0xFFB3B1B1)),
      ),
      controller: controller,
    );
  }
}
