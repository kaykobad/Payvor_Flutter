import 'package:intl/intl.dart';

class TimeAgo {
  static String timeAgoSinceDate(num timeStamp, {bool numericDates = true}) {
    DateTime notificationDate =
        new DateTime.fromMicrosecondsSinceEpoch(timeStamp * 1000);
    ;
    final currentDate = DateTime.now();
    final difference = currentDate.difference(notificationDate);
    String dateString = DateFormat('dd-MM-yyyy h:mma').format(currentDate);
    if (difference.inDays > 8) {
      return dateString;
    } else if ((difference.inDays / 7).floor() >= 1) {
      return (numericDates) ? '1 week ago' : 'Last week';
    } else if (difference.inDays >= 2) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays >= 1) {
      return (numericDates) ? '1 day ago' : 'Yesterday';
    } else if (difference.inHours >= 2) {
      return '${difference.inHours} hours ago';
    } else if (difference.inHours >= 1) {
      return (numericDates) ? '1 hour ago' : 'An hour ago';
    } else if (difference.inMinutes >= 2) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inMinutes >= 1) {
      return (numericDates) ? '1 minute ago' : 'A minute ago';
    } else if (difference.inSeconds >= 3) {
      return '${difference.inSeconds} seconds ago';
    } else {
      return 'now';
    }
  }

  static String timeString(num timeStamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    final dateToCheck =
        new DateTime.fromMicrosecondsSinceEpoch(timeStamp * 1000);

    final aDate =
        DateTime(dateToCheck.year, dateToCheck.month, dateToCheck.day);
    if (aDate == today) {
      return "Today";
    } else if (aDate == yesterday) {
      return "Yesterday";
    } else {
      return DateFormat('dd-MM-yyyy').format(dateToCheck);
    }
  }
}
