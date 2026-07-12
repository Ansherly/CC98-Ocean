import 'package:flutter/material.dart';

class PortraitOval extends StatelessWidget {
  final String url;
  final double size;
  const PortraitOval({super.key, required this.url, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: ClipOval(
        child: url.isNotEmpty
            ? Image.network(url,
                height: size,
                width: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    buildDefaultAvatar(url))
            : buildDefaultAvatar(url),
      ),
    );
  }

  Widget buildDefaultAvatar(String url) {
    if (url.contains("boy")) {
      return Image.asset("assets/images/default_avatar_boy.png");
    } else if (url.contains("girl")) {
      return Image.asset("assets/images/default_avatar_girl.png");
    } else {
      return Image.asset("assets/images/unknown.gif");
    }
  }
}