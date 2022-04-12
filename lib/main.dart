import 'package:day_to_day/inherited.dart';
import 'package:day_to_day/months.dart';
import 'package:day_to_day/to_do_list_directory_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:day_to_day/calendar.dart';
import 'package:day_to_day/event_form.dart';
import 'dart:async';

StreamController<bool> streamController = StreamController<bool>.broadcast();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(DayToDay());
}

class DayToDay extends StatelessWidget {
  final Future<FirebaseApp> _fbApp = Firebase.initializeApp();
  DayToDay({Key? key}) : super(key: key);
  bool wic = true;

  @override
  Widget build(BuildContext context) => InheritedState(
      child: MaterialApp(
        title: "DayToDay",
        theme: ThemeData(
          timePickerTheme: TimePickerThemeData(
            //backgroundColor: Colors.red[200],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            hourMinuteShape: const CircleBorder(),
          ),

          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.white,

          /* light theme settings */
        ),
        darkTheme: ThemeData(
          timePickerTheme: TimePickerThemeData(
            backgroundColor: Colors.grey[900],
            dayPeriodTextColor: Colors.white,
            entryModeIconColor: Colors.white,
            dialTextColor: Colors.white,
            hourMinuteTextColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            hourMinuteShape: const CircleBorder(),
          ),
            colorScheme: ColorScheme.fromSwatch().copyWith(
                primary: Colors.red[200],
                secondary: Colors.redAccent[200],
                  brightness: Brightness.dark,
            ),
          brightness: Brightness.dark,

          scaffoldBackgroundColor: Colors.black,
        ),
        themeMode: ThemeMode.system,
        /* ThemeMode.system to follow system theme,
         ThemeMode.light for light theme,
         ThemeMode.dark for dark theme
      */
        //home: const MyStatefulWidget(),
        home: FutureBuilder(
          future: _fbApp,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print('You have an error! ${snapshot.error.toString()}');
              return const Text('Something went wrong!');
            } else if (snapshot.hasData) {
              return const AppWidget();
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
        debugShowCheckedModeBanner: false,
      ),
  );
}

class AppWidget extends StatefulWidget {
  const AppWidget({Key? key}) : super(key: key);
  @override
  State<AppWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<AppWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var systemColor = MediaQuery.of(context).platformBrightness;
    bool darkMode = systemColor == Brightness.dark;
    Color labelColorChange;

    if (darkMode) {
      labelColorChange = Colors.red[400]!;
    } else {
      labelColorChange = Colors.red[400]!;
    }
    Color? appBarC;
    Color? appBarT;
    if (darkMode) {
      appBarC = Colors.grey[800];
      appBarT = Colors.white;
    }
    else {
      appBarC = Colors.white10;
      appBarT = Colors.black;
    }

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: const Text('Ex1'),
              onTap: () {

                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Ex2'),
              onTap: () {

                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => onAddEventButtonPressed(),
        child: const Icon(Icons.add,size: 45, color: Colors.white,),
        backgroundColor: Colors.blueGrey,
      ),
      appBar: AppBar(
        title: Text('DayToDay', style: TextStyle(color: appBarT),),
        backgroundColor: appBarC,
        actions: [
          IconButton(
            onPressed: () => onSearchButtonPressed(),
            icon: Image.asset(
              "assets/icons/search-icon.png",
            ),
            splashRadius: 20,
          ),
          /*IconButton(
            onPressed: () => onFindMyDayPressed(equation, pageController),
            icon: Image.asset(
              "assets/icons/find-the-day.png",
            ),
            splashRadius: 20,
          ),*/
        ],
        bottom: TabBar(
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          controller: _tabController,
          isScrollable: true,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: <Widget>[
            Tab(
              text: "Calendar",

              icon: Image.asset(
                'assets/icons/icons8-calendar-48.png',
                scale: 2,
              ),

              //icon: ImageIcon(
              //  AssetImage("assets/icons/icons8-calendar-48.png"),
              //  size: 24,
              //),
            ),
            const Tab(
              text: "To-Do",
            ),
            const Tab(
              text: "Projects",
            ),
            const Tab(
              text: "Assignments",
            ),
            const Tab(
              text: "Exams",
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          CalendarWidget(stream: streamController.stream,),
          const ToDoListDirectoryWidget(),
          const Center(
            child: Text("Projects"),
          ),
          const Center(
            child: Text("HW"),
          ),
          const Center(
            child: Text("Exams"),
          )
        ],
      ),
    );
  }
  void onSearchButtonPressed() {}
  void onAddEventButtonPressed() {

    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      int? clicked = StateWidget.of(context)?.clicked;


      //print(clicked);
      return const EventForm();
    }));

  }


}
