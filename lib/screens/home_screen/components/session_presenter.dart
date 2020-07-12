import 'package:flutter/material.dart';
import 'package:freibad_app/models/person.dart';
import 'package:freibad_app/models/weather.dart';
import 'package:freibad_app/provider/session_data.dart';
import 'package:freibad_app/screens/home_screen/components/person_detail_dialog.dart';

import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:freibad_app/models/session.dart';
import 'package:freibad_app/models/appointment.dart';
import 'package:freibad_app/models/request.dart';

class SessionPresenter extends StatefulWidget {
  final Session session;
  final Weather weather;
  final bool isAppointment;

  SessionPresenter(this.session, this.weather)
      : isAppointment = session is Appointment {
    if (!isAppointment && !(session is Request)) {
      throw 'children of a Session should only be from an Appointment (class) or a Request (class), diffrent children might cause problems to the SessionPresenter';
    }
  }

  @override
  _SessionPresenterState createState() => _SessionPresenterState();
}

class _SessionPresenterState extends State<SessionPresenter> {
  List<Map<String, dynamic>> accessList = [];
  bool isInitState = true;
  String date;
  String startTime;
  String endTime;

  @override
  void initState() {
    date = DateFormat('EEEE, d LLLL').format(widget.session.startTime);
    startTime = DateFormat.Hm().format(widget.session.startTime);
    endTime = DateFormat.Hm().format(widget.session.endTime);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (isInitState) {
      for (Map<String, String> access in widget.session.accessList) {
        accessList.add(
          {
            'person': Provider.of<SessionData>(context, listen: false)
                .findPersonById(access['person']),
            if (widget.isAppointment) 'code': access['code'],
          },
        );
      }
      isInitState = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(widget.session.id),
      onDismissed: (direction) =>
          Provider.of<SessionData>(context, listen: false)
              .deleteSession(widget.session),
      confirmDismiss: (direction) => showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => buildAlertDialog(context),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 2, bottom: 2, left: 8, right: 8),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              height: 100,
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      showSessionStatus(28),
                      Text(
                        '$startTime to $endTime',
                        style: TextStyle(fontSize: 28),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text(
                            '$date',
                            style: TextStyle(fontSize: 14),
                          ),
                          widget.weather != null
                              ? Row(
                                  children: <Widget>[
                                    Icon(
                                      widget.weather.skyIcon,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    Text(
                                      '${widget.weather.maxTemp} ${widget.weather.tempUnit}',
                                      style: TextStyle(fontSize: 14),
                                    )
                                  ],
                                )
                              : Text(
                                  'No Weather Data',
                                  style: TextStyle(fontSize: 14),
                                ),
                        ],
                      ),
                    ],
                  ),
                  showAccessList(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  AlertDialog buildAlertDialog(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Text('Confirm'),
      content: Text('Do you want to remove this session?'),
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('No!'),
        ),
        FlatButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text('Yes!'),
        ),
      ],
    );
  }

  Icon showSessionStatus(double size) {
    if (widget.isAppointment)
      return Icon(
        Icons.done,
        color: Colors.green,
        size: size,
      );
    var tmpRequest = widget.session as Request;
    if (tmpRequest.hasFailed)
      return Icon(
        Icons.close,
        color: Colors.red,
        size: size,
      );
    else
      return Icon(
        Icons.access_time,
        color: Colors.yellow,
        size: size,
      );
  }

  Container showAccessList(BuildContext context) {
    List<Widget> accessListItems = widget.session.accessList
        .map((accessItem) => getAccessListItem(accessItem, context))
        .toList();
    return Container(
      padding: EdgeInsets.all(5),
      child: Wrap(children: accessListItems),
    );
  }

  Widget getAccessListItem(Map<String, dynamic> accessItem, context) {
    String personId = accessItem['person'];
    Person person = Provider.of<SessionData>(context, listen: false)
        .findPersonById(personId);
    bool hasCode = widget.isAppointment;
    String code;
    if (hasCode) code = accessItem['code'];

    return Padding(
      padding: EdgeInsets.only(left: 6, right: 6, top: 1, bottom: 1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => PersonDetailDialog(
                  personId: personId,
                ),
              );
            },
            child: Text(
              '${person.forename}',
              style: TextStyle(fontSize: 20),
            ),
          ),
          if (hasCode)
            GestureDetector(
              onTap: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  title: Text(code),
                  content: Text(
                      '${person.forename} ${person.name} has the code: $code'),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Ok!'),
                    ),
                  ],
                ),
              ),
              child: Text(
                ': $code',
                style: TextStyle(fontSize: 20),
              ),
            ),
        ],
      ),
    );
  }
}
