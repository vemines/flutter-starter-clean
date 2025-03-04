import 'package:flutter/material.dart';

import '../../app/locale.dart';
import '../../core/extensions/build_content_extensions.dart';

Widget hasMoreWidget(BuildContext context, bool hasMore) =>
    hasMore
        ? const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(child: CircularProgressIndicator()),
        )
        : Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Center(
            child: Text(
              context.tr(I18nKeys.noMoreList),
              style: context.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        );
