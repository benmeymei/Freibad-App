import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:freibad_app/models/session.dart';
import 'package:freibad_app/provider/local_data.dart';

class SessionPresenter extends StatefulWidget {
  final Session session;

  SessionPresenter(this.session);

  @override
  _SessionPresenterState createState() => _SessionPresenterState();
}

class _SessionPresenterState extends State<SessionPresenter> {
  List<Map<String, dynamic>> personsAndCodes = [];
  bool isInitState = true;

  @override
  void didChangeDependencies() {
    if (isInitState) {
      for (var i in widget.session.personsAndCodes) {
        personsAndCodes.add(
          {
            'person': Provider.of<LocalData>(context, listen: false)
                .findPersonById(i['person']),
            'code': i['code'],
          },
        );
      }
      isInitState = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
