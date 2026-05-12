# F-Droid Submission

F-Droid is the leading free-and-open-source Android app catalog. Inclusion
gives the app reach to privacy-conscious users globally who avoid Google
Play Services.

## Anti-features audit (F-Droid policy)

All checks pass:

| Anti-feature | Present? |
|---|---|
| Ads (any kind) | No |
| Tracking (analytics, ad SDKs, telemetry) | No |
| NonFreeNet (depends on non-free services) | No |
| NonFreeDep (non-free libraries) | No — all pubspec deps are open-source |
| NonFreeAdd (recommends non-free addons) | No |
| KnownVuln (known vulnerabilities) | Check `dart pub audit` before submission |
| UpstreamNonFree | No |

## Submission steps

1. **Fork** https://gitlab.com/fdroid/fdroiddata
2. Copy `metadata.yml` to `metadata/com.mahmoodhamdi.hadith_nawawi_audio.yml`
3. Open a merge request titled: `New app: Forty Hadith Nawawi`
4. Address reviewer comments (usually about reproducible builds)
5. Once merged, the app appears at:
   `https://f-droid.org/packages/com.mahmoodhamdi.hadith_nawawi_audio/`

## Reproducibility note

F-Droid builds from source on their infrastructure. Ensure:
- `pubspec.lock` is committed (it is)
- All dependency versions are pinned
- No build steps require network access beyond `flutter pub get`

## Application ID

The current `applicationId` in `android/app/build.gradle` should be
verified. If it includes a placeholder like `com.example.*`, change it
to `com.mahmoodhamdi.hadith_nawawi_audio` before F-Droid submission —
this is the package ID that F-Droid will reference forever.
