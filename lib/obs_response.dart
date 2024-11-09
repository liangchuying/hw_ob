part of './obs.dart';

class OBSResponse {
  String? objectName;
  String? fileName;
  String? url;
  int? size;
  String? ext;
  String? md5;
}

class InterfaceResult {
  final String Bucket;
  final CommonPrefixes;
  final int? ContentLength;
  final Contents;
  final String Date;
  final String Delimiter;
  final dynamic EncodingType;
  final String MaxKeys;
  final String Prefix;

  InterfaceResult(
      {required this.Bucket,
      required this.CommonPrefixes,
      required this.ContentLength,
      required this.Contents,
      required this.Date,
      required this.Delimiter,
      this.EncodingType,
      required this.MaxKeys,
      required this.Prefix});
}
