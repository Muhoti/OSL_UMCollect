// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DialogInput extends StatefulWidget {
  final String title;
  final String value;
  final int lines;
  final TextInputType type;
  final Function(dynamic) onSubmit;

  const DialogInput(
      {super.key,
      required this.title,
      required this.lines,
      required this.value,
      required this.type,
      required this.onSubmit});

  @override
  State<StatefulWidget> createState() => _DialogInputState();
}

class _DialogInputState extends State<DialogInput> {
  TextEditingController _controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant DialogInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      setState(() {
        _controller.text =
            widget.value != "null" ? widget.value.toString() : '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
          hintColor: Colors.white,
          inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Color.fromARGB(255, 28, 100, 140))),
              focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Color.fromARGB(255, 28, 100, 140))))),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
        child: TextFormField(
          onChanged: (value) {
            widget.onSubmit(value);
          },
          keyboardType: widget.type,
          controller: _controller,
          maxLines: widget.lines,
          style: const TextStyle(
            color: Color.fromARGB(255, 28, 100, 140),
          ),
          cursorColor: const Color.fromARGB(255, 28, 100, 140),
          obscureText: widget.type == TextInputType.visiblePassword,
          enableSuggestions: true,
          autocorrect: false,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(8),
            hintStyle: const TextStyle(
              color: Color.fromARGB(255, 28, 100, 140),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                  color: Color.fromARGB(255, 28, 100, 140), width: 1.0),
            ),
            filled: false,
            label: Text(
              widget.title,
              style: const TextStyle(
                color: Color.fromARGB(255, 28, 100, 140),
              ),
            ),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
          ),
        ),
      ),
    );
  }
}
