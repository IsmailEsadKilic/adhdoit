import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ADH',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 27, 178, 186)),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {

  var scheduleJSON = "{\"schedule\": [{\"day\": \"Monday\", \"time\": \"8:00 AM\"}, {\"day\": \"Tuesday\", \"time\": \"9:00 AM\"}, {\"day\": \"Wednesday\", \"time\": \"10:00 AM\"}, {\"day\": \"Thursday\", \"time\": \"11:00 AM\"}, {\"day\": \"Friday\", \"time\": \"12:00 PM\"}]}";
  var zoomAmount = 1.0;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(4),
          child: Divider(height: 4, color: Color.fromARGB(255, 27, 178, 186)),
        ),
        leadingWidth: 200,
        leading: IconButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          padding: const EdgeInsets.all(0),
          icon: Image.asset('images/adhdoit_title_1.png'),
          onPressed: () {
          },
        ),
        actions: const <Widget>[
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Schedule: $scheduleJSON'),
        ],
      ),
    );
  }
}
