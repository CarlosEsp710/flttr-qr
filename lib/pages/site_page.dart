import 'package:flutter/material.dart';

import 'package:webview_flutter/webview_flutter.dart';

class SitePage extends StatefulWidget {
  final String webSite;
  final String? title;

  const SitePage({
    Key? key,
    required this.webSite,
    this.title,
  }) : super(key: key);

  @override
  State<SitePage> createState() => _SitePageState();
}

class _SitePageState extends State<SitePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Website preview'),
      ),
      body: WebView(
        initialUrl: widget.webSite,
        javascriptMode: JavascriptMode.unrestricted,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.translate),
      ),
    );
  }
}
