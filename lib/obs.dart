library obs;

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

part './obs_client.dart';

part './obs_response.dart';

part './utils.dart';

/// obs 对象存储操作
/// 文档地址 https://support.huaweicloud.com/api-obs/obs_04_0115.html
class FileObjectApi {
  /// 获取临时文件路径
  /// key === objectKey  示例：key = 't45/系统文件/客服/video/下载.mp4'
  static String getFileDownLoadUrl(String key) {
    return createV2SignedUrl({
      'BucketName': OBSClient.bucketName,
      'objectKey': key,
      'Method': "GET"
    });
  }

  /// objectName 文件对象 ‘dev/hello.text’
  static Future<Response> putObject(String objectName, List<int> data,
      {ProgressCallback? onSendProgress,
      String xObsAcl = "public-read"}) async {
    String contentMD5 = data.toMD5Base64();
    int size = data.length;
    var stream = Stream.fromIterable(data.map((e) => [e]));
    return await OBSClient.put(objectName, stream, contentMD5, size,
        onSendProgress: onSendProgress, xObsAcl: xObsAcl);
  }

  // 文本上传
  static Future<Response> putString(String objectName, String content,
      {ProgressCallback? onSendProgress,
      String xObsAcl = "public-read"}) async {
    var contentMD5 = content.toMD5Base64();
    var size = content.length;
    return await OBSClient.put(objectName, content, contentMD5, size,
        onSendProgress: onSendProgress, xObsAcl: xObsAcl);
  }

  // File 上传
  static Future<Response> putFile(String objectName, File file,
      {ProgressCallback? onSendProgress,
      String xObsAcl = "public-read"}) async {
    var contentMD5 = await getFileMd5Base64(file);
    var stream = file.openRead();
    return await OBSClient.put(
        objectName, stream, contentMD5, await file.length(),
        onSendProgress: onSendProgress, xObsAcl: xObsAcl);
  }

  // path 上传
  static Future<Response> putFileWithPath(String objectName, String filePath,
      {String xObsAcl = "public-read"}) async {
    return await putFile(objectName, File(filePath));
  }

  /// 获取元数据对象
  /// key 示例 'dev/video(16).mp4'
  /// ??? 元数据没有单独封装一个字段，待优化 Metadata
  static Future<Response> getObjectMetadata(String key) async {
    return await OBSClient.head(key);
  }

  // 修改元数据

  /// 获取列举对象
  /// key 示例 dev/
  static Future<Response> getListObjects(String key) async {
    return await OBSClient.get('/',
        queryParameters: {"prefix": key, "delimiter": "/"});
  }

  /// 删除对象 key 示例 'dev/video(16).mp4'
  static Future<Response> deleteObjects(String key) async {
    return await OBSClient.delete(key);
  }

  /// 拷贝对象
  /// destinationObjectName  目标对象 示例：dev/新建 XLS 工作表.xls
  ///  sourceObject 元对象拷贝对象 示例 t45/系统文件/客服/seatsKf_100058_-15/新建 XLS 工作表.xls
  ///  ？？？ 拷贝元对象 还是重新赋值元对象 待优化
  ///  https://support.huaweicloud.com/api-obs/obs_04_0082.html
  static Future<Response> copyObject(
      String destinationObjectName, String sourceObject) async {
    return await OBSClient.putCopy(
        destinationObjectName: destinationObjectName,
        sourceObject: sourceObject);
  }
}
