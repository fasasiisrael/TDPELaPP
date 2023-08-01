import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';

class YouTubeEmbedWidget extends StatelessWidget {
  final String videoId;
  final bool? fullIFrame;

  YouTubeEmbedWidget(this.videoId, {this.fullIFrame});

  @override
  Widget build(BuildContext context) {
    print("Vidoe Id $videoId");
    return AspectRatio(
      aspectRatio: 16 / 8,
      child: IgnorePointer(
        child: WebView(
          backgroundColor: Colors.transparent,
          initialUrl: Uri.dataFromString(
            fullIFrame.validate()
                ? '<html><iframe style="width:100%" height="260" src="https://www.youtube.com/embed/$videoId"></iframe></html>'
                : '<html><iframe style="width:100%" height="460" frameborder="0" src="https://www.youtube.com/embed/$videoId" allow="autoplay; fullscreen" allowfullscreen="allowfullscreen"></iframe></html>',
            mimeType: 'text/html',
            encoding: Encoding.getByName('utf-8'),
          ).toString(),
          javascriptMode: JavascriptMode.unrestricted,
        ),
        // child: Html(
        //   data: fullIFrame.validate()
        //       ? '<html><h1> dfjndvdmnv</h1><iframe style="width:100%" height="260" src="$videoId"></iframe></html>'
        //       : '<h1> dfjndvdmnv</h1><iframe loading="lazy" title="vimeo-player" src="https://player.vimeo.com/video/793511925?h=5815c9e823" width="640" height="360" frameborder="0" allowfullscreen=""></iframe>',
        // ),
      ).center(),
    ).onTap(() {
      url_launcher.launchUrl(Uri.parse('https://www.youtube.com/embed/$videoId'), mode: LaunchMode.inAppWebView);
    });
  }
}
