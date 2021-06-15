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
                Navigator.pushNamed(context, 'remo_connection');
              },
              icon: Icon(Icons.link),
              label: const Text('Connect Remo'),
              style: OutlinedButton.styleFrom(
                backgroundColor: Color.fromRGBO(241, 240, 235, 1),
                elevation: 15,
                fixedSize: Size(
                  MediaQuery.of(context).size.width * 0.8,
                  MediaQuery.of(context).size.height * 0.18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(60),
                ),
                side:
                    BorderSide(width: 1, color: Theme.of(context).primaryColor),
              ),
            ),
            SizedBox(height: 40),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Start',
                style: TextStyle(color: Colors.white),
              ),
              style: TextButton.styleFrom(
                fixedSize: Size(
                  MediaQuery.of(context).size.width * 0.35,
                  MediaQuery.of(context).size.height * 0.35,
                ),
                backgroundColor: Theme.of(context).primaryColor,
                shape: CircleBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
