import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:freibad_app/models/session.dart';
import 'package:freibad_app/models/appointment.dart';
import 'package:freibad_app/models/request.dart';
import 'package:freibad_app/provider/local_data.dart';

class SessionPresenter extends StatefulWidget {
  final Session session;
  final bool isAppointment;

  SessionPresenter(this.session) : isAppointment = session is Appointment {
    if (!isAppointment && !(session is Request)) {
      throw 'children of a Session should only be from an Appointment (class) or a Request (class), diffrent children might cause problem to the SessionPresenter';
    }
  }

  @override
  _SessionPresenterState createState() => _SessionPresenterState();
}

class _SessionPresenterState extends State<SessionPresenter> {
  List<Map<String, dynamic>> accessList = [];
  bool isInitState = true;

  @override
  void didChangeDependencies() {
    if (isInitState) {
      for (var i in widget.session.accessList) {
        accessList.add(
          {
            'person': Provider.of<LocalData>(context, listen: false)
                .findPersonById(i['person']),
            if (widget.isAppointment) 'code': i['code'],
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
          Provider.of<LocalData>(context, listen: false).deleteSession(widget.session),
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
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 120,
              child: Column(
                children: <Widget>[
                  Text(widget.session.id)
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
      backgroundColor: Theme.of(context).cardColor,
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
}
