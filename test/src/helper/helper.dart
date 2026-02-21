
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:mockito/mockito.dart';

class MockCameraController extends Mock implements CameraController {}

class FakeCameraDescription extends Fake implements CameraDescription {
  FakeCameraDescription({
    required this.name,
    required this.lensDirection,
    required this.sensorOrientation,
  });

  @override
  final String name;

  @override
  final CameraLensDirection lensDirection;

  @override
  final int sensorOrientation;
}

class FakePlane extends Fake implements Plane {
  FakePlane(this.bytes, {this.bytesPerRow = 640});

  @override
  final Uint8List bytes;

  @override
  final int bytesPerRow;

  @override
  int get bytesPerPixel => 1;

  @override
  int? get height => null;

  @override
  int? get width => null;
}

class FakeImageFormat extends Fake implements ImageFormat {
  FakeImageFormat();

  @override
  ImageFormatGroup get group => ImageFormatGroup.yuv420;

  @override
  int get raw => 35;
}

class FakeCameraImage extends Fake implements CameraImage {
  FakeCameraImage({
    required this.planes,
    this.width = 640,
    this.height = 480,
    ImageFormat? format,
  }) : format = format ?? FakeImageFormat();

  @override
  final List<Plane> planes;

  @override
  final int width;

  @override
  final int height;

  @override
  final ImageFormat format;

  @override
  double? get lensAperture => 0.0;

  @override
  int? get sensorExposureTime => 0;

  @override
  double? get sensorSensitivity => 0.0;
}
