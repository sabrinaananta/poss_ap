import 'package:flutter/material.dart';

class CardOrderItem extends StatelessWidget {
  const CardOrderItem({required this.name, super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          color: Colors.grey[300],
          child: Center(
            child: Icon(Icons.image, color: Colors.white),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                ),
              ),
              // if (details.isNotEmpty)
              //   Text(
              //     details,
              //     style: TextStyle(color: Colors.grey),
              //   ),
              // SizedBox(height: 8),
              // Text(
              //   _formatRupiah(price),
              //   style: TextStyle(fontWeight: FontWeight.bold),
              // ),
            ],
          ),
        ),
      ],
    );
    ;
  }
}
