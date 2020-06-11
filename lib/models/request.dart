import 'package:flutter/foundation.dart';
import 'package:freibad_app/models/session.dart';

class Request extends Session {
  Request({
    @required String id,
    @required List<Map<String, String>> accessList, //following this scheme [{'person': 'personId'}]
    @required DateTime startTime,
    @required DateTime endTime,
  }) : super(
          id: id,
          accessList: accessList,
          startTime: startTime,
          endTime: endTime,
        );
}
