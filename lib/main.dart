import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:xml2json/xml2json.dart';
import 'package:xml/xml.dart';

import 'package:logger/logger.dart';

import 'obs.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      builder: EasyLoading.init(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    // OBSClient.init(
    //   'HKXFQ7HJT01TX8USG2RX',
    //   'wRz6IohO3k294UYrCXfvo16dBEkRBP3QbaDfzq46',
    //   'https://cs-example.obs.cn-south-1.myhuaweicloud.com',
    //   'cs-example',
    // );
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: () async {
                  String json = await FileObjectApi.getListObjects('dev/');

                  logger.f(json);
                  logger.f(json.runtimeType);
                },
                child: Text('列举对象')),
            ElevatedButton(
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();

                  if (result != null) {
                    print(result.files.single.path!);
                    File file = File(result.files.single.path!);
                    Response res = await FileObjectApi.putFile(
                        'dev/${result.files.single.name}', file);

                    logger.f('----${res.headers}');
                    logger.f('----${res.statusCode}');
                  } else {
                    // User canceled the picker
                  }
                },
                child: Text("上传文件")),
            ElevatedButton(
                onPressed: () async {
                  Response res = await FileObjectApi.getObjectMetadata(
                      't45/系统文件/客服/seatsKf_100058_-15/downloadfile-1.mp4');

                  Map<String, dynamic> headers = res.headers.map;
                  var InterfaceResult = parseCommonHeaders(headers);

                  logger.f(InterfaceResult);
                },
                child: Text('获取元数据')),
            ElevatedButton(
                onPressed: () {
                  String url = createV2SignedUrl({
                    'BucketName': 'cs-example',
                    // 'objectKey': 'dev/Screenshot_2024-10-20-16-00-19-750_com.tencent.mm.jpg',
                    'objectKey': 't45/系统文件/客服/video/下载.mp4',
                    // 'objectKey': 'dev/video(16).mp4',
                    'Method': "GET"
                  });

                  logger.f(url);
                },
                child: Text('获取下载地址')),
            ElevatedButton(
                onPressed: () async {
                  Response res = await FileObjectApi.deleteObjects(
                      'dev/T4441-230208-73DA1A7756484722.txt');
                  logger.f(res.statusCode);
                },
                child: Text('删除对象')),
            ElevatedButton(
                onPressed: () async {
                  Response res = await FileObjectApi.copyObject(
                      'dev/新建 XLS 工作表.xls',
                      't45/系统文件/客服/seatsKf_100058_-15/新建 XLS 工作表.xls');
                  logger.f(res.statusCode);
                },
                child: Text('拷贝对象')),
          ],
        ),
      ),
    );
  }
}

Map<String, dynamic> _elementToMap(XmlElement element) {
  final Map<String, dynamic> result = {};

  // 遍历当前元素的子元素
  for (var child in element.children) {
    if (child is XmlElement) {
      final childMap = _elementToMap(child);
      final childName = child.name.toString();

      if (childName == 'Contents') {
        if (result.containsKey('Contents')) {
          result[childName] = [...result[childName], childMap];
        } else {
          result[childName] = [childMap];
        }
      } else if (childName == 'CommonPrefixes') {
        if (result.containsKey('CommonPrefixes')) {
          result[childName] = [...result[childName], childMap];
        } else {
          result[childName] = [childMap];
        }
      } else {
        result[childName] = childMap;
      }
    } else {
      result['value'] = child;
    }
  }

  return result;
}
