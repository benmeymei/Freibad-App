import 'package:intl/intl.dart';

class ApiService {
  static List<List<DateTime>> availableTimeBlocks(DateTime date) {
    //could be advanced with more conditions (like local holidays), for that Reason placed in API_SERVICE

    String formattedDate = DateFormat('EEEEE').format(date);

    if (formattedDate == 'Saturday' || formattedDate == 'Sunday') {
      return [
        [addHour(date, 8), addHour(date, 13, minutes: 30)],
        [addHour(date, 14, minutes: 30), addHour(date, 20)],
      ];
    } else {
      return [
        [addHour(date, 6), addHour(date, 9)],
        [addHour(date, 10), addHour(date, 16)],
        [addHour(date, 17), addHour(date, 20)],
      ];
    }
  }

  static DateTime addHour(DateTime date, int hours, {int minutes = 0}) {
    DateTime tempDate = date;
    return tempDate.add(Duration(hours: hours, minutes: minutes));
  }
}
