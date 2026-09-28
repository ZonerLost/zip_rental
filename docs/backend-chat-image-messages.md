# Chat module — request: support sending an image as a message

**Status: ✅ FULLY RESOLVED, retested live 2026-09-28.** Backend implemented and committed (`18894e9`),
now deployed. Client-side (this repo) implements it too: picker → `ChatService.sendImageMessage()` →
multipart POST → `ChatBubble` renders `type === "image"` messages, chat list shows
"📷 Photo"/"📷 &lt;caption&gt;". The "Not Supported Yet" snackbar is gone.

## History

Live-testing on 2026-09-25 found the send working end-to-end but the uploaded image failing to
*load* — `chat-photos/` objects came back `403 Forbidden` while `profile-photos/` objects (same
bucket) returned `200`, pointing at a missing bucket-policy entry for that prefix rather than a
client bug. Backend fixed it same-day (added `chat-photos/*` to the bucket policy) and confirmed the
original reported object now returns `200`.

**Retested against production on 2026-09-28, all 5 items from the backend's checklist pass:**

1. ✅ Photo + caption → renders in the bubble, caption underneath (`content: "best captionn"` round-tripped correctly).
2. ✅ Photo with no caption → renders; empty `content`, rendered on `type` as instructed.
3. ✅ Left the thread and reopened → history renders the image the same way via `GET /chats/{id}/messages`.
4. ✅ Chat list shows "📷 Photo" from `lastMessage.type` with no extra fetch.
5. ✅ Deleted own image message → removed from history; the S3 object is inaccessible afterward too.

Also added a small client-side resilience improvement while retesting: `ChatBubble`'s image
`errorBuilder` now calls back into `ChatMessagesController.retryImageLoad()` (once per message) to
refetch and redisplay if a load ever fails — covers a transient failure today, and needs no further
change if chat media later moves to expiring signed URLs, per the backend's note about that
possibility.

---

## Backend's answer (received 2026-09-25)

```
POST /chats/{conversationId}/messages/image        multipart/form-data
  image    (file, required)     JPEG / PNG / WebP, max 5 MB
  caption  (text, optional)     up to 2000 chars; omit it entirely for an image on its own
```

Response — same message object the text endpoint returns, plus `type`/`imageUrl`:

```jsonc
{
  "success": true,
  "message": "Message sent",
  "data": {
    "_id": "6ab61423bcde82db5bf416f4",
    "conversation": "6ab6141fbcde82db5bf416da",
    "sender": { "_id": "6ab0bfc5…", "firstName": "Zain", "lastName": "Hassan" },
    "type": "image",
    "imageUrl": "https://zonerlost-media.s3.us-east-1.amazonaws.com/chat-photos/….jpg",
    "content": "here it is",
    "isRead": false,
    "deliveredAt": "2026-09-25T06:26:42.043Z",
    "createdAt": "2026-09-25T06:26:41.998Z",
    "updatedAt": "2026-09-25T06:26:41.998Z"
  }
}
```

Key points from their write-up:
- Render on `type`, not on whether `content` is empty — `content` is `""` for an uncaptioned image.
- Messages from before this feature have no `type` field at all — a missing `type` means `"text"`.
- Error responses for this route (and item/profile uploads, fixed at the same time): 400 with a
  specific message (`No image uploaded`, `File must be 5MB or smaller`, `Only JPEG, PNG and WebP
  images are allowed`, `Unexpected file field "…"`) instead of a 500.
- `GET /chats/{id}/messages` returns the same `type`/`imageUrl` for history — verified by them.
- `DELETE /chats/{id}/messages/{messageId}` works unchanged and also deletes the S3 object —
  `imageUrl` is dead once a message is deleted.
- `new_message` socket event carries the same `type`/`imageUrl` (same message object) — nothing extra
  to wire once sockets are usable again.
- `conversation.lastMessage` (on `GET /chats`) also carries `type`, so the chat list can show
  "📷 Photo" straight from the list response, no extra fetch needed.
- Receipts/delivery/blocking/permissions are all unchanged — an image message behaves exactly like a
  text one for everything except how it renders.
- Deployed to production as of 2026-09-28, confirmed by live retest above.

---

## What changed on our side

- `ChatMessage` (`lib/models/chat/chat_models.dart`): added `type` (defaults to `'text'` when the
  field is absent) and `imageUrl`; `fromMap` parses both.
- `ChatService.sendImageMessage()` (`lib/services/chat/chat_service.dart`): multipart POST to the
  route above, mirroring `ItemApiService.uploadItemPhotos()`'s pattern.
- `ChatMessagesController.sendImageMessage()`: optimistic-UI send (shows the local file immediately,
  swapped for the real URL once the upload responds), plus client-side 5MB/JPEG-PNG-WebP validation
  (same limits as item photos) so a bad file fails instantly instead of after a wasted upload.
- `chat_messages.dart`: `_showImageSourceSheet()` now sends the image instead of showing a snackbar;
  whatever's already typed in the input is sent along as the caption.
