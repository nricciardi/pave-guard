import 'package:flutter/material.dart';

import '../../../constants.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  final String title;
  final String value;

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
            this.value,
            maxLines: 1,
          ),
          Text(
            this.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text(
          //       "${info.numOfFiles} Files",
          //       style: Theme.of(context)
          //           .textTheme
          //           .bodySmall!
          //           .copyWith(color: Colors.white70),
          //     ),
          //     Text(
          //       info.totalStorage!,
          //       style: Theme.of(context)
          //           .textTheme
          //           .bodySmall!
          //           .copyWith(color: Colors.white),
          //     ),
          //   ],
          // )
        ],
      ),
    );
  }
}
