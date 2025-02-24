// file.dart
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:logger/logger.dart';

var logger = Logger();

Future<void> downloadFile(String url) async {
  Dio dio = Dio();
  try {
    var dir = await getApplicationDocumentsDirectory();
    String fileName = url.split('/').last;
    String filePath = '${dir.path}/$fileName';

    await dio.download(
      url,
      filePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          logger.i('${(received / total * 100).toStringAsFixed(0)}%');
        }
      },
    );

    logger.i('File scaricato: $filePath');
    OpenFile.open(filePath);
  } catch (e) {
    logger.e(e);
  }
}
