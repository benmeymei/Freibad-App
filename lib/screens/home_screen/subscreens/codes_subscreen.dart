import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:freibad_app/provider/data_manager.dart';
import 'package:freibad_app/models/session.dart';
import 'package:freibad_app/screens/home_screen/components/session_presenter.dart';

class CodesSubscreen extends StatefulWidget {
  @override
  _CodesSubscreenState createState() => _CodesSubscreenState();
}

class _CodesSubscreenState extends State<CodesSubscreen> {
  List<Session> sessions;

  @override
  Widget build(BuildContext context) {
    sessions = Provider.of<DataManager>(context).appointments;
    sessions.addAll(Provider.of<DataManager>(context).requests);
    sessions.sort();
    return ListView(
      children: sessions.map((session) => SessionPresenter(session)).toList(),
    );
  }
}
