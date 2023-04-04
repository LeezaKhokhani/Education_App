import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../globals/globals.dart';

class WebPage extends StatefulWidget {
  const WebPage({Key? key}) : super(key: key);

  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;

  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
    ),
    android: AndroidInAppWebViewOptions(
      useHybridComposition: true,
    ),
    ios: IOSInAppWebViewOptions(
      allowsInlineMediaPlayback: true,
    ),
  );

  late PullToRefreshController pullToRefreshController;
  String url = "";
  final urlController = TextEditingController();
  late final String web;

  @override
  void initState() {
    super.initState();
    web = Global.currentWeb["website"];
    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            webViewController?.goBack();
            setState(() {
            });
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text("${Global.currentWeb['name']}"),
        actions: [
          IconButton(
            onPressed: () {
              Global.bookMarksList.add(url);
              Global.bookMarksList =
                  Global.bookMarksList.toSet().toList();
            },
            icon: Icon(Icons.bookmark),
          ),
          IconButton(
            onPressed: () {
              webViewController?.loadUrl(
                urlRequest: URLRequest(
                  url: Uri.parse(web),
                ),
              );
            },
            icon: Icon(Icons.home),
          ),
          IconButton(
            onPressed: () {
              webViewController?.goBack();
            },
            icon: Icon(Icons.arrow_forward),
          ),
        ],
      ),
      body: Center(
        child: InAppWebView(
          key: webViewKey,
          initialUrlRequest: URLRequest(
            url: Uri.parse("${Global.currentWeb['website']}"),
          ),
          initialOptions: options,
          pullToRefreshController: pullToRefreshController,
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
          onLoadStop: (controller, url) async {
            pullToRefreshController.endRefreshing();
            setState(
                  () {
                this.url = url.toString();
                urlController.text = this.url;
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          webViewController?.reload();
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}