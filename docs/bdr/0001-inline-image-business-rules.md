# BDR 0001: Inline image business rules and calibrations

- Status: Accepted
- Date: 2026-07-23

## User outcome

A user editing a note can drag one or more images into the note field. Memoly inserts each uploaded image as Markdown at the current caret position and shows an upload placeholder while the server validates, stores, and resizes it.

Collections are also valid image owners through the API so collection covers, galleries, or future collection Markdown can use the same storage policy without a schema redesign.

## Deliberate rules

| Rule | Calibration | User-facing result |
| --- | --- | --- |
| Accepted formats | PNG, JPG/JPEG, WebP, GIF | Other files receive a clear rejection |
| Maximum size | 10 MiB (10 × 1024 × 1024 bytes), inclusive | A file over the limit is not stored |
| Responsive sizes | 1600, 960, and 480 pixel bounding boxes | Aspect ratio is preserved; images are not cropped |
| Inline default | Medium (960 px maximum dimension) | Notes balance readability, bandwidth, and sharpness |
| Multiple drops | Supported | Each accepted file gets its own Markdown entry |
| Invalid files in a mixed drop | Rejected individually | Valid files may continue uploading |
| Save during upload | Disabled | A note cannot persist temporary upload placeholders |
| Attachment owners | Only records owned by the authenticated user | Cross-account attachment is forbidden |
| Deletion | Purge attachment and stored derivatives | Storage does not intentionally outlive its owner |

## Security calibration

Object keys provide at least 448 random bits across three path components. This prevents practical guessing or directory enumeration and deliberately avoids customer or content metadata in object names.

The configured R2 domain is public, so possession of a complete URL grants read access. Unguessability reduces discovery risk but does not revoke a URL that has already leaked. If private-note images later require revocable authorization, this decision must be revisited in favor of a private bucket plus short-lived signed URLs or an authenticated image proxy.

R2 access keys remain server-side environment secrets. Browser code only talks to Memoly's same-origin upload route.

## Operational calibration

- Development defaults to the supplied `r2.dev` domain and can opt into local disk with `ACTIVE_STORAGE_SERVICE=local`.
- Production must set `R2_PUBLIC_DOMAIN` to the intended public custom CDN/domain before launch.
- The S3 endpoint environment value excludes the bucket suffix.
- Content type is detected from file bytes; the client-provided MIME header alone is not trusted.
- Errors remove any temporary Markdown placeholder. A successfully uploaded image is retained if the user later cancels note editing; orphan cleanup is a separate product policy if that behaviour becomes costly.

## Success measures

- Supported images at or below 10 MiB upload and render inline.
- Unsupported or oversized files never create an Active Storage blob.
- Every successful upload has three stored variants.
- No stored key contains a user ID, record ID, label, original filename, or predictable counter.
- Users cannot attach to another user's note or collection.