- `ChatBubble`: renders the image (local file while uploading, network URL once sent) with the
  caption underneath when present; its `errorBuilder` now calls `onImageError` (wired to
  `ChatMessagesController.retryImageLoad()`) once per message on a load failure, so a transient
  failure — or a future move to expiring URLs — self-heals without user action.
- `chat_main.dart`: last-message preview shows "📷 Photo" (or "📷 &lt;caption&gt;") for image messages.

## Also flagged, not part of this feature

While diagnosing the `chat-photos/` 403, the backend checked every S3 prefix the API writes to and
found two more that have never been publicly readable: `bookings/<id>/pre-rental|post-rental` and
`disputes/<id>/evidence` (both still `403`; `identity-docs/` is `403` too but intentionally,
admin-only/presigned). This app's `booking.dart` already renders `preRentalPhotos`/`postRentalPhotos`
via `_photoStrip` — so those are showing broken images in production today, same root cause as this
doc, just a different prefix. Backend says booking photos will likely get the same public-read fix;
dispute evidence is expected to move to expiring signed URLs instead (a contract change, not a
bucket-policy tweak) since it's quasi-legal material — they said we'd hear from them before that
ships. No action taken here; noting it so it isn't mistaken for a client bug if someone spots it.

Original request below, kept for context.

---

**Original status:** feature request, not a bug report. Nothing is broken — the app currently detects
this gap and tells the user clearly ("Sending images in chat needs a backend endpoint that doesn't
exist yet") right after they pick a photo, instead of pretending to support it and failing silently at
send time.

## What's missing

`POST /chats/:id/messages` only accepts a plain-text body:

```jsonc
{ "content": "hey" }
```

There's no way to send an image in a conversation. The app already has the picker UI built (camera /
gallery, via `image_picker`, compressed to `imageQuality: 85`) — it just has nowhere to send the
result.

## What we'd like

A way to upload an image and have it show up as a message in the conversation, with the same
delivery/read-receipt semantics (`deliveredAt`, `readAt`, `isRead`) as a text message.

We checked how this backend already handles uploads elsewhere so this fits the existing pattern
rather than inventing a new one — both `PUT /users/profile/photo` (field `photo`) and
`POST /items/:id/photos` (field `photos`) are multipart endpoints that return the resulting URL(s).
We'd suggest the same shape here:

```
POST /chats/:conversationId/messages/image      (multipart/form-data)
  file field: "image"
  optional field: "caption" — text alongside the image, same as most chat apps
```

Response — ideally the same message object shape `POST /chats/:id/messages` already returns, just
with an image URL and a way to tell image messages apart from text ones, e.g.:

```jsonc
{
  "success": true,
  "message": "Message sent",
  "data": {
    "_id": "...",
    "conversation": "...",
    "sender": { "_id": "...", "firstName": "...", "lastName": "..." },
    "type": "image",
    "imageUrl": "https://zonerlost-media.s3.us-east-1.amazonaws.com/chat-photos/...",
    "content": "optional caption text",
    "isRead": false,
    "createdAt": "...",
    "updatedAt": "..."
  }
}
```

If it's simpler on your side to keep `POST /chats/:id/messages` as the single endpoint and just
accept multipart there instead of JSON when an image is attached (content-negotiated by
`Content-Type`), that works for us too — whichever fits your existing code better. We don't have a
strong preference, just flagging the two options since the existing upload endpoints are all
separate multipart routes rather than negotiated ones.

## Things we'd want clarified either way

- **Max file size / accepted types** — so we can validate client-side before uploading, same as we
  do for item photos.
- **Does `GET /chats/:id/messages` return the same `type`/`imageUrl` fields** for history, so we can
  render past image messages the same way as a freshly-sent one?
- **Delete** — does `DELETE /chats/:id/messages/:messageId` (already documented as sender-only soft
  delete) work unchanged for an image message, including removing the underlying S3 object the way
  `DELETE /items/:id/photos` does?
- **Socket event** — once the realtime socket connection is usable again (see
  `docs/backend-chat-socket-questions.md`), does `new_message` carry the same `type`/`imageUrl`
  fields? Not blocking right now since sockets are disabled client-side either way, but worth getting
  right at the same time rather than as a follow-up.

## What changes on our side once this exists

Small — the picker UI, compression, and multipart-upload plumbing (`ChatService` already extends the
same `ApiServiceBase` that `ProfileService`/`ItemApiService` use for their multipart uploads) are
already in place from other features. Once the endpoint exists we'd:
1. Replace the "Not Supported Yet" snackbar in `ChatMessagesController`/`chat_messages.dart` with an
   actual upload call.
2. Add image rendering to `ChatBubble` (currently text-only) and to `ChatMessage.fromMap` /
   `ChatConversation`'s `lastMessage` preview (so the chat list shows something sensible like
   "📷 Photo" instead of empty content for an image-only message).

Not urgent — flagging as a follow-up once the socket work above is resolved, not blocking anything
today.
