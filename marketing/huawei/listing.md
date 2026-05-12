# Huawei AppGallery Listing

Huawei AppGallery is the primary store for Huawei devices (which lack Google
Play Services). This is critical for the MENA market where Huawei has
significant share. The app works without Google Play Services because it uses
no Firebase, no Google Maps, no Google Sign-In — it's pure offline.

## Submission requirements

- **Developer account**: Free at https://developer.huawei.com
- **APK** (universal, not AAB — AppGallery accepts both but APK is simpler):
  - Path after build: `.agent/release_artifacts/v<version>/nawawi-40-v<version>-universal.apk`
- **Listings**: same content as Play Store. AppGallery accepts AR, EN, ID, UR.
- **Screenshots**: same sets as Play Store work; AppGallery requires:
  - Phone: 1080 × 1920 portrait (3-8 images)
  - Tablet: 1200 × 1920 or 1920 × 1200
- **Feature graphic**: 1080 × 720 PNG
- **App icon**: 216 × 216 PNG (round masked)

## Category
- Primary: Education > Religion
- Secondary: Books & Reference

## Content rating
- IARC: Everyone / 3+
- No restricted content

## Permissions justifications (in submission form)
- `POST_NOTIFICATIONS`: Daily hadith reminder feature
- `SCHEDULE_EXACT_ALARM`: Reliable scheduling for daily reminder
- `VIBRATE`: Tactile feedback for notification
- `RECEIVE_BOOT_COMPLETED`: Re-schedule reminders after device reboot

## Privacy declaration
- Personal data collected: **None**
- Permissions used for the user-facing reminder feature only
- All data stays on the device
- Privacy policy URL: https://github.com/mahmoodhamdi/nawawi_40_hadith_app/blob/main/PRIVACY.md

## Localization
Submit listings in (priority order): AR, EN, ID, UR. Falling back to EN is
fine if Huawei doesn't have all locales. Most Huawei MENA users will see AR
by default.

## QR code
Once submitted, the QR code at `appgallery.huawei.com/app/<APPID>` is what
to print on mosque posters for Huawei users.
