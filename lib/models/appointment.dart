import 'package:flutter/foundation.dart';
import 'package:freibad_app/models/session.dart';

class Appointment extends Session {
  Appointment({
    @required String id,

    ///following this scheme [{'person': 'personId', 'code': 'accessCode'}]
    @required List<Map<String, String>> accessList,
    @required DateTime startTime,
    @required DateTime endTime,
  }) : super(
          id: id,
          accessList: accessList,
          startTime: startTime,
          endTime: endTime,
        );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    };
  }
}
