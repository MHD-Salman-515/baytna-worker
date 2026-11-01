# Baytna — Worker App

The app housekeepers use on the Baytna home-services marketplace (Syria, Iraq).
Built with Flutter and BLoC. Arabic is the primary language (RTL by default) and
English is secondary. The Arabic copy addresses the worker in the feminine.

> **Status (step 2, the working half):** on top of the foundation (login,
> onboarding, status screen): her services and pricing, weekly availability,
> incoming scheduled bookings, the job lifecycle, and her wallet. Not yet:
> INSTANT offers and presence, live tracking, push, reviews, panic.

The architecture mirrors [baytna-customer](https://github.com/MHD-Salman-515/baytna-customer).
Its README covers the shared request pipeline and session handling in depth.
This document focuses on what is specific to the worker app.

- **Backend (staging):** `https://baytna-api-z7v9.onrender.com/api/v1`
- **Swagger:** https://baytna-api-z7v9.onrender.com/docs. It documents request
  bodies only. Response shapes were probed live; see [Backend notes](#backend-notes).

---

## The one rule: status is the spine

Holding the `WORKER` role gives her **no** capability.
`verificationStatus == APPROVED` is the only gate. The app fetches
`GET /workers/me/profile` at launch, and the router decides where she can go
from that status. The policy is a pure function,
[`appRedirect`](lib/core/router/app_redirect.dart), tested in
[app_redirect_test.dart](test/core/router/app_redirect_test.dart):

| State | Reachable |
|---|---|
| signed out | `/auth/*` |
| signed in, profile loading or failed | `/splash` (shows retry; never assumes approved) |
| never applied | `/apply` |
| `DRAFT`, `REJECTED` | `/status`, `/status/profile`, `/status/documents` |
| `PENDING_REVIEW`, `SUSPENDED`, unknown value | `/status` |
| `APPROVED` | everything except auth, splash, apply and the onboarding steps |

Non-approved states use an **allow-list**, so a route added later (such as
`/bookings`) is unreachable until she is approved, without anyone remembering
to guard it.

`financialStatus` is **independent** of `verificationStatus`: a verified worker
can be financially suspended. The two appear as separate rows with separate
badges ([AccountStandingCard](lib/features/worker/presentation/widgets/account_standing_card.dart))
and are never merged into a single "account status".

**Two independent gates decide what she can do**, and clearing one never clears
the other: `verificationStatus` must be APPROVED (the router enforces it) and
`financialStatus` must be ACTIVE. `WorkerProfile.canTakeNewWork` is the check
for NEW work only. A financially suspended worker can't accept, but **every
step of a job she already holds keeps working**, and she can still reach her
wallet to settle. `booking_detail_screen_test.dart` pins this per status.

### Onboarding flow

1. **Sign in** with phone + OTP, the same flow as the customer app. A new account comes back as `CUSTOMER` only.
2. **Apply** with `POST /workers/me/apply`. The WORKER role lives **in the JWT**, and
   until the token is re-minted every other `/workers/me` route answers
   **403 "Insufficient role"**. A 403 doesn't trigger the 401 refresh path, so
   `WorkerRepositoryImpl.apply()` refreshes the token **explicitly** through the
   single-flight `TokenRefresher` and checks that the new token carries `WORKER`.
   On launch, if the account has the role but the token doesn't (for example, she
   applied on another device), the app refreshes before loading the profile.
3. **Profile:** bio `{ar, en}`, years of experience, languages, city and service
   areas. Cities come from `GET /cities?countryId=` for *her* country.
4. **Documents:** national ID front and back, and the criminal-record certificate
   (which needs an expiry date). See below.
5. **Submit** from the status screen. The button is enabled only when the
   checklist is complete.
6. **Status screen:** her home until approval. It shows:
   - `DRAFT`: what's missing
   - `PENDING_REVIEW`: how long she has been waiting (from `submittedAt`)
   - `REJECTED`: the reason and which documents to replace
   - `SUSPENDED`: a message to contact support
   - `APPROVED`: a "continue" button to the placeholder home

   The screen refreshes on pull-to-refresh, when the app returns to the
   foreground, when she comes back from a sub-screen, and every 2 minutes while
   she is pending. An approval made in the admin console therefore appears on
   its own.

### Documents: handled with care

- **Picking:** camera, gallery or PDF file. Images are downscaled on the device
  (2400 px, JPEG quality 85) to stay well under 5 MB.
- **Validated before upload:** the real type is checked from **magic bytes**
  (JPEG/PNG/PDF, as the backend does), size must be ≤ 5 MB, and the criminal
  record needs an expiry date **of tomorrow or later**. The backend accepts a past
  date, but then treats the document as missing at submit.
- **Nothing outlives the screen:**
  - Bytes are held in memory only.
  - Every temporary copy the picker plugins write to the app cache is deleted
    after each pick and again at startup ([PlatformDocumentPicker](lib/features/documents/data/datasources/platform_document_picker.dart)).
  - The preview is evicted from Flutter's `ImageCache` on dispose.
  - Nothing is saved to the gallery.
  - Uploads use a neutral filename (`national_id_front.jpg`), never her original one.
- **Status per document:** a badge for missing / pending / approved / rejected /
  expired, plus the rejection reason. The newest upload of a type is the one that counts.
- **Progress, and a retry that never duplicates:** the backend keeps every
  upload and doesn't deduplicate.
  - Before the first attempt, the app records which document ids exist, using a
    fresh list from the server.
  - If an attempt ends ambiguously (timeout, dropped connection, 5xx), and on
    every retry, the app re-lists and **adopts** a new document of that type
    instead of sending the file again. If it can't check, it doesn't resend.
  - A 504 is never auto-retried for uploads.
  - After a replacement lands, older uploads of that type are deleted.

---

## The working half: decisions that matter

- **Prices are ranges first.** The admin's min/max from `GET
  /service-pricing-rules` appears as soon as she picks a pricing model, before
  she types. Only `allowedPricingTypes` are offered. The same checks run
  client-side (`OfferingValidator`), and a server refusal is parsed for its
  range. Currency is shown as fixed and is never sent on PATCH.
- **The country's clock, not the phone's.** Availability times are `HH:mm` text
  and are never turned into a `DateTime`. The schedule names the zone and shows
  the time there now. Booking times use `CountryTime`.
- **Availability is intent.** The switch says it isn't approval, and says when
  it has no effect.
- **The decision is honest.** Before she accepts, the backend sends only the
  landmark, so the card leads with it and says what's hidden. A true distance
  is impossible (see [Backend gaps](#backend-gaps)). It shows "in your city", or
  km between CITY CENTRES, labelled as such.
- **Deadlines tick.** `responseDeadline` counts down live. At zero the answer
  buttons go and the booking reloads.
- **One legal step.** `JobAction.next(status)` is the only button offered, so
  she can't tap into a 400. If her screen was stale, the real status is parsed
  from the backend's error, the booking reloads, and she's told why in Arabic.
- **A lost response is never replayed.** POSTs aren't idempotent here (a repeat
  is a 400), so after a timeout, dropped connection or 5xx the booking is
  re-read: if it reached the target status, that's a success. On `complete`
  this is real money.
- **Her list is the only read.** There's no single-booking GET for workers, so
  `find` walks `/workers/me/bookings`, and every step re-reads from there.
- **Estimate, then final.** Up to completion the figure is labelled an estimate
  and says how the real one is worked out. After, the final figure sits beside
  the estimate with the reason they differ and the commission taken. The app
  computes no money: every figure comes from the server.
- **Complete is a swipe.** `SwipeToConfirm`: a tap does nothing, an early release
  springs back, and screen readers get a labelled action.
- **Money is `int` + currency.** `Money` has no doubles. `moneyFromJson` THROWS
  on a fractional amount rather than round someone's pay. Amounts are shown as
  sent, in whole currency units, matching the customer app.
- **Wallet.** A negative balance is normal, so the card leads with room left
  before the floor and warns at `lowBalanceWarningThreshold`. Suspension is read
  from the profile, never inferred from the balance. Top-up is stated as
  staff-recorded; there's no button.
- **Finding new requests.** There's no push yet, so Jobs polls every 90 s and on
  resume. That's the seam for notifications.

---

## Run it

Requirements: Flutter 3.47 / Dart 3.13, an Android emulator or device.

```bash
cp secrets.example.json secrets.json   # paste the dev OTP key (same as the customer app)
flutter pub get
flutter run -d emulator-5556 --dart-define-from-file=secrets.json
```

> The staging server sleeps after inactivity (Render free tier). The first
> request can take **30–60 s**. A "server is waking up" banner shows meanwhile.

### Dev OTP key

This works exactly as in the customer app. `secrets.json` (gitignored) holds
`DEV_OTP_KEY`, and the OTP screen shows a debug-only "Autofill code (dev mode)"
button. The key and the button are **compiled out** of profile and release builds
([dev_otp.dart](lib/core/dev/dev_otp.dart)). To verify on Android:

```bash
echo '{"DEV_OTP_KEY":"CANARY-123"}' > /tmp/canary.json
flutter build apk --release --target-platform android-arm64 --dart-define-from-file=/tmp/canary.json
unzip -o -q build/app/outputs/flutter-apk/app-release.apk lib/arm64-v8a/libapp.so -d /tmp/apk
grep -c -a -e CANARY-123 -e last-otp -e x-dev-otp-key /tmp/apk/lib/arm64-v8a/libapp.so   # → 0
```

### Environments

| `--dart-define` | Default | Meaning |
|---|---|---|
| `APP_ENV` | `staging` | `staging` or `production` |
| `API_BASE_URL` | per env | Overrides the base URL. **Required for production** until it has a URL. |

### Tests

```bash
flutter analyze        # must stay at zero issues
flutter test           # unit + bloc tests, no network
dart run build_runner build --delete-conflicting-outputs   # after changing DI/models
```

**Read-only tour** of an approved worker on staging (saves nothing):
`integration_test/work_smoke_e2e_test.dart`.

**Full job** (`integration_test/job_e2e_test.dart`) MOVES REAL STATE: it accepts
a pending booking, completes it and charges commission. It needs a
PENDING_WORKER booking. See the file header for the command and
`E2E_WORK_SECONDS`.

**Live end-to-end onboarding** runs on an Android emulator against staging. It
signs in with a **new random number**, applies, fills the profile, uploads the
three documents, submits, and checks that the status screen shows
`PENDING_REVIEW`:

```bash
flutter drive -d emulator-5556 \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/onboarding_e2e_test.dart \
  --dart-define-from-file=secrets.json          # optional: --dart-define=E2E_PHONE=09…
```

Screenshots and the app's request log are written to `build/e2e_screenshots/`.
The system camera, gallery and file pickers can't be driven from a test, so the
E2E replaces **only** the `DocumentPicker` registration with one that returns
generated sample images and a PDF. Validation, blocs, upload, network and
backend are all real.

---

## Structure

```
lib/
  main.dart               DI → locale → WorkerBloc → AuthStarted → purge picker cache → runApp
  app.dart                MaterialApp.router; AuthBloc + WorkerBloc + LocaleCubit provided app-wide
  core/                   same layout as the customer app:
    config/ di/ error/ localization/ storage/ theme/ widgets/ dev/ utils/
    network/              + paged.dart (meta), upload_file.dart, replay.dart (FormData clone)
    format/ time/ geo/    Money, CountryTime, GeoPoint
    router/               app_routes.dart, app_redirect.dart (status policy), app_router.dart
  features/
    auth/                 phone + OTP, session (from the customer app)
    countries/  cities/   reference data (cities are paginated, need countryId)
    worker/               THE SPINE: WorkerProfile, statuses, WorkerRepository
                          (apply + explicit token refresh), app-wide WorkerBloc
    onboarding/           apply, profile form, status screen + submit, OnboardingChecklist
    documents/            entities, validator, requirements, repository (safe retry),
                          platform picker, DocumentsBloc, screen
    offerings/            her services: catalog, price rules, three pricing
                          models, OfferingValidator, the Work tab
    availability/         weekly windows + date exceptions, on the country's clock
    bookings/             requests, the job state machine (JobAction), lost-response
                          handling, countdown, swipe, money outcome
    wallet/               balance, WalletStanding, ledger
    home/                 the approved worker's tab shell
```

## Conventions

The customer app's conventions apply unchanged: data/domain/presentation layers,
`Result` + `guard`, sealed events and states, no Dio in features, no hard-coded
strings, `EdgeInsetsDirectional`, phone numbers LTR, and so on. See its README →
*Conventions for new features*. Additions for this app:

1. **A new screen that implies she can work** gets a new path. It is
   unreachable unless she is APPROVED; add nothing to the non-approved
   allow-lists. Gate NEW work on `canTakeNewWork`, and never a job in hand.
2. **Anything that changes her profile** (save, submit, apply) hands the returned
   profile to the WorkerBloc with `WorkerProfileChanged`. Screens never keep
   their own copy of her status.
3. **Never conflate** verification and financial status in copy, colour or logic.
4. **Paginated endpoints:** use `ApiClient.getPage`, which keeps `meta`.
5. **Non-idempotent uploads:** use `ApiClient.upload`, and design retries the way
   `DocumentRepositoryImpl.upload` does (check before resending).
6. **Personal documents:** keep them in memory only. Never cache to disk, log
   bytes or send original filenames.

---

## Backend notes

Observed against staging on 2026-10-26. None of this is in Swagger.

| Situation | Response |
|---|---|
| Worker route with a token minted before `apply` | **403** `"Insufficient role"`. Refresh to get `roles: [CUSTOMER, WORKER]` |
| `POST /workers/me/apply`, repeated | 201, same profile (idempotent); never resets PENDING/APPROVED |
| `GET /cities` without `countryId` | 400. With it: paginated, `meta` next to `data`, `limit` ≤ 100 |
| `POST /workers/me/profile` | Upsert; also **requires `countryId`**; `yearsOfExperience` must be an integer; accepts a city from **another country** (the app constrains it) |
| `bio` | Absent from the profile until set |
| Upload | multipart `type`, `expiresAt?`, `file`. 400 "File type not recognized" (checked by magic bytes); **413** above 5 MB; 400 if CRIMINAL_RECORD has no `expiresAt` |
| Upload with a past `expiresAt` | 201, but submit then fails as "missing or rejected" |
| Same file uploaded twice | **Two documents**; no dedupe. List is newest first |
| `checksum` | SHA-256 of the stored bytes. Images are re-encoded server-side, so it doesn't match the local file |
| `DELETE` while PENDING_REVIEW | 400 "Documents can only be deleted while the profile is DRAFT or REJECTED". 404 for an unknown id, **500** for a malformed id |
| Upload or profile edit while PENDING_REVIEW | Accepted by the backend; the app's router doesn't offer it |
| Submit, missing docs | 400 "Cannot submit for review: missing or rejected required documents (…)" |
| Submit twice | 400 "Cannot transition worker verification status from PENDING_REVIEW to PENDING_REVIEW" |
| `GET /workers/me/services` | `{ id, serviceId, pricingType, hourly{rate,minHours}\|null, bySize{tiers[{maxRooms,price}]}\|null, fixed{price}\|null, currency, isActive }` |
| Service refusals | 400 "price must be between 10000 and 50000 (inclusive)" (also "rate must be…") · 400 "BY_SIZE is not an allowed pricing type for COOKING (allowed: …)" · 409 "You already offer this service…" · 400 "currency must be SYP for your country" · PATCH `currency` → 400 "property currency should not exist" |
| Service changes | PATCH may switch `pricingType` · `isActive:false` keeps it listed · DELETE → 204, then 404 |
| Availability PUT | Both lists required. 400 on start ≥ end, overlaps, non-`HH:mm`. Several windows a day are fine. EXTRA needs times; BLOCKED drops them. **Past dates are accepted** |
| `PATCH /workers/me/availability` | Answers with the whole profile |
| `GET /workers/me/bookings` | Paged, `limit` ≤ 100. `status` is a **single** value. Before acceptance `address` is `{landmark}` only and `customerPhone` is null. `pricing` has `workerEarnings` (after commission), never `basePrice` |
| Illegal step | 400 "Cannot ACCEPT a booking from status EXPIRED to ACCEPTED (requires current status to be one of: PENDING_WORKER)". Cancel: ACCEPTED, ON_THE_WAY, ARRIVED only |
| `reject`, `cancel` | Without a reason: 400 "reason should not be empty" |
| `GET /workers/me/wallet` | `{ _id, workerProfileId, countryId, balance, currency }` only. **No floor, no status** |
| `GET /workers/me/wallet/entries` | Paged, `limit` ≤ 100, no `type` filter |

## Backend gaps

1. **No distance before acceptance.** The brief wanted distance prominent at
   decision time, but the worker projection has no pin and no distance, and the
   app has no location of hers this phase. Fix: add a server-computed
   `distanceKm` (from her home or last location to the pin, without exposing
   the pin).
2. **No single-booking GET for workers.** `GET /bookings/:id` is 404 for her and
   `/workers/me/bookings/:id` doesn't exist, so detail walks her list.
3. **Wallet lacks floor and status** (see above): the app joins country policy
   and the profile.
4. **Malformed ids return 500** (`DELETE /workers/me/documents/zzz`).
