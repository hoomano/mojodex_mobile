import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../DS/design_system.dart' as ds;
import '../../models/user/user.dart';

class ProfilePicture extends StatelessWidget {
  final String? data;

  const ProfilePicture({super.key, required this.data});

  Image imageFromBase64String(String base64String) {
    return Image.memory(base64Decode(base64String),
        errorBuilder: (context, _, stack) {
      User().onProfilePictureError();
      return CircleAvatar(
          backgroundColor: ds.DesignColor.grey.grey_3,
          child: SizedBox.expand(
              child: Padding(
            padding: const EdgeInsets.all(ds.Spacing.base),
            child: ds.DesignIcon.user02(),
          )));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return Icon(Icons.account_box_rounded,
          color: ds.DesignColor.grey.grey_7, size: 40);
    }

    if (data!.startsWith("http")) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CachedNetworkImage(
            imageUrl: data!,
            placeholder: (context, url) => const SizedBox(
                  width: 40,
                  height: 40,
                ),
            errorWidget: (context, url, error) {
              return CircleAvatar(
                  backgroundColor: ds.DesignColor.grey.grey_3,
                  child: SizedBox.expand(
                      child: Padding(
                    padding: const EdgeInsets.all(ds.Spacing.base),
                    child: ds.DesignIcon.user02(),
                  )));
            }),
      );
    } else {
      return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: imageFromBase64String(data!));
    }
  }
}
