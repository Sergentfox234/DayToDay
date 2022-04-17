import 'package:flutter/material.dart';
import 'EventForm.dart';
import 'globals.dart' as globals;
import 'Events.dart';

class ExamsWidget extends StatefulWidget {
  List<Events> exams = [];
  ExamsWidget({Key? key}) : super(key: key);

  @override
  State<ExamsWidget> createState() => ExamsState();
}

class ExamsState extends State<ExamsWidget> {
  @override
  Widget build(BuildContext context) {
    widget.exams = [];
    globals.events.forEach((key, value) {
      for (int i = 0; i < value.length; i++) {
        if (value[i].type.contains("exam")) {
          widget.exams.add(value[i]);
        }
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Exams List")),
        backgroundColor: const Color.fromARGB(255, 255, 82, 82),
      ),
      body: ListView.builder(
        itemCount: widget.exams.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
              child: CheckboxListTile(
                  dense: true,
                  activeColor: Colors.red[400],
                  controlAffinity: ListTileControlAffinity.leading,
                  value: false,
                  onChanged: (value) {
                    setState(() {
                      widget.exams.removeAt(index);
                    });
                  },
                  title: Text(
                    widget.exams[index].title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color.fromARGB(255, 12, 12, 12)),
                  )));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            setState(() {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return EventForm();
              }));
            });
            setState(() {});
          });
        },
        child: const Icon(
          Icons.add,
          size: 45,
          color: Colors.white,
        ),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }
}