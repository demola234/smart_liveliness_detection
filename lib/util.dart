//
// import 'dart:convert';
// import 'dart:typed_data';
// import 'dart:ui';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
//
// InputImage jsonToInputImage(String jsonString) {
//   final Map<String, dynamic> jsonData = json.decode(jsonString);
//
//   // Check InputImage type according to JSON
//   final String? type = jsonData['type'];
//
//   if (type == 'file') {
//     return InputImage.fromFilePath(jsonData['path']);
//   } else if (type == 'bytes') {
//     return InputImage.fromBytes(
//       bytes: Uint8List.fromList(List<int>.from(jsonData['bytes'])),
//       metadata: InputImageMetadata(
//         size: Size(
//           (jsonData['metadata']['width'] ?? 0).toDouble(),
//           (jsonData['metadata']['height'] ?? 0).toDouble(),
//         ),
//         rotation: _parseImageRotation(jsonData['metadata']['rotation']),
//         format: _parseImageFormat(jsonData['metadata']['image_format']),
//         bytesPerRow: jsonData['metadata']['bytes_per_row'], // ???
//       ),
//     );
//   } else if (type == 'file') {
//     // Para InputImage.fromFile, você precisaria do arquivo real
//     throw Exception('For InputImage.fromFile the real file is needed. It cannot be recreated by JSON');
//   } else {
//     throw Exception('InputImage type not supported: $type');
//   }
// }
//
// // AUX METHODS
// InputImageRotation _parseImageRotation(dynamic rotation) {
//   if (rotation is int) {
//     return InputImageRotation.values.firstWhere((e) => e.rawValue == rotation,
//       orElse: () => InputImageRotation.rotation0deg,
//     );
//   }
//   return InputImageRotation.rotation0deg;
// }
//
// InputImageFormat _parseImageFormat(dynamic format) {
//   if (format is int) {
//     return InputImageFormat.values.firstWhere((e) => e.rawValue == format,
//       orElse: () => InputImageFormat.nv21,
//     );
//   }
//   return InputImageFormat.nv21;
// }