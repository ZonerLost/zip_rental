// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final String? itemId;
  final String? itemTitle;
  final String time;
  final bool isMe;
  /// Only meaningful when [isMe] is true — 'sent' | 'delivered' | 'read'.
  /// Mirrors WhatsApp: single tick while merely sent, double tick once
  /// delivered, and the double tick only turns blue once actually read.
  final String status;
  /// Set for image messages. Before the upload completes this is a local
  /// file path (the optimistic message uses the picked file directly so the
  /// image shows immediately); once the server responds it's swapped for
  /// the real `https://` URL.
  final String? imageUrl;
  /// Called (at most once per bubble build) when the network image fails to
  /// load — lets the caller refetch the message in case the URL itself was
  /// the problem (a transient failure, or the backend's flagged future move
  /// to expiring signed URLs) rather than leaving a permanently-broken
  /// bubble.
  final VoidCallback? onImageError;

  const ChatBubble({
    super.key,
    required this.message,
    this.itemId,
    this.itemTitle,
    required this.time,
    required this.isMe,
    this.status = 'sent',
    this.imageUrl,
    this.onImageError,
  });

  bool get _isNetworkImage => (imageUrl ?? '').startsWith('http');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // Chat Bubble
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isMe ? kPrimaryColor : kWhite,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((itemId ?? '').isNotEmpty || (itemTitle ?? '').isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isMe
                          ? Colors.white.withOpacity(0.16)
                          : kPrimaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: MyText(
                      text: itemTitle?.isNotEmpty == true
                          ? itemTitle!
                          : 'Item reference',
                      size: 12,
                      color: isMe ? kWhite : kPrimaryColor,
                      weight: FontWeight.w600,
                    ),
                  ),
                if ((imageUrl ?? '').isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _isNetworkImage
                        ? Image.network(
                            imageUrl!,
                            width: 220,
                            height: 220,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return SizedBox(
                                width: 220,
                                height: 220,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: isMe ? kWhite : kPrimaryColor,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) {
                              if (onImageError != null) {
                                // Not called synchronously during this
                                // build — errorBuilder can itself be
                                // invoked mid-build, and the callback ends
                                // up calling GetxController.update().
                                scheduleMicrotask(onImageError!);
                              }
                              return Container(
                                width: 220,
                                height: 220,
                                color: Colors.black12,
                                child: const Icon(Icons.broken_image_outlined),
                              );
                            },
                          )
                        : Image.file(
                            File(imageUrl!),
                            width: 220,
                            height: 220,
                            fit: BoxFit.cover,
                          ),
                  ),
                  if (message.isNotEmpty) const Gap(8),
                ],
                if (message.isNotEmpty)
                  MyText(
                    text: message,
                    size: 15,
                    color: isMe ? kWhite : kBlack,
                    weight: FontWeight.w400,
                    textAlign: TextAlign.start,
                  ),
              ],
            ),
          ),
          Gap(4),
          // Timestamp + Checkmark
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyText(
                text: time,
                size: 12,
                paddingTop: 4,
                color: kSubText2,
                weight: FontWeight.w500,
              ),
              if (isMe) ...[
                Gap(4),
                Icon(
                  status == 'sent' ? Icons.done : Icons.done_all,
                  size: 16,
                  color: status == 'read' ? kPrimaryColor : kSubText2,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
