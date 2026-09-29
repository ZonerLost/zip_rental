# Disputes API — two bugs found during integration

**Context:** integrated the `08 · Disputes` Postman collection into the Flutter app and tested every renter/owner-facing endpoint live against production (`https://au2p3vkiqi.us-east-1.awsapprunner.com`), not just against the docs. Two things don't match the documented/expected behavior. Neither is blocking — the client handles both gracefully — but both need a backend fix.

---

## 1. Evidence images are uploaded successfully but come back `403 Forbidden` — the S3 path isn't public-read

`POST /disputes/:id/evidence` works correctly: it accepts the multipart upload and returns the new URL in `evidence[]`. But that URL isn't fetchable by anyone — it 403s even with no auth headers at all, same as a browser or the app's image loader would request it.

**Repro:**
```bash
# Upload evidence to an existing dispute
curl -X POST "https://au2p3vkiqi.us-east-1.awsapprunner.com/api/v1/disputes/6abb96375fad339ccdfa5a2e/evidence" \
  -H "Authorization: Bearer <token>" \
  -F "evidence=@photo.png;type=image/png"

# → 200, data.evidence[0] =
# https://zonerlost-media.s3.us-east-1.amazonaws.com/disputes/6abb96375fad339ccdfa5a2e/evidence/17b62142-9ab0-41a0-ba90-5f3901fca702-1790678634148

# Now fetch that exact URL:
curl -s -o /dev/null -w "%{http_code}\n" \
  "https://zonerlost-media.s3.us-east-1.amazonaws.com/disputes/6abb96375fad339ccdfa5a2e/evidence/17b62142-9ab0-41a0-ba90-5f3901fca702-1790678634148"
# → 403
```

Compare with two other prefixes in the **same bucket**, both public-read and working fine (these are what item photos and profile photos already use elsewhere in the app):
```bash
curl -s -o /dev/null -w "%{http_code}\n" "https://zonerlost-media.s3.us-east-1.amazonaws.com/item-photos/6df83b15-8258-49af-b675-148d9b2dea87-1789968559478"
# → 200

curl -s -o /dev/null -w "%{http_code}\n" "https://zonerlost-media.s3.us-east-1.amazonaws.com/profile-photos/373b50cc-d743-4051-87a2-97d2b965afec-1790317496145"
# → 200
```

Looks like the bucket policy / object ACL for the `disputes/` prefix just wasn't set up the same way as `item-photos/` and `profile-photos/` when this feature was added. Either make `disputes/evidence/*` public-read to match, or — if evidence photos are meant to be more restricted than item/profile photos on purpose — switch the API to return signed/presigned URLs instead of raw S3 URLs, and let us know so we can adjust how we cache/refresh them client-side.

**Client impact:** none crash-wise — our image widget already handles a failed load with a fallback error icon instead of breaking the screen. But evidence photos are currently unviewable by anyone (reporter, the other party, or admin) until this is fixed.

---

## 2. `GET /disputes/my?status=` is ignored server-side

The `status` query param (documented values: `open`, `under_review`, `resolved_for_renter`, `resolved_for_owner`, `resolved_mutually`, `closed`) doesn't filter anything — every value returns the same unfiltered list.

**Repro:** one account with exactly one dispute, whose actual `status` is `"closed"`:
```bash
curl "https://au2p3vkiqi.us-east-1.awsapprunner.com/api/v1/disputes/my?status=open&page=1&limit=10" \
  -H "Authorization: Bearer <token>"
# → data: [ { ..., "status": "closed", ... } ]   (should be empty)

curl "https://au2p3vkiqi.us-east-1.awsapprunner.com/api/v1/disputes/my?status=closed&page=1&limit=10" \
  -H "Authorization: Bearer <token>"
# → data: [ { ..., "status": "closed", ... } ]   (same result either way)
```

Both calls return byte-identical `data`/`pagination`, including a `status=open` request returning a dispute whose real status is `closed`. Looks like the param is either never read or never applied to the query.

**Client impact:** none crash-wise — our Open/Closed filter tabs are wired up correctly and send the right param, they just won't actually narrow the list until the backend honors it. Currently every tab shows the same full list.

---

## 3. Not a bug, but worth flagging: `GET /disputes/my` doesn't match its own description

The collection describes this endpoint as "Disputes I am part of," which reads as *either* party — reporter or the one reported against, matching how `GET /disputes/:id` is documented ("Either party" can view a single dispute). In practice it only returns disputes where the caller is `reportedBy`.

**Repro:** two accounts, one dispute each way on the same booking —
```bash
# Account A reports account B
POST /disputes  (as A)  → reportedBy: A, reportedAgainst: B

# Account B reports account A (different booking not required — same booking is fine)
POST /disputes  (as B)  → reportedBy: B, reportedAgainst: A

GET /disputes/my  (as A)  → only the dispute A filed. The one B filed against A is absent.
GET /disputes/my  (as B)  → only the dispute B filed. The one A filed against A is absent from A's own list too (obviously — different account), but B's own filed-by-A-against-B dispute doesn't show on B's `/my` either.
```

So today there's no way for a user to see disputes filed *against* them — `GET /disputes/:id` would show it if they somehow had the id, but nothing surfaces that id to them. If the intent really is "either party," `/my` should also match on `reportedAgainst`. If the intent is "only what I filed," that's fine too, just means we should reword our own UI copy rather than mirroring the doc's "either party" framing — let us know which one it's supposed to be.

---

## Appendix: environment

- Backend: `https://au2p3vkiqi.us-east-1.awsapprunner.com/api/v1`
- Test accounts: `zaindev2@yopmail.com` (owner, reporter of dispute `6abb96375fad339ccdfa5a2e`, reason `item_damaged`, now `closed`), `v8fujw3ene@olipii.com` (renter, reporter of dispute `6abb96bf5fad339ccdfa5a6b`, reason `item_not_as_described`, `open`)
- Shared booking used for both: `6abb8c2b5fad339ccdfa58c2`
- Confirmed while testing, not a bug — noting for the record: the `reason` enum isn't in the collection description, but a validation error names it exactly: `item_damaged, item_not_returned, item_not_as_described, late_return, no_show, payment_issue, other`. Also confirmed: only the reporter can cancel a dispute (`"Only the reporter can cancel a dispute"`), only an `open` dispute can be cancelled, cancelling sets `status` to `closed` (not a separate `cancelled` value), and a second dispute on the same booking by the same reporter is rejected with `"You have already raised a dispute for this booking"`.
- Tested: 2026-09-29
