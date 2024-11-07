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
      this.Bucket,
      this.CommonPrefixes,
      this.ContentLength,
      this.Contents,
      this.Date,
      this.Delimiter,
      this.EncodingType,
      this.MaxKeys,
      this.Prefix);
}
