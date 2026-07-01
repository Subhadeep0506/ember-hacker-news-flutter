import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Widget buildPlatformImage({
  required String imageUrl,
  required double width,
  required double height,
  required BoxFit fit,
  required Widget Function(BuildContext, String, Object) errorWidget,
}) {
  return CachedNetworkImage(
    imageUrl: imageUrl,
    width: width,
    height: height,
    fit: fit,
    errorWidget: errorWidget,
  );
}
