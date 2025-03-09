import 'package:flutter/material.dart';

import '../../features/post/domain/entities/post_entity.dart';
import '../extensions/build_content_extensions.dart';
import '../extensions/num_extension.dart';
import '../extensions/widget_extensions.dart';
import '../utils/string_utils.dart';
import 'cache_image.dart';

class PostItem extends StatelessWidget {
  const PostItem({
    super.key,
    required this.post,
    this.callback,
    this.border,
    this.isDetail = false,
    this.isEditable = false,
    this.onEditPostCallback,
    this.onDeletePostCallback,
  });
  final PostEntity post;
  final Border? border;
  final Function()? callback;
  final bool isDetail;
  final bool isEditable;
  final Function(PostEntity)? onEditPostCallback;
  final Function(PostEntity)? onDeletePostCallback;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: callback,
      child: Container(
        decoration: BoxDecoration(
          border: isDetail ? null : border ?? Border.all(color: context.colorScheme.outline),
          borderRadius: 12.radius,
        ),
        padding: 20.eiAll,
        child: (context.isMobile || isDetail) ? _columnPost(context) : _rowPost(context),
      ),
    );
  }

  Row _rowPost(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CachedImage(
          imageUrl: post.imageUrl,
          placeholder: SizedBox(
            width: 280,
            height: 150,
            child: Center(child: CircularProgressIndicator()),
          ),
          width: 280,
          height: 150,
        ),
        20.sbW(),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Expanded(
                    child: Text(
                      post.title,
                      softWrap: true,
                      style: context.textTheme.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isEditable) ...editActionButton(),
                ],
              ),
              Text(
                timeAgo(post.updatedAt),
                style: TextStyle(color: context.colorScheme.onSurfaceVariant),
              ),
              20.sbH(),
              Text(
                post.body,
                style: context.textTheme.bodyMedium,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Column _columnPost(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CachedImage(
          imageUrl: post.imageUrl,
          placeholder: SizedBox(
            height: 250,
            width: double.infinity,
            child: Center(child: CircularProgressIndicator()),
          ),
          height: 250,
          width: double.infinity,
        ),
        20.sbH(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                post.title,
                style: context.textTheme.titleLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isEditable) ...editActionButton(),
          ],
        ),
        Text(
          timeAgo(post.updatedAt),
          style: TextStyle(color: context.colorScheme.onSurfaceVariant),
        ),
        20.sbH(),
        Text(
          post.body,
          style: context.textTheme.bodyLarge,
          maxLines: isDetail ? null : 5,
          overflow: isDetail ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
      ],
    );
  }

  List<Widget> editActionButton() => [
    IconButton(
      onPressed: () => onEditPostCallback != null ? onEditPostCallback!(post) : null,
      icon: Icon(Icons.edit),
    ),
    16.sbW(),
    IconButton(
      onPressed: () => onDeletePostCallback != null ? onDeletePostCallback!(post) : null,
      icon: Icon(Icons.delete),
    ),
  ];
}
