# Disputes API — two bugs found during integration

**Re:** `disputes-api-answers.md`
**Status: ✅ all three resolved, re-tested live on production 2026-10-01.** Both bugs are fixed and the `/my` semantics question is answered — client updated to match. Thanks for the detailed writeup, especially flagging the pre/post-rental photos 403 before we hit it independently.

**Context:** integrated the `08 · Disputes` Postman collection into the Flutter app and tested every renter/owner-facing endpoint live against production (`https://au2p3vkiqi.us-east-1.awsapprunner.com`), not just against the docs. Original report below, kept for the record, with resolution notes added to each section.

---

## 1. ✅ RESOLVED — evidence images now load (signed URLs)

Confirmed live: `evidence[]` URLs are now presigned and actually fetchable.

```bash
curl -s -o /dev/null -w "%{http_code}\n" "<fresh evidence URL from GET /disputes/:id>"
# → 200 (was 403)
```

Also confirmed the new `evidenceUrlsExpireAt` field is present alongside `evidence[]` on `GET /disputes/my`, `GET /disputes/:id`, and the `POST /disputes/:id/evidence` response — all three checked directly. **Client change made:** the app never persisted these URLs to begin with (each screen re-fetches the dispute fresh on open), so no caching fix was needed — we just added `evidenceUrlsExpireAt` to our model for completeness. Kept the existing fallback error icon for the rare case a URL goes stale mid-session.

One thing we hadn't realized until testing the fix: **both parties can add evidence to an open dispute**, not just the reporter (confirmed live — the reported-against account successfully uploaded evidence and got `myRole: "reported_against"` back). Our UI previously only showed "Add Evidence" to the reporter; now it shows to both parties while open, and only "Cancel Dispute" stays reporter-only (also re-confirmed: reported-against still gets `"Only the reporter can cancel a dispute"`).

<details>
<summary>Original report (for the record)</summary>

`POST /disputes/:id/evidence` accepted uploads fine, but the returned `evidence[]` URL 403'd for everyone, including no-auth requests — compared against `item-photos/` and `profile-photos/` in the same bucket, both public-read and working.
</details>

---

## 2. ✅ RESOLVED — `?status=` now filters, and rejects bad values

```bash
curl "https://au2p3vkiqi.us-east-1.awsapprunner.com/api/v1/disputes/my?status=open&page=1&limit=10" -H "Authorization: Bearer <token>"
# → only open disputes now (previously returned everything, including closed ones)

curl "https://au2p3vkiqi.us-east-1.awsapprunner.com/api/v1/disputes/my?status=bogus&page=1&limit=10" -H "Authorization: Bearer <token>"
# → 400, "\"status\" must be one of [open, under_review, resolved_for_renter, resolved_for_owner, resolved_mutually, closed]"
```

Both re-tested directly. **Client change made:** our `DisputeStatuses` model now also names the four admin-only outcomes (`under_review`, `resolved_for_renter`, `resolved_for_owner`, `resolved_mutually`) alongside `open`/`closed`, since those are now confirmed-valid values a user's own dispute could carry. Our Open/Closed tabs are unchanged — a dispute in one of the four admin states still displays correctly via our existing "prettify unknown status" fallback, so we didn't add dedicated tabs for them.

<details>
<summary>Original report (for the record)</summary>

`status=open` and `status=closed` returned byte-identical, unfiltered results — including a `status=open` request returning a dispute whose real status was `closed`.
</details>

---

## 3. ✅ RESOLVED — "either party" confirmed and implemented

Re-tested with the same two-account setup as the original report:

```bash
GET /disputes/my  (as A)
# → now returns BOTH disputes: the one A filed (myRole: "reporter")
#   AND the one B filed against A (myRole: "reported_against")
```

Also confirmed: `?role=against` and `?role=reporter` both filter correctly, `reportedBy`/`reportedAgainst` are now both fully populated objects on the list endpoint (previously `reportedBy` was a bare id string there), and `myRole` is present on list/detail/evidence-upload responses — not yet confirmed on the create/cancel action responses, so the client falls back to an id comparison when `myRole` is absent rather than assuming it's always there.

**Client change made:** `DisputeController.isReporter()` now reads `dispute.myRole` directly instead of comparing ids, with the id-comparison kept only as a fallback. Card labels ("You reported X" / "X reported you") now work correctly for disputes filed against the current user, which simply didn't show up in the list before.

<details>
<summary>Original report (for the record)</summary>

`GET /disputes/my` only returned disputes where the caller was `reportedBy`, despite being documented as "disputes I am part of" — disputes filed against a user were invisible with no way to discover their id.
</details>

---

## 4. Noted, not actioned: known issue nearby

Booking condition photos (`bookings/:id/pre-rental` / `post-rental`) are confirmed still 403ing for the same original reason (unsigned raw URLs, no public ACL on that prefix). Not re-testing or filing separately since you already flagged it as known and tracked — just confirming we read that note and won't file a duplicate report if/when we notice it independently in that part of the app.

---

## Appendix: environment

- Backend: `https://au2p3vkiqi.us-east-1.awsapprunner.com/api/v1`
- Test accounts: `zaindev2@yopmail.com` (dispute `6abb96375fad339ccdfa5a2e`, reason `item_damaged`, `closed`, `myRole: reporter` for this account), `v8fujw3ene@olipii.com` (dispute `6abb96bf5fad339ccdfa5a6b`, reason `item_not_as_described`, `open`, `myRole: reporter` for this account — and `reported_against` for the other)
- Shared booking used for both: `6abb8c2b5fad339ccdfa58c2`
- Confirmed while testing, not a bug: `reason` enum is `item_damaged, item_not_returned, item_not_as_described, late_return, no_show, payment_issue, other`; `description` must be 20–2000 characters (client-side minimum bumped from 10 to 20 to match, `maxLength: 2000` added to the input); only the reporter can cancel, only while `open`, cancelling sets `closed` (no separate `cancelled` value); one dispute per booking per reporter (both parties can each file their own on the same booking).
- Original test pass: 2026-09-29. Fix re-verification pass: 2026-10-01.
