import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class WebViewPage extends StatefulWidget {
  final String url;

  WebViewPage({Key? key, required this.url}) : super(key: key);

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final _key = UniqueKey();
  InAppWebViewController? _controller;
  late ValueNotifier<String> _filePathNotifier;

  @override
  void initState() {
    super.initState();
    _filePathNotifier = ValueNotifier<String>('');
  }

  @override
  void dispose() {
    _filePathNotifier.dispose();
    super.dispose();
  }
  Future<bool> _requestCameraPermission() async {
    var status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> _requestStoragePermission() async {
    var status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<void> _pickImage() async {
    bool cameraPermission = await _requestCameraPermission();
    bool storagePermission = await _requestStoragePermission();

    if (cameraPermission && storagePermission) {
      // Your existing _pickImage code here
    } else {
      // Handle permission denied scenario
    }
  }


  Future<void> _pickVideo() async {
    bool storagePermission = await _requestStoragePermission();

    if (storagePermission) {
      // Your existing _pickVideo code here
    } else {
      // Handle permission denied scenario
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Column(
        children: [
          Expanded(
            child: InAppWebView(
              key: _key,
              initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
              onWebViewCreated: (InAppWebViewController webViewController) {
                _controller = webViewController;
              },
              onLoadStart: (controller, url) {
                print('Page started loading: $url');
              },
              onLoadStop: (controller, url) {
                print('Page finished loading: $url');
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                var uri = navigationAction.request.url!;
                if (uri.toString().startsWith('https://www.youtube.com/')) {
                  print('blocking navigation to $uri}');
                  return NavigationActionPolicy.CANCEL;
                }
                print('allowing navigation to $uri');
                return NavigationActionPolicy.ALLOW;
              },
              onProgressChanged: (controller, progress) {
                // Handle progress changes if needed
              },
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  javaScriptEnabled: true,
                  useOnDownloadStart: true, // Enables file download support
                  useShouldOverrideUrlLoading: true, // Required for `shouldOverrideUrlLoading` callback to work
                ),
              ),
              onDownloadStart: (controller, url) async {
                // Handle file download here
                print('Download start: $url');
              },
              onLoadResource: (controller, resource) async {
                if (resource is LoadedResource) {
                  final url = resource.url.toString();
                  if (url.startsWith('blob:')) {
                    _filePathNotifier.value = url;
                  }
                }
              },
            ),
          ),
          ValueListenableBuilder<String>(
            valueListenable: _filePathNotifier,
            builder: (context, filePath, _) {
              if (filePath.isNotEmpty) {
                return Column(
                  children: [
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: Text('Pick Image'),
                    ),
                    ElevatedButton(
                      onPressed: _pickVideo,
                      child: Text('Pick Video'),
                    ),
                  ],
                );
              } else {
                return SizedBox.shrink();
              }
            },
          ),
        ],
      ),
    );
  }
}
