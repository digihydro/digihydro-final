import 'package:flutter/material.dart';

class ExpandableTextWidget extends StatefulWidget {
  final String text;

  ExpandableTextWidget({required this.text});

  @override
  _ExpandableTextWidgetState createState() => new _ExpandableTextWidgetState();
}

class _ExpandableTextWidgetState extends State<ExpandableTextWidget> {
  String _text = "";
  bool flag = true;
  bool hasShowMore = false;

  @override
  void initState() {
    super.initState();

    if (widget.text.length > 500) {
      _text = widget.text.substring(0, 500);
    }

  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: _text.isEmpty
          ? Text(widget.text,
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).primaryColor,
              ),
            )
          : Column(
        children: [
          Text(flag ? (_text + " ...") : widget.text,
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(context).primaryColor,
            ),
          ),
          InkWell(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                 Text(
                  flag ? "show more" : "show less",
                  style: TextStyle(color: Colors.blue),
                ),
              ],
            ),
            onTap: () {
              setState(() {
                flag = !flag;
              });
            },
          ),
        ],
      ),
    );
  }
}