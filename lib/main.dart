import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ADH',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 27, 178, 186)),
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

class MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  // Timer ////////////////////////////////////////////////////

  Timer? _timer;
  double timeFraction = 0.55;
  int secondsSinceMidnight = 0;

  void updateTime() {
    setState(() {
      secondsSinceMidnight = DateTime.now().hour * 3600 +
          DateTime.now().minute * 60 +
          DateTime.now().second;
      timeFraction = getCurrentTimeFraction();
    });
  }

  double getCurrentTimeFraction() {
    const totalSecondsInDay = 24 * 60 * 60;
    return secondsSinceMidnight / totalSecondsInDay;
  }

  // Timer ////////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      updateTime();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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
          onPressed: () {},
        ),
        actions: const <Widget>[],
      ),
      body: Container(
        color: const Color.fromARGB(255, 220, 240, 240),
        child: Timeline(timeFraction: timeFraction),
      ),
    );
  }
}

// timeline ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class Timeline extends StatefulWidget {
  const Timeline({super.key, required this.timeFraction});

  final double timeFraction;

  @override
  State<Timeline> createState() => TimelineState();
}

class TimelineState extends State<Timeline>
    with SingleTickerProviderStateMixin {
  // Time scale cards /////////////////////////////////////////

  WeekList? weekList;
  List<TimescaleCard> timeScaleCards = [];

  Future<void> _loadDocumentsJsonData() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final adhDirectory = Directory('${documentsDirectory.path}/adh');
      await adhDirectory.create(recursive: true);
      final file = File('${adhDirectory.path}/schedule.json');

      // Check if file exists
      if (await file.exists()) {
        // Read the file
        final contents = await file.readAsString();
        // Parse the JSON
        final jsonData = json.decode(contents);
        setState(() {
          weekList = WeekList.fromJson(jsonData);
          initCards();
        });
      } else {
        // Create the file and write a default JSON structure
        final defaultData = {'key': 'value'};
        await file.writeAsString(json.encode(defaultData));
      }
    } catch (e) {
      // Handle any errors
      print('Error reading or creating JSON file: $e');
    }
  }

  void initCards() {
    timeScaleCards = [];
    for (var week in weekList!.weeks) {
      for (var day in week.days) {
        timeScaleCards.add(TimescaleCard(day: day));
      }
    }
  }

  // Time scale cards /////////////////////////////////////////

  @override
  void initState() {
    super.initState();
    _loadDocumentsJsonData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 4), // between cards and ruler. 4 on desktop.
            child: TimeRulerH(zoomAmount: 0.5), //not used, random zoomAmount
          ),
          Expanded(
            child: SingleChildScrollView(
              child: CustomPaint(
                foregroundPainter:
                    ArrowHeadPainter(fraction: widget.timeFraction),
                child: Column(
                  children: timeScaleCards,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// timeline ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Card And Block /////////////////////////////////////////////////////////////////////////////////////////////////////////////

class TimescaleCard extends StatefulWidget {
  final Day day;

  const TimescaleCard({super.key, required this.day});

  @override
  State<TimescaleCard> createState() => TimescaleCardState();
}

class TimescaleCardState extends State<TimescaleCard> {
  bool rackOpen = false;
  bool isToday = false;

  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }

  double _calculateTODPosition(TimeOfDay? tod, double cardWidth) {
    if (tod == null) {
      return -1;
    }
    return tod.hour * cardWidth / 24 + tod.minute * cardWidth / 24 / 60;
  }

  double _calculateWidth(TimeOfDay? start, TimeOfDay? end, double cardWidth) {
    if (start == null || end == null) {
      return -1;
    }
    return (end.hour - start.hour) * cardWidth / 24 +
        (end.minute - start.minute) * cardWidth / 24 / 60;
  }

  @override
  void initState() {
    super.initState();
    if (widget.day.date.year == DateTime.now().year &&
        widget.day.date.month == DateTime.now().month &&
        widget.day.date.day == DateTime.now().day) {
      isToday = true;
    }
    rackOpen = isToday;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!rackOpen) {
          setState(() {
            rackOpen = true;
          });
        } else if (rackOpen) {
          setState(() {
            rackOpen = false;
          });
        }
      },
      child: Card(
        color:
            !isToday ? const Color.fromARGB(255, 210, 225, 225) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double cardWidth = constraints.maxWidth;
                    return Container(
                      constraints:
                          const BoxConstraints(maxWidth: 3000, maxHeight: 200),
                      child: Stack(
                        children: widget.day.blocks.map((block) {
                          double left =
                              _calculateTODPosition(block.start, cardWidth);
                          double width = _calculateWidth(
                              block.start, block.end, cardWidth);
                          if (left == -1 || width == -1) {
                            return Container();
                          }
                          return Positioned(
                            left: left,
                            width: width,
                            height: 200,
                            child: BlockWidget(block: block),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ]),
            if (rackOpen)
              Column(
                children: [
                  const TimeRulerH(zoomAmount: 0.5),
                  Row(
                    children: [
                      Text('${widget.day.description} / ${widget.day.name}'),
                      Text(' / ${widget.day.date}'),
                      Text(' / ${_getWeekdayName(widget.day.date.weekday)}'),
                      IconButton(
                          onPressed: () {}, icon: const Icon(Icons.book)),
                      IconButton(
                          onPressed: () {}, icon: const Icon(Icons.place)),
                      IconButton(
                          onPressed: () {}, icon: const Icon(Icons.play_arrow)),
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.play_for_work)),
                    ],
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}

class BlockWidget extends StatelessWidget {
  final Block block;

  const BlockWidget({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Text("${block.description} ${block.name}"),
          Text('${block.start} - ${block.end}'),
        ],
      ),
    );
  }
}

// Card And Block /////////////////////////////////////////////////////////////////////////////////////////////////////////////

//arrowHead and ruler//////////////////////////////////////////////////////////////////////////////////////////////////////////

class ArrowHeadPainter extends CustomPainter {
  final double fraction;

  ArrowHeadPainter({required this.fraction});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2;

    double x = size.width * fraction;

    canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class TimeRulerH extends StatelessWidget {
  final double zoomAmount;

  const TimeRulerH({super.key, required this.zoomAmount});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      width: 3000,
      color: Colors.green,
      child: CustomPaint(
        painter: TimeRulerPainterH(zoomAmount: zoomAmount),
      ),
    );
  }
}

class TimeRulerPainterH extends CustomPainter {
  final double zoomAmount;

  TimeRulerPainterH({required this.zoomAmount});

  // Draw the horizontal time ruler

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    for (int i = 0; i < 48; i++) {
      double x = i * size.width / 24 * zoomAmount;
      if (i % 2 == 0) {
        canvas.drawLine(Offset(x, 2), Offset(x, size.height - 2), paint);

        int j = i ~/ 2;

        TextSpan span = TextSpan(
          style: const TextStyle(color: Colors.white),
          text: ' $j',
        );

        TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );

        tp.layout();

        tp.paint(canvas, Offset(x, 0));
      } else if (size.width / 24 * zoomAmount > 20) {
        canvas.drawLine(Offset(x, 2), Offset(x, size.height - 5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

//arrowHead and ruler//////////////////////////////////////////////////////////////////////////////////////////////////////////

//Models///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class Week {
  final DateTime firstMonday;
  final List<Day> days;
  int templateId = 0;
  String name = 'Week';
  String description = 'Week description';

  Week(
      {required this.firstMonday,
      required this.days,
      this.name = 'Week',
      this.description = 'Week description',
      this.templateId = 0});
}

class Day {
  final DateTime date;
  final List<Block> blocks;
  List<Interruption> interruptions;
  int templateId = 0;
  String name = 'Day';
  String description = 'Day description';

  Day(
      {required this.date,
      required this.blocks,
      this.interruptions = const [],
      this.name = 'Day',
      this.description = 'Day description',
      this.templateId = 0});
}

class Block {
  int templateId = 0;
  String name;
  String description;
  final TimeOfDay? start;
  final TimeOfDay? end;

  Block(
      {required this.start,
      required this.end,
      this.name = 'Block',
      this.description = 'Block description',
      this.templateId = 0});
}

class Interruption {
  int templateId = 0;
  String name = 'Interruption';
  String description = 'Interruption description';
  final TimeOfDay? start;
  final TimeOfDay? end;

  Interruption(
      {required this.start,
      required this.end,
      this.name = 'Interruption',
      this.description = 'Interruption description',
      this.templateId = 0});
}

Day getDayFromTemplate(int templateId, DateTime date) {
  return Day(
      date: date,
      blocks: [
        Block(
            start: TimeOfDay.fromDateTime(
                DateTime.now().add(const Duration(hours: -1))),
            end: TimeOfDay.fromDateTime(
                DateTime.now().add(const Duration(hours: 1))),
            name: 'Template',
            description: 'Template description',
            templateId: templateId)
      ],
      interruptions: [],
      name: 'Template',
      description: 'Template description',
      templateId: 0);
}

class WeekList {
  final List<Week> weeks;
  final DateTime firstMonday;

  WeekList({required this.weeks, required this.firstMonday});

  factory WeekList.fromJson(Map<String, dynamic> json) {
    List<Week> weeks = [];
    DateTime firstMondayOfWeeks = DateTime.parse(json['firstMonday']);

    int i = 0;
    int j = 0;
    for (var week in json['weeks']) {
      List<Day> days = [];
      for (var day in week['days']) {
        List<Block> blocks = [];
        for (var block in day['blocks']) {
          String start = block['start'];
          String end = block['end'];
          Block blockToAdd = Block(
              start: (start == '')
                  ? null
                  : TimeOfDay.fromDateTime(
                      DateTime.parse("0000-00-00 $start:00")),
              end: (end == '')
                  ? null
                  : TimeOfDay.fromDateTime(
                      DateTime.parse("0000-00-00 $end:00")),
              name: block['name'],
              description: block['description'],
              templateId: block['templateId']);
          blocks.add(blockToAdd);
        }
        List<Interruption> interruptions = [];
        if (day['interruptions'] != null) {
          for (var interruption in day['interruptions']) {
            String start = interruption['start'];
            String end = interruption['end'];
            Interruption interruptionToAdd = Interruption(
                start: (start == '')
                    ? null
                    : TimeOfDay.fromDateTime(
                        DateTime.parse("0000-00-00 $start:00")),
                end: (end == '')
                    ? null
                    : TimeOfDay.fromDateTime(
                        DateTime.parse("0000-00-00 $end:00")),
                name: interruption['name'],
                description: interruption['description'],
                templateId: interruption['templateId']);
            interruptions.add(interruptionToAdd);
          }
        }
        Day dayToAdd = Day(
            date: firstMondayOfWeeks.add(Duration(days: j)),
            blocks: blocks,
            interruptions: interruptions,
            name: day['name'],
            description: day['description'],
            templateId: day['templateId']);
        if (dayToAdd.templateId != 0) {
          dayToAdd = getDayFromTemplate(
              dayToAdd.templateId, firstMondayOfWeeks.add(Duration(days: j)));
        }
        days.add(dayToAdd);
        j++;
      }
      Week weekToAdd = Week(
          firstMonday: firstMondayOfWeeks.add(Duration(days: i)),
          days: days,
          name: week['name'],
          description: week['description'],
          templateId: week['templateId']);
      weeks.add(weekToAdd);
      i += 7;
    }
    return WeekList(weeks: weeks, firstMonday: firstMondayOfWeeks);
  }
}
