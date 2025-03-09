import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../comment/domain/entities/comment_entity.dart';

class CommentItem extends StatelessWidget {
  const CommentItem({
    super.key,
    required this.comment,
    required this.isMyComment,
    this.onEdit,
    this.onDelete,
  });

  final CommentEntity comment;
  final bool isMyComment;
  final Function()? onEdit;
  final Function()? onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 30,
        backgroundImage: CachedNetworkImageProvider(comment.user.avatar),
      ),
      title: Text(comment.user.fullName),
      subtitle: Text(comment.body),
      trailing:
          isMyComment
              ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
                  IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
                ],
              )
              : SizedBox.shrink(),
    );
  }
}
