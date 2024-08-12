import 'package:flutter/material.dart';

class MyRowIII extends StatefulWidget {
  final String no;
  final String title;
  final String image;

  const MyRowIII({
    Key? key,
    required this.no,
    required this.title,
    required this.image,
  }) : super(key: key);

  @override
  State<MyRowIII> createState() => _MyRowIIIState();
}

class _MyRowIIIState extends State<MyRowIII> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 8, 16, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9F1), // Cream color
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(82, 158, 158, 158),
            offset: Offset(2.0, 2.0),
            blurRadius: 5.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                widget.image,
                height: 64,
              ),
              const Expanded(
                child: SizedBox(
                  height: 8,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  widget.no == "" ? "" : widget.no,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 28, 100, 140),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            width: 8,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              widget.title,
              style: const TextStyle(
                  color: Color.fromARGB(255, 28, 100, 140),
                  fontWeight: FontWeight.bold,
                  fontSize: 22),
            ),
          ),
        ],
      ),
    );
  }
}
