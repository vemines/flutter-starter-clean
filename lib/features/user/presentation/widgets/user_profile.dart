import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/locale.dart';
import '../../../../app/routes.dart';
import '../../../../core/extensions/build_content_extensions.dart';
import '../../../../core/extensions/num_extension.dart';
import '../../../../core/extensions/widget_extensions.dart';
import '../../../../core/widgets/cache_image.dart';
import '../../domain/entities/user_entity.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({super.key, required this.user, this.isDetail = false});
  final UserEntity user;
  final bool isDetail;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: () => context.push('${Paths.userProfile}/${user.id}'),
      child: SizedBox(
        height: 350,

        child: Stack(
          children: [
            // Cover image
            SizedBox(height: 250, width: double.infinity, child: CachedImage(imageUrl: user.cover)),

            // User avatar
            Positioned(
              top: 135,
              left: 16,
              right: isDetail ? 16 : null,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: context.colorScheme.surfaceBright, width: 10),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 90,
                  backgroundImage: CachedNetworkImageProvider(user.avatar),
                ),
              ),
            ),

            // User Detail
            if (!isDetail)
              Positioned(
                top: 260,
                left: 16 + 180 + 50,
                width: 1200 - 250,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    8.sbH(),
                    FilledButton(
                      onPressed: () {
                        context.push('${Paths.userProfile}/${user.id}');
                      },
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: 6.radius),
                        padding:
                            context.isMobile
                                ? null
                                : EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      ),
                      child: Text(
                        context.tr(I18nKeys.viewProfile),
                        style: context.textTheme.labelLarge!.copyWith(
                          color: context.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
