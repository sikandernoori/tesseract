class RecognizedBlock {
  String text;
  double confidence;
  double boundingBoxOriginX;
  double boundingBoxOriginY;
  double boundingBoxWidth;
  double boundingBoxHeight;

  RecognizedBlock(
      {required this.text,
      required this.confidence,
      required this.boundingBoxOriginX,
      required this.boundingBoxOriginY,
      required this.boundingBoxWidth,
      required this.boundingBoxHeight});
}
