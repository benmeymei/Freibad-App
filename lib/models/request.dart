import 'package:flutter/foundation.dart';
import 'package:freibad_app/models/session.dart';

class Request extends Session {
  final bool hasFailed;

  Request({
    @required String id,

    /// following this scheme [{'person': 'personId'}]
    @required List<Map<String, String>> accessList,
    @required DateTime startTime,
    @required DateTime endTime,
    @required String location,
    @required this.hasFailed,
  }) : super(
          id: id,
          accessList: accessList,
          startTime: startTime,
          endTime: endTime,
          location: location,
        );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'hasFailed': hasFailed ? 0 : 1, //SQLite cannot store bool, 0 == TRUE,
      'location': location
    };
  }
}
