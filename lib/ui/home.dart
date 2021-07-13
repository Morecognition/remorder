import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Remorder'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/remo_connection');
              },
              icon: Icon(Icons.link),
              label: const Text(
                'Connect Remo',
                style: TextStyle(fontSize: 25),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Color.fromRGBO(241, 240, 235, 1),
                elevation: 15,
                fixedSize: Size(
                  MediaQuery.of(context).size.width * 0.8,
                  MediaQuery.of(context).size.height * 0.18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                side:
                    BorderSide(width: 1, color: Theme.of(context).primaryColor),
              ),
            ),
            SizedBox(height: 40),
            OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/remo_transmission');
              },
              child: const Text(
                'Start',
              ),
              style: OutlinedButton.styleFrom(
                fixedSize: Size(
                  MediaQuery.of(context).size.width * 0.40,
                  MediaQuery.of(context).size.height * 0.40,
                ),
                backgroundColor: Color.fromRGBO(241, 240, 235, 1),
                shape: CircleBorder(),
                elevation: 15,
                side:
                    BorderSide(width: 1, color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
