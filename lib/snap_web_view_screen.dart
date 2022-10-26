import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SnapWebViewScreen extends StatefulWidget {
  static const routeName = '/snap-webview';

  const SnapWebViewScreen({Key? key, required this.controller})
      : super(key: key);

  final Completer<WebViewController> controller;

  @override
  State<SnapWebViewScreen> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<SnapWebViewScreen> {
  var loadingPercentage = 0;

  @override
  Widget build(BuildContext context) {
    final routeArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final url = routeArgs['url'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter WebView'),
      ),
      body: Stack(
        children: [
          WebView(
            initialUrl: url,
            onPageStarted: (url) {
              setState(() {
                loadingPercentage = 0;
              });
            },
            onWebViewCreated: (webViewController) {
              widget.controller.complete(webViewController);
            },
            onProgress: (progress) {
              setState(() {
                loadingPercentage = progress;
              });
            },
            onPageFinished: (url) {
              setState(() {
                loadingPercentage = 100;
              });
            },
            navigationDelegate: (navigation) {
              final host = Uri.parse(navigation.url).toString();
              if (host.contains('gojek://') ||
                  host.contains('shopeeid://') ||
                  host.contains('//wsa.wallet.airpay.co.id/') ||
                  // This is handle for sandbox Simulator
                  host.contains('/gopay/partner/') ||
                  host.contains('/shopeepay/')) {
                _launchInExternalBrowser(Uri.parse(navigation.url));
                return NavigationDecision.prevent;
              } else {
                return NavigationDecision.navigate;
              }
            },
            javascriptMode: JavascriptMode.unrestricted,
          ),
          if (loadingPercentage < 100)
            LinearProgressIndicator(
              value: loadingPercentage / 100.0,
            ),
        ],
      ),
    );
  }

  Future<void> _launchInExternalBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }
}
