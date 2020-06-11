import 'package:flutter/foundation.dart';
import 'package:freibad_app/models/session.dart';

class Appointment extends Session {
  Appointment({
    @required String id,
    @required List<Map<String, String>> accessList, //following this scheme [{'person': 'personId', 'code': 'accessCode'}]
    @required DateTime startTime,
    @required DateTime endTime,
  }) : super(
          id: id,
          accessList: accessList,
          startTime: startTime,
          endTime: endTime,
        );
}
