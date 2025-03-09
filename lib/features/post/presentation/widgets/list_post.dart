import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../core/extensions/widget_extensions.dart';
import '../../../../core/widgets/has_more_incaditor.dart';
import '../../../../core/widgets/post_item.dart';
import '../../domain/entities/post_entity.dart';

class ListPostWidget extends StatelessWidget {
  const ListPostWidget(
    this.posts,
    this.hasMore, {
    super.key,
    this.isEditable = false,
    this.onEditPostCallback,
    this.onDeletePostCallback,
  });

  final List<PostEntity> posts;
  final bool hasMore;
  final bool isEditable;
  final Function(PostEntity)? onEditPostCallback;
  final Function(PostEntity)? onDeletePostCallback;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (_, _) => 16.sbH(),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: posts.length + 1,
      itemBuilder: (context, index) {
        if (index == posts.length) {
          return hasMoreWidget(context, hasMore);
        }
        final post = posts[index];
        return PostItem(
          key: ValueKey('post-${post.id}'),
          post: post,
          callback: () => context.push('${Paths.postDetail}/${post.id}'),
          isEditable: isEditable,
          onDeletePostCallback: onDeletePostCallback,
          onEditPostCallback: onEditPostCallback,
        );
      },
    );
  }
}
