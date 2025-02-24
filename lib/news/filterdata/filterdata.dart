class FilterData {
  static String convertDateFormat(String date) {
    // Convert the date format from "24 Febbraio 2025" to "2025-02-24"
    final months = {
      'Gennaio': '01',
      'Febbraio': '02',
      'Marzo': '03',
      'Aprile': '04',
      'Maggio': '05',
      'Giugno': '06',
      'Luglio': '07',
      'Agosto': '08',
      'Settembre': '09',
      'Ottobre': '10',
      'Novembre': '11',
      'Dicembre': '12',
    };

    final parts = date.split(' ');
    final day = parts[0].padLeft(2, '0');
    final month = months[parts[1]]!;
    final year = parts[2];

    return '$year-$month-$day';
  }
}
