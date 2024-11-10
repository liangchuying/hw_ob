part of './obs.dart';

class OBSClient {
  static String ak = 'HKXFQ7HJT01TX8USG2RX';
  static String sk = 'wRz6IohO3k294UYrCXfvo16dBEkRBP3QbaDfzq46';
  static String bucketName = kReleaseMode ? '' : 'cs-example';
  static String domain = 'https://$bucketName.obs.cn-south-1.myhuaweicloud.com';

  static late final Dio _dio;

  static OBSClient? _instance;

  factory OBSClient() {
    OBSClient._instance ??= OBSClient._initial();
    return OBSClient._instance!;
  }

  OBSClient._initial() {
    final BaseOptions options = BaseOptions(
      baseUrl: domain,
      sendTimeout: const Duration(seconds: 5),
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    );

    _dio = Dio(options);

    _dio.interceptors.add(PrettyDioLogger(
        requestHeader: true, requestBody: true, responseHeader: true));
  }

  Future<Response> get(String objectName,
      {Map<String, dynamic>? queryParameters,
      String xObsAcl = "public-read"}) async {
    if (objectName.startsWith("/")) {
      objectName = objectName.substring(1);
    }

    String url = "/";
    var date = HttpDate.format(DateTime.now());
    Map<String, String> headers = {};

    headers["Date"] = date;
    headers["Authorization"] =
        _sign("GET", '', '', date, "", "/$bucketName/$objectName");

    Options options = Options()
      ..method = 'get'
      ..headers = headers;

    try {
      Response response = await _dio.request(url,
          options: options, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      return e.response!;
    }
  }

  Future<Response> head(String objectName,
      {Map<String, dynamic>? queryParameters,
      String xObsAcl = "public-read"}) async {
    if (objectName.startsWith("/")) {
      objectName = objectName.substring(1);
    }

    objectName = encodeURIWithSafe(objectName, '/', false);

    String url = "/$objectName";
    var date = HttpDate.format(DateTime.now());
    Map<String, String> headers = {};

    headers["Date"] = date;
    headers["Authorization"] =
        _sign("HEAD", '', '', date, "", "/$bucketName/$objectName");

    Options options = Options()
      ..method = 'head'
      ..headers = headers;

    try {
      Response response = await _dio.request(url,
          options: options, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      return e.response!;
    }
  }

  Future<Response> put(String objectName, data, String md5, int size,
      {ProgressCallback? onSendProgress,
      String xObsAcl = "public-read"}) async {
    if (objectName.startsWith("/")) {
      objectName = objectName.substring(1);
    }

    String url = "/$objectName";

    var contentMD5 = md5;
    var date = HttpDate.format(DateTime.now());
    var contentType = "application/octet-stream";

    Map<String, String> headers = {};
    headers['content-length'] = '$size';
    headers["Content-MD5"] = contentMD5;
    headers["Date"] = date;
    headers["x-obs-acl"] = xObsAcl;
    headers["Authorization"] = _sign("PUT", contentMD5, contentType, date,
        "x-obs-acl:$xObsAcl", "/$bucketName/$objectName");

    Options options = Options()
      ..method = 'put'
      ..headers = headers
      ..contentType = contentType;

    try {
      Response response = await _dio.request(url,
          data: data, options: options, onSendProgress: onSendProgress);
      return response;
    } on DioException catch (e) {
      return e.response!;
    }
  }

  Future<Response> putCopy(
      {required String destinationObjectName,
      required String sourceObject}) async {
    sourceObject = encodeURIWithSafe(sourceObject, '/', false);
    destinationObjectName =
        encodeURIWithSafe(destinationObjectName, '/', false);

    String url = "/$destinationObjectName";

    var date = HttpDate.format(DateTime.now());

    Map<String, String> headers = {};
    headers["Date"] = date;
    headers["x-obs-copy-source"] = '/$bucketName/$sourceObject';
    headers["Authorization"] = _sign(
        "PUT",
        '',
        '',
        date,
        "x-obs-copy-source:/$bucketName/$sourceObject",
        "/$bucketName/$destinationObjectName");

    Options options = Options()
      ..method = 'put'
      ..headers = headers;

    try {
      Response response = await _dio.request(url, options: options);
      return response;
    } on DioException catch (e) {
      return e.response!;
    }
  }

  Future<Response> delete(String objectName) async {
    if (objectName.startsWith("/")) {
      objectName = objectName.substring(1);
    }

    String url = "/$objectName";
    var date = HttpDate.format(DateTime.now());

    Map<String, String> headers = {};

    headers["Date"] = date;
    headers["Authorization"] =
        _sign("DELETE", '', '', date, "", "/$bucketName/$objectName");

    Options options = Options()
      ..method = 'delete'
      ..headers = headers;

    try {
      Response response = await _dio.request(url, options: options);
      return response;
    } on DioException catch (e) {
      return e.response!;
    }
  }

  static String _sign(String httpMethod, String contentMd5, String contentType,
      String date, String acl, String res) {
    if (ak.isEmpty || sk.isEmpty) {
      throw "ak or sk is null";
    }

    String signContent = "$httpMethod\n$contentMd5\n$contentType\n$date";
    if (acl.isNotEmpty) signContent = '$signContent\n$acl';
    signContent = '$signContent\n$res';

    return "OBS $ak:${signContent.toHmacSha1Base64(sk)}";
  }
}
