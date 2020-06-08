import 'package:flutter/material.dart';
import 'package:freibad_app/provider/local_data.dart';
import 'package:provider/provider.dart';
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
    sessions = Provider.of<LocalData>(context, listen: true).sessions;
    return Container(
      child: ListView(
        children: sessions.map((session) => SessionPresenter(session)).toList(),
      ),
    );
  }
}
