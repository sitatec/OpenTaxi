import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CustomWebView extends StatefulWidget {
  final String title;
  final String? initialUrl;
  final Function(String)? onPageStarted;
  const CustomWebView({
    this.title = "",
    this.initialUrl,
    this.onPageStarted,
    Key? key,
  }) : super(key: key);

  @override
  _CustomWebViewState createState() => _CustomWebViewState();
}

class _CustomWebViewState extends State<CustomWebView> {
  int pageLoadProgress = 0;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
        ),
        foregroundColor: Colors.black,
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: Column(
        children: [
          if (pageLoadProgress < 100)
            LinearProgressIndicator(
              value: pageLoadProgress / 100,
              color: theme.primaryColor.withAlpha(200),
              backgroundColor: theme.primaryColor.withAlpha(50),
            ),
          Expanded(
            child: WebView(
              javascriptMode: JavascriptMode.unrestricted,
              initialUrl: widget.initialUrl,
              onPageStarted: widget.onPageStarted,
              onProgress: (progress) =>
                  setState(() => pageLoadProgress = progress),
            ),
          ),
        ],
      ),
    );
  }
}
