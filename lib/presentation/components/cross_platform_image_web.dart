import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

final _registered = <String>{};

Widget buildPlatformImage({
  required String imageUrl,
  required double width,
  required double height,
  required BoxFit fit,
  required Widget Function(BuildContext, String, Object) errorWidget,
}) {
  final viewType = 'og-img-${imageUrl.hashCode}';

  if (!_registered.contains(viewType)) {
    _registered.add(viewType);
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final img = web.HTMLImageElement()
        ..src = imageUrl
        ..alt = '';
      img.style
        ..setProperty('object-fit', 'cover')
        ..setProperty('width', '100%')
        ..setProperty('height', '100%')
        ..setProperty('display', 'block');

      img.addEventListener(
        'error',
        ((web.Event e) {
          img.style.setProperty('display', 'none');
        }).toJS,
      );

      return img;
    });
  }

  return SizedBox(
    width: width,
    height: height,
    child: HtmlElementView(viewType: viewType),
  );
}
