part of './obs.dart';

extension StringMd5Ext on String {
  List<int> toMD5Bytes() {
    var content = Utf8Encoder().convert(this);
    var digest = md5.convert(content);
    return digest.bytes;
  }

  String toMD5() {
    return toMD5Bytes().toString();
  }

  String toMD5Base64() {
    var md5Bytes = toMD5Bytes();
    return base64.encode(md5Bytes);
  }

  String toHmacSha1Base64(String sk) {
    var hmacSha1 = Hmac(sha1, utf8.encode(sk));
    return base64.encode(hmacSha1.convert(utf8.encode(this)).bytes);
  }
}

extension ListIntExt on List<int> {
  List<int> toMD5Bytes() {
    return md5.convert(this).bytes;
  }

  String toMD5() {
    return toMD5Bytes().toString();
  }

  String toMD5Base64() {
    return base64.encode(toMD5Bytes());
  }
}

Future<List<int>> getFileMd5BytesFromPath(String filePath) async {
  File file = File(filePath);
  var digest = await md5.bind(file.openRead()).first;
  return digest.bytes;
}

Future<List<int>> getFileMd5Bytes(File file) async {
  var digest = await md5.bind(file.openRead()).first;
  return digest.bytes;
}

Future<String> getFileMd5Base64FromPath(String filePath) async {
  var md5bytes = await getFileMd5BytesFromPath(filePath);
  return base64.encode(md5bytes);
}

Future<String> getFileMd5Base64(File file) async {
  var md5bytes = await getFileMd5Bytes(file);
  return base64.encode(md5bytes);
}

String getRFC1123Date() {
  return HttpDate.format(DateTime.now());
}

// listObjects
Map<String, String> commonHeaders = {
  'content-length': 'ContentLength',
  'date': 'Date',
  'x-reserved': 'Reserved'
};

Map<String, String> ObsSignatureContext = {
  'signature': 'obs',
  'headerPrefix': 'x-obs-',
  'headerMetaPrefix': 'x-obs-meta-',
  'authPrefix': 'OBS'
};

Map<String, dynamic> parseCommonHeaders(Map<String, dynamic> headers) {
  Map<String, dynamic> opt = {
    "CommonMsg": {
      // "Status" : serverback.status,
      "Code": '',
      "Message": '',
      "HostId": '',
      "RequestId": '',
      "InterfaceResult": null
    },
    "InterfaceResult": {}
  };

  for (var Key in commonHeaders.keys) {
    opt["InterfaceResult"][Key] = commonHeaders[Key];
  }

  headers.forEach((key, value) {
    if (key.contains(ObsSignatureContext['headerMetaPrefix']!)) {
      var _key = key.substring(ObsSignatureContext['headerMetaPrefix']!.length);
      opt["InterfaceResult"][_key] = Uri.decodeComponent(value[0]);
    }
  });
  return opt;
}

///---------------------------------------------------
class getSignResultOpt {
  final Map<dynamic, dynamic> queryParams;
  final Map<dynamic, dynamic> queryParamsKeys;
  final dynamic objectKey;
  final dynamic bucketName;
  final Map<dynamic, dynamic>? signatureContext;

  getSignResultOpt(
      {required this.queryParams,
      required this.queryParamsKeys,
      this.objectKey,
      this.bucketName,
      required this.signatureContext});

  factory getSignResultOpt.frmmJson(Map<dynamic, dynamic> json) {
    return getSignResultOpt(
        queryParams: json['queryParams'],
        queryParamsKeys: json['queryParamsKeys'],
        objectKey: json['objectKey'],
        bucketName: json['bucketName'],
        signatureContext: json['signatureContext']);
  }
}

String createV2SignedUrl(Map<String, dynamic> param) {
  Map<String, dynamic> queryParams = getQueryParams(param)..addAll(param);

  var bucketName = encodeURIWithSafe('/${param["BucketName"]}/${param["objectKey"]}', '/', false);

  String signContent =
      "GET\n\n\n${queryParams['queryParams']['Expires']}\n$bucketName";

  print(signContent);
  var result = getSignResult(
      getSignResultOpt.frmmJson(queryParams), 'HKXFQ7HJT01TX8USG2RX', '');

  result +=
      'Signature=${encodeURIWithSafe(signContent.toHmacSha1Base64('wRz6IohO3k294UYrCXfvo16dBEkRBP3QbaDfzq46'), '/', false)}';

  return 'https://cs-example.obs.cn-south-1.myhuaweicloud.com$result';
}

String getSignResult(opt, ak, stsToken) {
  // 获取计算签名时的resuvar
  opt.queryParams['AccessKeyId'] = ak;

  var result = '';

  if (opt.objectKey.isNotEmpty) {
    result += '/' + encodeURIWithSafe(opt.objectKey, '/', false);
  }
  result += '?';

  for (var k in opt.queryParamsKeys.keys) {
    var val = opt.queryParamsKeys[k];
    var key = encodeURIWithSafe(k, '', false);
    val = encodeURIWithSafe(val, '', false);
    result += key;

    if (val.isNotEmpty) {
      result += '=$val';
    }
    result += '&';
  }

  return result;
}

String encodeURIWithSafe(str, safe, skipEncoding) {
  str = str.toString();
  if (str.length == 0) {
    return '';
  }
  if (skipEncoding) {
    return str;
  }
  var ret;
  if (safe.isNotEmpty) {
    ret = [];

    for (int i = 0; i < str.length; i++) {
      String v = str[i];
      ret.add(safe.contains(v) ? v : Uri.encodeComponent(v));
    }

    ret = ret.join('');
  } else {
    ret = Uri.encodeComponent(str);
  }

  return ret
      .replaceAll('!', '%21')
      .replaceAll('*', '%2A')
      .replaceAll("'", '%27')
      .replaceAll('(', '%28')
      .replaceAll(')', '%29');
}

Map<String, dynamic> getQueryParams(param) {
  var expires = 300;
  // 循环获取参数中的queryParams
  var queryParams = {};

  expires = int.parse(
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
          radix: 10) +
      expires;

  queryParams['Expires'] = '$expires';

  var queryParamsKeys = [];
  queryParams.keys.forEach((e) {
    queryParamsKeys.add(e);
  });

  queryParamsKeys.sort();

  return {"queryParams": queryParams, "queryParamsKeys": queryParams};
}
