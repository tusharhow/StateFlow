import 'dart:io';

class MultipartFile {
  final String field;
  final String filename;
  final String contentType;
  final Stream<List<int>> stream;

  MultipartFile({
    required this.field,
    required this.filename,
    required this.contentType,
    required this.stream,
  });

  factory MultipartFile.fromBytes(
      String field, String filename, List<int> bytes,
      {String contentType = 'application/octet-stream'}) {
    return MultipartFile(
      field: field,
      filename: filename,
      contentType: contentType,
      stream: Stream.fromIterable([bytes]),
    );
  }

  factory MultipartFile.fromFile(String field, File file,
      {String? contentType}) {
    return MultipartFile(
      field: field,
      filename: file.path.split('/').last,
      contentType: contentType ?? _getContentType(file.path),
      stream: file.openRead(),
    );
  }

  static String _getContentType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'mp4':
        return 'video/mp4';
      case 'mp3':
        return 'audio/mpeg';
      default:
        return 'application/octet-stream';
    }
  }
}
