import 'dart:ui' as ui;

ui.Image? image;
ui.Picture? picture;

Future<void> exerciseGraphics() async {
  image = await _createImage();
  picture = _createPicture();
  print('${image.runtimeType}');
}

Future<ui.Image> _createImage() => _createPicture().toImage(10, 10);

ui.Picture _createPicture() {
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final ui.Canvas canvas = ui.Canvas(recorder);
  const ui.Rect rect = ui.Rect.fromLTWH(0.0, 0.0, 100.0, 100.0);
  canvas.clipRect(rect);
  return recorder.endRecording();
}
