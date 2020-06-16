import 'package:flutter/foundation.dart';
import 'package:freibad_app/models/session.dart';

class Request extends Session {
  final hasFailed;
  
  Request({
    @required String id,
    @required List<Map<String, String>> accessList, //following this scheme [{'person': 'personId'}]
    @required DateTime startTime,
    @required DateTime endTime,
    @required this.hasFailed,
  }) : super(
          id: id,
          accessList: accessList,
          startTime: startTime,
          endTime: endTime,
        );
}
