import 'package:flutter/material.dart';
import 'package:majorproject_covid19_tracker/pages/info.dart';
import 'package:majorproject_covid19_tracker/panels/comments.dart';

class InfoPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CommentPage()));
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              color: Colors.blue,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'COMMENT',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),

                ],
              ),
            ),
          ),



        ],
      ),
    );
  }
}
