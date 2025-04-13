import 'package:intl/intl.dart';

String formatNumber(double number) {
  final formatter = NumberFormat('#,##0', 'vi_VN');
  return formatter.format(number);
}
