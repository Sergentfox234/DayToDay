import 'dart:async';
import 'package:day_to_day/inherited.dart';
import 'package:day_to_day/months.dart';
import 'package:flutter/material.dart';
import 'event_form.dart';
import 'package:day_to_day/user_sync.dart';
import 'events.dart';
import 'globals.dart' as globals;
import 'package:firebase_database/firebase_database.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({Key? key, required this.stream}) : super(key: key);
  final Stream<bool> stream;


  @override
  State<CalendarWidget> createState() => CalendarState();
}

class CalendarState extends State<CalendarWidget> {
  //Creating month object to get data about what day it is
  Months n = Months();
  PageController pageController = PageController();
  String display = "";
  int clickedPosition = -1;
  List<Widget> dayClicked = [];
  Map<String, Events> span = {};
  int pag = 0;
  List<Events> deleteSearch = [];

  @override
  void initState() {
    var equation = ((getCurrentYear() - 1980) * 12 + getCurrentMonth()) - 1;
    pageController = PageController(initialPage: equation);
    widget.stream.listen((event) {
      mySetStateAdd();
    });
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void mySetStateAdd() {
    setState(() {
      clickedPosition = -1;
      dayClicked.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    Months monthView;
    var systemColor = MediaQuery
        .of(context)
        .platformBrightness;
    bool darkMode = systemColor == Brightness.dark;

    return InheritedState(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => onAddEventButtonPressed(),
          child: const Icon(
            Icons.add,
            size: 45,
            color: Colors.white,
          ),
          backgroundColor: Colors.blueGrey,
        ),
        body: Column(
          children: [
            Expanded(
              //Builds separate page for each month of every year since 1980
              child: PageView.builder(
                controller: pageController,
                scrollDirection: Axis.vertical,
                itemBuilder: (BuildContext context, int pages) {
                  int temporaryM = pages;
                  pag = pages;

                  if (clickedPosition == -1) {
                    deleteSearch.clear();
                    Widget firstLine;
                    Widget secondLine;
                    clickedPosition = getCurrentDay();
                    String dayStringFirst = getCurrentDay().toString();
                    String monthStringFirst = getCurrentMonth().toString();
                    if (getCurrentDay() <= 9) {
                      dayStringFirst = "0" + dayStringFirst;
                    }
                    if (getCurrentMonth() <= 9) {
                      monthStringFirst = "0" + monthStringFirst;
                    }
                    if (globals.eventsList[dayStringFirst +
                        monthStringFirst +
                        getCurrentYear().toString()] !=
                        null) {
                      globals.eventsList[dayStringFirst +
                          monthStringFirst +
                          getCurrentYear().toString()]
                          ?.forEach((element) {
                        firstLine = Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  color: element.color),
                              height: 15,
                              width: 2,
                            ),
                            const Padding(padding: EdgeInsets.only(right: 10)),
                            Text(
                              element.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ],
                        );
                        String timeF = TimeOfDay(
                            hour: element.from.hour,
                            minute: element.from.minute)
                            .format(context);
                        String timeT = TimeOfDay(
                            hour: element.to.hour,
                            minute: element.to.minute)
                            .format(context);
                        String repeatingString;

                        if (element.from.day == element.to.day &&
                            element.from.month == element.to.month &&
                            element.from.year == element.to.year) {
                          secondLine = Center(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Text(timeF + " - " + timeT),
                            ),
                          );
                        } else if (element.from.year == element.to.year) {
                          secondLine = Center(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Text(Months()
                                  .getMonthShort(element.from.month)! +
                                  " " +
                                  element.from.day.toString() +
                                  ", " +
                                  timeF +
                                  " - " +
                                  Months().getMonthShort(element.to.month)! +
                                  " " +
                                  element.to.day.toString() +
                                  ", " +
                                  timeT),
                            ),
                          );
                        } else {
                          secondLine = Center(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Text(Months()
                                  .getMonthShort(element.from.month)! +
                                  " " +
                                  element.from.day.toString() +
                                  ", " +
                                  element.from.year.toString() +
                                  ", " +
                                  timeF +
                                  " - " +
                                  Months().getMonthShort(element.to.month)! +
                                  " " +
                                  element.to.day.toString() +
                                  ", " +
                                  element.to.year.toString() +
                                  ", " +
                                  timeT),
                            ),
                          );
                        }
                        dayClicked.add(Column(
                          children: [firstLine, secondLine],));
                        deleteSearch.add(element);
                      }
                      );
                    } else {
                      dayClicked.add(const Text("No events today"));
                    }
                  }

                  int yearsPassed = 1;
                  if (pages > 12) {
                    temporaryM = (temporaryM % 12) + 1;
                  }
                  int userMonth = temporaryM;
                  temporaryM = pages;

                  var yearEarly = 1980;
                  yearsPassed = (pages / 12).floor();
                  int earlyYear = yearEarly + yearsPassed;
                  String monthIAmIn = n.currentMonth;
                  if (n.now.month == userMonth && n.now.year == earlyYear) {
                    monthView = n;
                  } else {
                    monthView = Months.otherYears(userMonth, earlyYear);
                  }
                  int mdw = monthView.monthStart;
                  if (monthView.monthStart == 7) {
                    mdw = 0;
                  }
                  monthIAmIn = n.month[userMonth].toString();

                  String year = (yearEarly + yearsPassed).toString();

                  if (getCurrentYear().toString() == year) {
                    year = "";
                  }
                  Color clickedColor = Colors.white70;
                  pageController.addListener(() {
                    clickedPosition = -2;
                  });
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Center(
                            child: InkWell(
                              child: Container(
                                padding:
                                const EdgeInsets.only(bottom: 16, top: 10),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    monthIAmIn + ' ' + year,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25),
                                  ),
                                ),
                              ),
                              onTap: () {
                                onYearPressed(context, pageController);
                              },
                              borderRadius: BorderRadius.circular(200),
                            ),
                          ),
                          Padding(
                            child: InkWell(
                              onTap: () => onFindMyDayPressed(),
                              splashColor: Colors.red[400]!,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border: Border.all(color: Colors.red[400]!),
                                  shape: BoxShape.circle,
                                ),
                                height: 25.0,
                                width: 25.0,
                                child: Center(
                                  child: Text(CalendarState()
                                      .getCurrentDay()
                                      .toString()),
                                ),
                              ),
                            ),
                            padding:
                            const EdgeInsets.only(left: 120, right: 15),
                          ),
                        ],
                        //mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: const [
                            Text(
                              "Sun",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text("Mon",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            Text("Tues",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            Text("Wed",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            Text("Thur",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            Text("Fri",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            Text("Sat",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold))
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        //Builds grid of days based on number of days in month
                        child: GridView.builder(
                            itemCount: monthView.daysInMonth + mdw,
                            scrollDirection: Axis.vertical,
                            physics: const ScrollPhysics(),
                            gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              childAspectRatio: 1 / 1.1,
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              index += 1;
                              int day;
                              bool skip = false;
                              if (mdw != 0) {
                                day = index - monthView.monthStart;
                              } else {
                                day = index;
                                skip = true;
                              }
                              Color textColor;
                              Widget textStyleToday = Text((day).toString());

                              if ((day) == monthView.now.day &&
                                  monthView.now.month == n.now.month &&
                                  monthView.now.year == n.now.year) {
                                textColor = Colors.white;
                                textStyleToday = CircleAvatar(
                                  backgroundColor: Colors.red[400]!,
                                  child: Text(
                                    day.toString(),
                                    style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  maxRadius: 12,
                                );
                              }
                              if (clickedPosition == day) {
                                clickedColor = Colors.red[200]!;
                              } else {
                                clickedColor = Colors.white70;
                              }

                              int dayLetters = index - 1;

                              if (index <= monthView.monthStart && !skip) {
                                Color colorCard;
                                if (darkMode) {
                                  colorCard = Colors.black;
                                } else {
                                  colorCard = Colors.white;
                                }

                                return Card(
                                  color: colorCard,
                                  elevation: 0,
                                );
                              } else {
                                if (dayLetters >= 7) {
                                  dayLetters = (dayLetters % 7);
                                }
                                String dayString = day.toString();
                                String monthString = userMonth.toString();
                                if (day <= 9) {
                                  dayString = "0" + day.toString();
                                }
                                if (userMonth <= 9) {
                                  monthString = "0" + userMonth.toString();
                                }
                                var todayE = globals.eventsList[dayString +
                                    monthString +
                                    (yearEarly + yearsPassed).toString()];
                                List<Widget> dayInfo = [];
                                dayInfo.add(textStyleToday);
                                if (todayE != null) {
                                  for (var element in todayE) {
                                    if (element.to
                                        .difference(element.from)
                                        .inDays != 0) {
                                      for (int i = 0; i <= element.to.difference(element.from).inDays; i++) {
                                        int dayCalc = element.from.day + i;
                                        int month = element.from.month;
                                        int yearCalc = element.from.year;

                                        if (dayCalc >
                                            DateTime(element.from.year,
                                                element.from.month + 1, 0)
                                                .day) {
                                          dayCalc = 1;
                                          month += 1;
                                        }
                                        if (month > 12) {
                                          if (month % 12 == 0) {
                                            yearCalc += month ~/ 12;
                                          }
                                          month = 1;
                                        }
                                        span[(dayCalc.toString() + month.toString() + yearCalc.toString())] = element;
                                      }
                                    }
                                    else {
                                      dayInfo.add(Container(
                                        padding:
                                        const EdgeInsets.only(top: 10),
                                        decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            color: element.color),
                                        height: 2,
                                        width: 40,
                                      ));
                                    }
                                  }
                                }
                                if (span.isNotEmpty) {
                                  if (span[day.toString() + userMonth.toString() + (yearEarly + yearsPassed).toString()] != null) {
                                    dayInfo.add(Container(
                                      padding:
                                      const EdgeInsets.only(top: 10),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          color: span[day.toString() + userMonth.toString() + (yearEarly + yearsPassed).toString()]?.color),
                                      height: 2,
                                      width: 40,
                                    ));
                                  }
                                }

                                if (globals.everyDay.isNotEmpty) {
                                  for (var element in globals.everyDay) {
                                    if (temporaryM >= element.page) {
                                      if (element.from.year ==
                                          (yearsPassed + yearEarly) &&
                                          element.from.month == userMonth) {
                                        if (day >= element.from.day) {
                                          dayInfo.add(Container(
                                            padding:
                                            const EdgeInsets.only(top: 10),
                                            decoration: BoxDecoration(
                                                shape: BoxShape.rectangle,
                                                color: element.color),
                                            height: 2,
                                            width: 40,
                                          ));
                                        }
                                      } else {
                                        dayInfo.add(Container(
                                          padding:
                                          const EdgeInsets.only(top: 10),
                                          decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              color: element.color),
                                          height: 2,
                                          width: 40,
                                        ));
                                      }
                                    }
                                  }
                                }
                                if (globals.everyWeek.isNotEmpty) {
                                  for (var element in globals.everyWeek) {
                                    if (temporaryM >= element.page) {
                                      DateTime weekDay = DateTime(
                                          yearEarly + yearsPassed,
                                          userMonth,
                                          day);
                                      if (element.to
                                          .difference(element.from)
                                          .inDays != 0) {
                                        for (int i = 0;
                                        i <=
                                            element.to
                                                .difference(element.from)
                                                .inDays;
                                        i++) {
                                          int dayCalc = element.from.day + i;
                                          int month = element.from.month;
                                          int yearCalc = element.from.year;

                                          if (dayCalc >
                                              DateTime(element.from.year,
                                                  element.from.month + 1, 0)
                                                  .day) {
                                            dayCalc = 1;
                                            month += 1;
                                          }
                                          if (month > 12) {
                                            if (month % 12 == 0) {
                                              yearCalc += month ~/ 12;
                                            }
                                            month = 1;
                                          }
                                          int dayOffset =
                                              DateTime(yearCalc, month, dayCalc)
                                                  .weekday;

                                          if (weekDay.weekday == dayOffset) {
                                            if (yearCalc ==
                                                (yearsPassed + yearEarly) &&
                                                month == userMonth) {
                                              if (day >= dayCalc) {
                                                dayInfo.add(Container(
                                                  padding:
                                                  const EdgeInsets.only(
                                                      top: 10),
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.rectangle,
                                                      color: element.color),
                                                  height: 2,
                                                  width: 40,
                                                ));
                                              }
                                            } else {
                                              dayInfo.add(Container(
                                                padding: const EdgeInsets.only(
                                                    top: 10),
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.rectangle,
                                                    color: element.color),
                                                height: 2,
                                                width: 40,
                                              ));
                                            }
                                          }
                                        }
                                      }
                                      else if (weekDay.weekday ==
                                          (element.from.weekday)) {
                                        if (element.from.year ==
                                            (yearsPassed + yearEarly) &&
                                            element.from.month == userMonth) {
                                          if (day >= element.from.day) {
                                            dayInfo.add(Container(
                                              padding: const EdgeInsets.only(
                                                  top: 10),
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.rectangle,
                                                  color: element.color),
                                              height: 2,
                                              width: 40,
                                            ));
                                          }
                                        } else {
                                          dayInfo.add(Container(
                                            padding:
                                            const EdgeInsets.only(top: 10),
                                            decoration: BoxDecoration(
                                                shape: BoxShape.rectangle,
                                                color: element.color),
                                            height: 2,
                                            width: 40,
                                          ));
                                        }
                                      }
                                    }
                                  }
                                }

                                if (globals.everyMonth.isNotEmpty) {
                                  for (var element in globals.everyMonth) {
                                    if (element.to
                                        .difference(element.from)
                                        .inDays !=
                                        0) {
                                      for (int i = 0;
                                      i <=
                                          element.to
                                              .difference(element.from)
                                              .inDays;
                                      i++) {
                                        int dayCalc = element.from.day + i;
                                        int monthCalc = element.from.month;

                                        if (dayCalc >
                                            DateTime(element.from.year,
                                                element.from.month + 1, 0)
                                                .day) {
                                          dayCalc = 1;
                                          monthCalc += 1;
                                        }
                                        if (monthCalc > 12) {
                                          monthCalc = 1;
                                        }
                                        if (day == dayCalc) {
                                          if (temporaryM >= element.page) {
                                            dayInfo.add(Container(
                                              padding: const EdgeInsets.only(
                                                  top: 10),
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.rectangle,
                                                  color: element.color),
                                              height: 2,
                                              width: 40,
                                            ));
                                          }
                                        }
                                      }
                                    }
                                    else {
                                      if (day == element.from.day) {
                                        if (temporaryM >= element.page) {
                                          dayInfo.add(Container(
                                            padding:
                                            const EdgeInsets.only(top: 10),
                                            decoration: BoxDecoration(
                                                shape: BoxShape.rectangle,
                                                color: element.color),
                                            height: 2,
                                            width: 40,
                                          ));
                                        }
                                      }
                                    }
                                  }
                                }
                                if (globals.everyYear.isNotEmpty) {
                                  for (var element in globals.everyYear) {
                                    if (element.to
                                        .difference(element.from)
                                        .inDays !=
                                        0) {
                                      for (int i = 0;
                                      i <=
                                          element.to
                                              .difference(element.from)
                                              .inDays;
                                      i++) {
                                        int dayCalc = element.from.day + i;
                                        int month = element.from.month;

                                        if (dayCalc >
                                            DateTime(element.from.year,
                                                element.from.month + 1, 0)
                                                .day) {
                                          dayCalc = 1;
                                          month += 1;
                                        }
                                        if (month > 12) {
                                          month = 1;
                                        }

                                        if (day == dayCalc &&
                                            userMonth == month) {
                                          if (temporaryM >= element.page) {
                                            dayInfo.add(Container(
                                              padding: const EdgeInsets.only(
                                                  top: 10),
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.rectangle,
                                                  color: element.color),
                                              height: 2,
                                              width: 40,
                                            ));
                                          }
                                        }
                                      }
                                    } else {
                                      if (day == element.from.day &&
                                          userMonth == element.from.month) {
                                        if (temporaryM >= element.page) {
                                          dayInfo.add(Container(
                                            padding:
                                            const EdgeInsets.only(top: 10),
                                            decoration: BoxDecoration(
                                                shape: BoxShape.rectangle,
                                                color: element.color),
                                            height: 2,
                                            width: 40,
                                          ));
                                        }
                                      }
                                    }
                                  }
                                }

                                return SizedBox(
                                  height: 200,
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: clickedColor, width: 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(50),
                                      splashColor: Colors.deepOrangeAccent,
                                      child: Align(
                                        alignment: Alignment.topCenter,
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                          children: dayInfo,
                                        ),
                                      ),
                                      onTap: () =>
                                          _tapDate(
                                              day,
                                              yearEarly + yearsPassed,
                                              userMonth,
                                              temporaryM),
                                    ),
                                  ),
                                );
                              }
                            }),
                      ),
                      Expanded(
                          flex: 1,
                          child: ListView.builder(
                            itemCount: dayClicked.length,
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                  onTap: () {
                                    if (deleteSearch[index].type ==
                                        "assignment") {}
                                  },
                                  onLongPress: () {
                                    showDialog<void>(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            AlertDialog(
                                              title: const Text(
                                                  'Delete event?'),
                                              content: const Text(
                                                  'Can\'t be undone'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    String d = deleteSearch[index]
                                                        .from.day.toString();
                                                    String m = deleteSearch[index]
                                                        .from.month.toString();
                                                    String y = deleteSearch[index]
                                                        .from.year.toString();
                                                    print(deleteSearch[index]
                                                        .title);
                                                    print(
                                                        deleteSearch[index].from
                                                            .day);
                                                    print("In long press");

                                                    if (deleteSearch[index].to
                                                        .difference(
                                                        deleteSearch[index]
                                                            .from)
                                                        .inDays != 0) {
                                                      //print("i am here");
                                                      //print(deleteSearch[index].from.difference(deleteSearch[index].to).inDays);
                                                      for (int j = 0; j <=
                                                          deleteSearch[index].to
                                                              .difference(
                                                              deleteSearch[index]
                                                                  .from)
                                                              .inDays; j++) {
                                                        d = (deleteSearch[index]
                                                            .from.day + j)
                                                            .toString();

                                                        if (int.parse(d) <= 9) {
                                                          d = "0" + d;
                                                        }
                                                        if (int.parse(m) <= 9) {
                                                          m = "0" + m;
                                                        }
                                                        //print(d);
                                                        for (int i = 0; i <
                                                            (globals
                                                                .eventsList[d +
                                                                m + y]
                                                                ?.length)!; i++) {
                                                          //print(globals.eventsList[d + m + y]?.length);


                                                          if (globals
                                                              .eventsList[d +
                                                              m + y]
                                                              ?.elementAt(i)
                                                              .to
                                                              .day ==
                                                              deleteSearch[index]
                                                                  .to.day &&
                                                              globals
                                                                  .eventsList[d +
                                                                  m + y]
                                                                  ?.elementAt(i)
                                                                  .to
                                                                  .month ==
                                                                  deleteSearch[index]
                                                                      .to
                                                                      .month &&
                                                              globals
                                                                  .eventsList[d +
                                                                  m + y]
                                                                  ?.elementAt(i)
                                                                  .to
                                                                  .year ==
                                                                  deleteSearch[index]
                                                                      .to
                                                                      .year &&
                                                              globals
                                                                  .eventsList[d +
                                                                  m + y]
                                                                  ?.elementAt(i)
                                                                  .to
                                                                  .hour ==
                                                                  deleteSearch[index]
                                                                      .to
                                                                      .hour &&
                                                              globals
                                                                  .eventsList[d +
                                                                  m + y]
                                                                  ?.elementAt(i)
                                                                  .to
                                                                  .minute ==
                                                                  deleteSearch[index]
                                                                      .to
                                                                      .minute &&
                                                              globals
                                                                  .eventsList[d +
                                                                  m + y]
                                                                  ?.elementAt(i)
                                                                  .from
                                                                  .day ==
                                                                  deleteSearch[index]
                                                                      .from
                                                                      .day &&
                                                              globals
                                                                  .eventsList[d +
                                                                  m + y]
                                                                  ?.elementAt(i)
                                                                  .from
                                                                  .minute ==
                                                                  deleteSearch[index]
                                                                      .from
                                                                      .minute &&
                                                              globals
                                                                  .eventsList[d +
                                                                  m + y]
                                                                  ?.elementAt(i)
                                                                  .from
                                                                  .year ==
                                                                  deleteSearch[index]
                                                                      .from
                                                                      .year &&
                                                              globals
                                                                  .eventsList[d +
                                                                  m + y]
                                                                  ?.elementAt(i)
                                                                  .from
                                                                  .month ==
                                                                  deleteSearch[index]
                                                                      .from
                                                                      .month &&
                                                              globals
                                                                  .eventsList[d +
                                                                  m + y]
                                                                  ?.elementAt(i)
                                                                  .from
                                                                  .hour ==
                                                                  deleteSearch[index]
                                                                      .from
                                                                      .hour &&
                                                              globals
                                                                  .eventsList[d +
                                                                  m + y]
                                                                  ?.elementAt(i)
                                                                  .type ==
                                                                  deleteSearch[index]
                                                                      .type &&
                                                              globals
                                                                  .eventsList[d +
                                                                  m + y]
                                                                  ?.elementAt(i)
                                                                  .allDay ==
                                                                  deleteSearch[index]
                                                                      .allDay &&
                                                              globals
                                                                  .eventsList[d +
                                                                  m + y]
                                                                  ?.elementAt(i)
                                                                  .page ==
                                                                  deleteSearch[index]
                                                                      .page &&
                                                              globals
                                                                  .eventsList[d +
                                                                  m + y]
                                                                  ?.elementAt(i)
                                                                  .title ==
                                                                  deleteSearch[index]
                                                                      .title
                                                          ) {
                                                            globals
                                                                .eventsList[d +
                                                                m + y]
                                                                ?.removeAt(i);
                                                            print("hm");
                                                          }
                                                        }
                                                      }
                                                      _tapDate(
                                                          deleteSearch[index]
                                                              .from.day,
                                                          deleteSearch[index]
                                                              .from.year,
                                                          deleteSearch[index]
                                                              .from.month, pag);
                                                    }
                                                    else {
                                                      if (int.parse(d) <= 9) {
                                                        d = "0" + d;
                                                      }
                                                      if (int.parse(m) <= 9) {
                                                        m = "0" + m;
                                                      }
                                                      for (int i = 0; i <
                                                          (globals
                                                              .eventsList[d +
                                                              m + y]
                                                              ?.length)!; i++) {
                                                        if (globals
                                                            .eventsList[d + m +
                                                            y]
                                                            ?.elementAt(i)
                                                            .to
                                                            .day ==
                                                            deleteSearch[index]
                                                                .to.day &&
                                                            globals
                                                                .eventsList[d +
                                                                m + y]
                                                                ?.elementAt(i)
                                                                .to
                                                                .month ==
                                                                deleteSearch[index]
                                                                    .to.month &&
                                                            globals
                                                                .eventsList[d +
                                                                m + y]
                                                                ?.elementAt(i)
                                                                .to
                                                                .year ==
                                                                deleteSearch[index]
                                                                    .to.year &&
                                                            globals
                                                                .eventsList[d +
                                                                m + y]
                                                                ?.elementAt(i)
                                                                .to
                                                                .hour ==
                                                                deleteSearch[index]
                                                                    .to.hour &&
                                                            globals
                                                                .eventsList[d +
                                                                m + y]
                                                                ?.elementAt(i)
                                                                .to
                                                                .minute ==
                                                                deleteSearch[index]
                                                                    .to
                                                                    .minute &&
                                                            globals
                                                                .eventsList[d +
                                                                m + y]
                                                                ?.elementAt(i)
                                                                .from
                                                                .day ==
                                                                deleteSearch[index]
                                                                    .from.day &&
                                                            globals
                                                                .eventsList[d +
                                                                m + y]
                                                                ?.elementAt(i)
                                                                .from
                                                                .minute ==
                                                                deleteSearch[index]
                                                                    .from
                                                                    .minute &&
                                                            globals
                                                                .eventsList[d +
                                                                m + y]
                                                                ?.elementAt(i)
                                                                .from
                                                                .year ==
                                                                deleteSearch[index]
                                                                    .from
                                                                    .year &&
                                                            globals
                                                                .eventsList[d +
                                                                m + y]
                                                                ?.elementAt(i)
                                                                .from
                                                                .month ==
                                                                deleteSearch[index]
                                                                    .from
                                                                    .month &&
                                                            globals
                                                                .eventsList[d +
                                                                m + y]
                                                                ?.elementAt(i)
                                                                .from
                                                                .hour ==
                                                                deleteSearch[index]
                                                                    .from
                                                                    .hour &&
                                                            globals
                                                                .eventsList[d +
                                                                m + y]
                                                                ?.elementAt(i)
                                                                .type ==
                                                                deleteSearch[index]
                                                                    .type &&
                                                            globals
                                                                .eventsList[d +
                                                                m + y]
                                                                ?.elementAt(i)
                                                                .allDay ==
                                                                deleteSearch[index]
                                                                    .allDay &&
                                                            globals
                                                                .eventsList[d +
                                                                m + y]
                                                                ?.elementAt(i)
                                                                .page ==
                                                                deleteSearch[index]
                                                                    .page &&
                                                            globals
                                                                .eventsList[d +
                                                                m + y]
                                                                ?.elementAt(i)
                                                                .title ==
                                                                deleteSearch[index]
                                                                    .title
                                                        ) {
                                                          globals.eventsList[d +
                                                              m + y]?.removeAt(
                                                              i);
                                                        }
                                                      }
                                                      if (globals.projects
                                                          .isNotEmpty) {
                                                        for (int i = 0; i <
                                                            globals.projects
                                                                .length; i++) {
                                                          if (globals.projects
                                                              .elementAt(i)
                                                              .to
                                                              .day ==
                                                              deleteSearch[index]
                                                                  .to.day &&
                                                              globals.projects
                                                                  .elementAt(i)
                                                                  .to
                                                                  .month ==
                                                                  deleteSearch[index]
                                                                      .to
                                                                      .month &&
                                                              globals.projects
                                                                  .elementAt(i)
                                                                  .to
                                                                  .year ==
                                                                  deleteSearch[index]
                                                                      .to
                                                                      .year &&
                                                              globals.projects
                                                                  .elementAt(i)
                                                                  .to
                                                                  .hour ==
                                                                  deleteSearch[index]
                                                                      .to
                                                                      .hour &&
                                                              globals.projects
                                                                  .elementAt(i)
                                                                  .to
                                                                  .minute ==
                                                                  deleteSearch[index]
                                                                      .to
                                                                      .minute &&
                                                              globals.projects
                                                                  .elementAt(i)
                                                                  .from
                                                                  .day ==
                                                                  deleteSearch[index]
                                                                      .from
                                                                      .day &&
                                                              globals.projects
                                                                  .elementAt(i)
                                                                  .from
                                                                  .minute ==
                                                                  deleteSearch[index]
                                                                      .from
                                                                      .minute &&
                                                              globals.projects
                                                                  .elementAt(i)
                                                                  .from
                                                                  .year ==
                                                                  deleteSearch[index]
                                                                      .from
                                                                      .year &&
                                                              globals.projects
                                                                  .elementAt(i)
                                                                  .from
                                                                  .month ==
                                                                  deleteSearch[index]
                                                                      .from
                                                                      .month &&
                                                              globals.projects
                                                                  .elementAt(i)
                                                                  .from
                                                                  .hour ==
                                                                  deleteSearch[index]
                                                                      .from
                                                                      .hour &&
                                                              globals.projects
                                                                  .elementAt(i)
                                                                  .type ==
                                                                  deleteSearch[index]
                                                                      .type &&
                                                              globals.projects
                                                                  .elementAt(i)
                                                                  .allDay ==
                                                                  deleteSearch[index]
                                                                      .allDay &&
                                                              globals.projects
                                                                  .elementAt(i)
                                                                  .page ==
                                                                  deleteSearch[index]
                                                                      .page &&
                                                              globals.projects
                                                                  .elementAt(i)
                                                                  .title ==
                                                                  deleteSearch[index]
                                                                      .title
                                                          ) {
                                                            globals.projects
                                                                .removeAt(i);
                                                          }
                                                        }
                                                      }
                                                      if (globals.exams
                                                          .isNotEmpty) {
                                                        for (int i = 0; i <
                                                            globals.exams
                                                                .length; i++) {
                                                          if (globals.exams
                                                              .elementAt(i)
                                                              .to
                                                              .day ==
                                                              deleteSearch[index]
                                                                  .to.day &&
                                                              globals.exams
                                                                  .elementAt(i)
                                                                  .to
                                                                  .month ==
                                                                  deleteSearch[index]
                                                                      .to
                                                                      .month &&
                                                              globals.exams
                                                                  .elementAt(i)
                                                                  .to
                                                                  .year ==
                                                                  deleteSearch[index]
                                                                      .to
                                                                      .year &&
                                                              globals.exams
                                                                  .elementAt(i)
                                                                  .to
                                                                  .hour ==
                                                                  deleteSearch[index]
                                                                      .to
                                                                      .hour &&
                                                              globals.exams
                                                                  .elementAt(i)
                                                                  .to
                                                                  .minute ==
                                                                  deleteSearch[index]
                                                                      .to
                                                                      .minute &&
                                                              globals.exams
                                                                  .elementAt(i)
                                                                  .from
                                                                  .day ==
                                                                  deleteSearch[index]
                                                                      .from
                                                                      .day &&
                                                              globals.exams
                                                                  .elementAt(i)
                                                                  .from
                                                                  .minute ==
                                                                  deleteSearch[index]
                                                                      .from
                                                                      .minute &&
                                                              globals.exams
                                                                  .elementAt(i)
                                                                  .from
                                                                  .year ==
                                                                  deleteSearch[index]
                                                                      .from
                                                                      .year &&
                                                              globals.exams
                                                                  .elementAt(i)
                                                                  .from
                                                                  .month ==
                                                                  deleteSearch[index]
                                                                      .from
                                                                      .month &&
                                                              globals.exams
                                                                  .elementAt(i)
                                                                  .from
                                                                  .hour ==
                                                                  deleteSearch[index]
                                                                      .from
                                                                      .hour &&
                                                              globals.exams
                                                                  .elementAt(i)
                                                                  .type ==
                                                                  deleteSearch[index]
                                                                      .type &&
                                                              globals.exams
                                                                  .elementAt(i)
                                                                  .allDay ==
                                                                  deleteSearch[index]
                                                                      .allDay &&
                                                              globals.exams
                                                                  .elementAt(i)
                                                                  .page ==
                                                                  deleteSearch[index]
                                                                      .page &&
                                                              globals.exams
                                                                  .elementAt(i)
                                                                  .title ==
                                                                  deleteSearch[index]
                                                                      .title
                                                          ) {
                                                            globals.exams
                                                                .removeAt(i);
                                                          }
                                                        }
                                                      }
                                                      if (globals.assignments
                                                          .isNotEmpty) {
                                                        for (int i = 0; i <
                                                            globals.assignments
                                                                .length; i++) {
                                                          if (globals
                                                              .assignments
                                                              .elementAt(i)
                                                              .to
                                                              .day ==
                                                              deleteSearch[index]
                                                                  .to.day &&
                                                              globals
                                                                  .assignments
                                                                  .elementAt(i)
                                                                  .to
                                                                  .month ==
                                                                  deleteSearch[index]
                                                                      .to
                                                                      .month &&
                                                              globals
                                                                  .assignments
                                                                  .elementAt(i)
                                                                  .to
                                                                  .year ==
                                                                  deleteSearch[index]
                                                                      .to
                                                                      .year &&
                                                              globals
                                                                  .assignments
                                                                  .elementAt(i)
                                                                  .to
                                                                  .hour ==
                                                                  deleteSearch[index]
                                                                      .to
                                                                      .hour &&
                                                              globals
                                                                  .assignments
                                                                  .elementAt(i)
                                                                  .to
                                                                  .minute ==
                                                                  deleteSearch[index]
                                                                      .to
                                                                      .minute &&
                                                              globals
                                                                  .assignments
                                                                  .elementAt(i)
                                                                  .from
                                                                  .day ==
                                                                  deleteSearch[index]
                                                                      .from
                                                                      .day &&
                                                              globals
                                                                  .assignments
                                                                  .elementAt(i)
                                                                  .from
                                                                  .minute ==
                                                                  deleteSearch[index]
                                                                      .from
                                                                      .minute &&
                                                              globals
                                                                  .assignments
                                                                  .elementAt(i)
                                                                  .from
                                                                  .year ==
                                                                  deleteSearch[index]
                                                                      .from
                                                                      .year &&
                                                              globals
                                                                  .assignments
                                                                  .elementAt(i)
                                                                  .from
                                                                  .month ==
                                                                  deleteSearch[index]
                                                                      .from
                                                                      .month &&
                                                              globals
                                                                  .assignments
                                                                  .elementAt(i)
                                                                  .from
                                                                  .hour ==
                                                                  deleteSearch[index]
                                                                      .from
                                                                      .hour &&
                                                              globals
                                                                  .assignments
                                                                  .elementAt(i)
                                                                  .type ==
                                                                  deleteSearch[index]
                                                                      .type &&
                                                              globals
                                                                  .assignments
                                                                  .elementAt(i)
                                                                  .allDay ==
                                                                  deleteSearch[index]
                                                                      .allDay &&
                                                              globals
                                                                  .assignments
                                                                  .elementAt(i)
                                                                  .page ==
                                                                  deleteSearch[index]
                                                                      .page &&
                                                              globals
                                                                  .assignments
                                                                  .elementAt(i)
                                                                  .title ==
                                                                  deleteSearch[index]
                                                                      .title
                                                          ) {
                                                            globals.assignments
                                                                .removeAt(i);
                                                          }
                                                        }
                                                      }
                                                      _tapDate(
                                                          deleteSearch[index]
                                                              .from.day,
                                                          deleteSearch[index]
                                                              .from.year,
                                                          deleteSearch[index]
                                                              .from.month, pag);
                                                    }
                                                    globals.timestamp = DateTime.now();
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            ));
                                  },
                                  child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        dayClicked[index],
                                      ]));
                            },
                            //children: [
                            //Column(
                            //children: dayClicked,
                            //),
                            //],
                          )),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _tapDate(int day, int year, int month, int page) {
    dayClicked.clear();
    deleteSearch.clear();
    setState(() {
      clickedPosition = day;
    });

    List<Events> temp;
    String dayString = day.toString();
    String monthString = month.toString();
    if (day <= 9) {
      dayString = "0" + day.toString();
    }
    if (month <= 9) {
      monthString = "0" + month.toString();
    }
    if (globals
        .eventsList[dayString + monthString + year.toString()] !=
        null) {
      temp = (globals
          .eventsList[day.toString() + monthString + year.toString()])!;
    } else {
      temp = [];
    }
    if (globals.everyDay.isNotEmpty) {
      for (var element in globals.everyDay) {
        if (page >= element.page) {
          if (element.from.year == year && element.from.month == month) {
            if (day >= element.from.day) {
              temp.add(element);
            }
          } else {
            temp.add(element);
          }
        }
      }
    }
    if (globals.everyWeek.isNotEmpty) {
      for (var element in globals.everyWeek) {
        DateTime weekDay = DateTime(year, month, day);
        if (element.to
            .difference(element.from)
            .inDays != 0) {
          for (int i = 0;
          i <= element.to
              .difference(element.from)
              .inDays;
          i++) {
            int dayCalc = element.from.day + i;
            int monthCalc = element.from.month;
            int yearCalc = element.from.year;

            if (dayCalc >
                DateTime(element.from.year, element.from.month + 1, 0).day) {
              dayCalc = 1;
              monthCalc += 1;
            }
            if (monthCalc > 12) {
              if (month % 12 == 0) {
                yearCalc += month ~/ 12;
              }
              monthCalc = 1;
            }
            int dayOffset = DateTime(yearCalc, monthCalc, dayCalc).weekday;
            if (weekDay.weekday == dayOffset) {
              if (page >= element.page) {
                if (yearCalc == year && month == monthCalc) {
                  if (day >= dayCalc) {
                    temp.add(element);
                  }
                } else {
                  temp.add(element);
                }
              }
            }
          }
        } else {
          if (weekDay.weekday == (element.from.weekday)) {
            if (page >= element.page) {
              if (element.from.year == year && element.from.month == month) {
                if (day >= element.from.day) {
                  temp.add(element);
                }
              } else {
                temp.add(element);
              }
            }
          }
        }
      }
    }
    if (globals.everyMonth.isNotEmpty) {
      for (var element in globals.everyMonth) {
        if (element.to
            .difference(element.from)
            .inDays != 0) {
          for (int i = 0;
          i <= element.to
              .difference(element.from)
              .inDays;
          i++) {
            int dayCalc = element.from.day + i;
            int monthCalc = element.from.month;
            int yearCalc = element.from.year;

            if (dayCalc >
                DateTime(element.from.year, element.from.month + 1, 0).day) {
              dayCalc = 1;
              monthCalc += 1;
            }
            if (monthCalc > 12) {
              if (month % 12 == 0) {
                yearCalc += month ~/ 12;
              }
              monthCalc = 1;
            }
            if (day == dayCalc) {
              if (page >= element.page) {
                if (yearCalc == year && monthCalc == month) {
                  if (day >= element.from.day) {
                    temp.add(element);
                  }
                } else {
                  temp.add(element);
                }
              }
            }
          }
        } else {
          if (day == element.from.day) {
            if (page >= element.page) {
              if (element.from.year == year && element.from.month == month) {
                if (day >= element.from.day) {
                  temp.add(element);
                }
              } else {
                temp.add(element);
              }
            }
          }
        }
      }
    }
    if (globals.everyYear.isNotEmpty) {
      for (var element in globals.everyYear) {
        if (element.to
            .difference(element.from)
            .inDays != 0) {
          for (int i = 0;
          i <= element.to
              .difference(element.from)
              .inDays;
          i++) {
            int dayCalc = element.from.day + i;
            int monthCalc = element.from.month;
            int yearCalc = element.from.year;

            if (dayCalc >
                DateTime(element.from.year, element.from.month + 1, 0).day) {
              dayCalc = 1;
              month += 1;
            }
            if (month > 12) {
              if (month % 12 == 0) {
                yearCalc += month ~/ 12;
              }
              month = 1;
            }
            if (day == dayCalc && month == monthCalc) {
              if (page >= element.page) {
                if (yearCalc == year && monthCalc == month) {
                  if (day >= element.from.day) {
                    temp.add(element);
                  }
                } else {
                  temp.add(element);
                }
              }
            }
          }
        } else {
          if (day == element.from.day && month == element.from.month) {
            if (page >= element.page) {
              if (element.from.year == year && element.from.month == month) {
                if (day >= element.from.day) {
                  temp.add(element);
                }
              } else {
                temp.add(element);
              }
            }
          }
        }
      }
    }
    Widget firstLine = Spacer();
    Widget secondLine = Spacer();

    if (span.isNotEmpty) {
      if (span[day.toString() + month.toString() + year.toString()] != null) {
        if (span[day.toString() + month.toString() + year.toString()]?.from.day != day) {
          temp.add((span[day.toString() + month.toString() + year.toString()])!);
        }
      }
    }


    if (temp.isNotEmpty) {
      for (var element in temp) {
        firstLine = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle, color: element.color),
              height: 15,
              width: 2,
            ),
            const Padding(padding: EdgeInsets.only(right: 10)),
            Text(
              element.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        );
        String timeF =
        TimeOfDay(hour: element.from.hour, minute: element.from.minute)
            .format(context);
        String timeT =
        TimeOfDay(hour: element.to.hour, minute: element.to.minute)
            .format(context);
        if (element.from.day == element.to.day &&
            element.from.month == element.to.month &&
            element.from.year == element.to.year) {
          if (element.allDay) {
            secondLine = const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text("All day"),
              ),
            );
          } else {
            secondLine = Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(timeF + " - " + timeT),
              ),
            );
          }
        }
        else if (element.from.year == element.to.year) {
          if (element.allDay) {
            secondLine = Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(Months().getMonthShort(element.from.month)! +
                    " " +
                    element.from.month.toString() +
                    " - " +
                    Months().getMonthShort(element.to.month)! +
                    " " +
                    element.to.month.toString()),
              ),
            );
          } else {
            secondLine = Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(Months().getMonthShort(element.from.month)! +
                    " " +
                    element.from.day.toString() +
                    ", " +
                    timeF +
                    " - " +
                    Months().getMonthShort(element.to.month)! +
                    " " +
                    element.to.day.toString() +
                    ", " +
                    timeT),
              ),
            );
          }
        } else {
          if (element.allDay) {
            secondLine = Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(Months().getMonthShort(element.from.month)! +
                    " " +
                    element.from.day.toString() +
                    ", " +
                    element.from.year.toString() +
                    " - " +
                    Months().getMonthShort(element.to.month)! +
                    " " +
                    element.to.day.toString() +
                    ", " +
                    element.to.year.toString()),
              ),
            );
          } else {
            secondLine = Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(Months().getMonthShort(element.from.month)! +
                    " " +
                    element.from.day.toString() +
                    ", " +
                    element.from.year.toString() +
                    ", " +
                    timeF +
                    " - " +
                    Months().getMonthShort(element.to.month)! +
                    " " +
                    element.to.day.toString() +
                    ", " +
                    element.to.day.toString() +
                    ", " +
                    timeT),
              ),
            );
          }
        }
        dayClicked.add(Column(
          children: [firstLine, secondLine],
        ));
        deleteSearch.add(element);
      }
    } else {
      dayClicked.add(const Center(child: Text("No events today")));
    }

    final access = StateWidget.of(context);
    access?.updateClicked(day, year, month);
  }


  void navigationPress(int month, int year, BuildContext context) {
    Navigator.pop(context);
    pageController.animateToPage(year * 12 + month,
        duration: const Duration(seconds: 1), curve: Curves.easeIn);
  }

  int getCurrentMonth() {
    return n.now.month;
  }

  int getCurrentDay() {
    return n.now.day;
  }

  int getCurrentYear() {
    return n.now.year;
  }

  int getClicked() {
    return clickedPosition;
  }

  void onYearPressed(BuildContext context, PageController pageController) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: Colors.black,
      builder: (BuildContext context) {
        return SizedBox(
          child: selectMonth(context, pageController),
          height: 200,
          width: 200,
        );
      },
    );
  }

  void onFindMyDayPressed() {
    if (pageController.hasClients) {
      pageController.animateToPage(
          ((getCurrentYear() - 1980) * 12 + getCurrentMonth()) - 1,
          duration: const Duration(seconds: 2),
          curve: Curves.easeIn);
    }
  }

  Widget selectMonth(BuildContext context, PageController pageController) {
    int equation = getCurrentYear() - 1980;

    PageController selectionController = PageController(
      initialPage: equation,
    );
    return PageView.builder(
        scrollDirection: Axis.horizontal,
        controller: selectionController,
        itemBuilder: (BuildContext context, int year) {
          var displayYear = (1980 + year).toString();
          display = displayYear;
          return Column(
            children: [
              InkWell(
                child: Text(
                  display,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  var firstYearRange = 1980 + ((year / 12).floor() * 12);
                  setState(() {
                    display = (firstYearRange.toString() +
                        "-" +
                        (firstYearRange + 12).toString());
                    //print(display);
                  });
                },
              ),
              Expanded(
                  child: GridView.builder(
                    itemCount: 12,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                    ),
                    itemBuilder: (BuildContext context, int month) {
                      Color monthName;
                      if (month + 1 == getCurrentMonth() &&
                          year == getCurrentYear() - 1980) {
                        monthName = Colors.red[200]!;
                      } else {
                        monthName = Colors.grey[800]!;
                      }
                      return Container(
                        padding: const EdgeInsets.all(5),
                        child: ElevatedButton(
                          child: Text(
                            n.getMonthShort(month + 1).toString(),
                            style: const TextStyle(fontSize: 12),
                          ),
                          onPressed: () =>
                              navigationPress(month, year, context),
                          style: ElevatedButton.styleFrom(
                            primary: monthName,
                            side: const BorderSide(width: 1.0,
                                color: Colors.red),
                            shape: const CircleBorder(),
                          ),
                        ),
                      );
                    },
                  )),
            ],
          );
        });
  }

  void onAddEventButtonPressed() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return EventForm();
    }));
  }
}