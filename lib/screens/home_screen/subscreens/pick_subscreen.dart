import 'package:flutter/material.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:freibad_app/services/api_service.dart';

class PickSubscreen extends StatefulWidget {
  @override
  _PickSubscreenState createState() => _PickSubscreenState();
}

class _PickSubscreenState extends State<PickSubscreen> {
  DateTime sessionDate;
  DateTime startTime;
  DateTime endTime;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          getDate(),
          getTime(sessionDate),
          //getPerson(),
          RaisedButton.icon(
            onPressed: () {
              print(sessionDate.toIso8601String());
            },
            icon: Icon(
              Icons.check,
              color: Colors.green,
            ),
            label: Text(
              'Submit',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  Widget getDate() {
    return DatePicker(
      DateTime.now(),
      onDateChange: (selectedDate) {
        setState(() {
          sessionDate = selectedDate;
        });
      },
      selectedTextColor: Theme.of(context).primaryColor,
      selectionColor: Theme.of(context).accentColor,
    );
  }

  Widget getTime(DateTime selectedDate) {
    if (selectedDate != null)
      return Column(
        children: ApiService.availableTimeBlocks(selectedDate)
            .map((e) => Container(child: Text(e[0].toIso8601String())))
            .toList(),
      );
    else
      return Container();
  }

  Widget getPerson() {
    return null;
  }
}
