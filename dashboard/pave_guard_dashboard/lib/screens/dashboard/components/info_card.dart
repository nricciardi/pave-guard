import 'package:flutter/material.dart';

import '../../../constants.dart';

class InfoCard extends StatelessWidget {
  
  const InfoCard({
    Key? key,
    required this.title,
    required this.value,
    this.titleStyle,
    this.valueStyle
  }) : super(key: key);

  final String title;
  final String value;
  final TextStyle? titleStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            this.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: this.titleStyle,
          ),
          Text(
            this.value,
            maxLines: 1,
            style: this.valueStyle,
          ),
        ],
      ),
    );
  }
}
