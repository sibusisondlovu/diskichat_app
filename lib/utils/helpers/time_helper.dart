
import 'package:intl/intl.dart';

class TimeHelper {
  static String formatMatchTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
}
