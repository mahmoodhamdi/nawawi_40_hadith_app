# Keystore setup — Android release signing

This document walks through generating, configuring, and protecting the
Android signing keystore. The same keystore is used for every release
on a given Play Store listing — **losing it means you can never publish
an update to that listing again**. Treat it as you would a master
password.

---

## Prerequisites

- Java JDK 17 (the `keytool` command).
- This project cloned locally with `flutter pub get` complete.
- A secure place to store the resulting keystore file (a password
  manager that allows file attachments, an encrypted backup volume, or
  similar).

## Step 1 — Generate the keystore

From the **project root**:

```bash
keytool -genkey -v \
  -keystore android/app/upload-keystore.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload
```

You'll be prompted for:
- A **keystore password** — pick a long random string. Save it.
- A **key password** — usually the same as the keystore password. Save.
- Identity fields (CN / OU / O / L / ST / C). For an Islamic open-source
  app, suggestions:
  - CN: Mahmood Hamdi (your real name as the responsible party)
  - OU: Nawawi 40 Hadith App
  - O: (your organisation, or leave blank → press Enter)
  - L: (city)
  - ST: (state/province)
  - C: (2-letter country code, e.g. EG, SA, US)

The file `android/app/upload-keystore.jks` is now created. It is
**already in `.gitignore`** — verify it never gets committed.

## Step 2 — Create `android/key.properties`

Copy the template:

```bash
cp android/key.properties.example android/key.properties
```

Edit `android/key.properties` with the **real passwords** you chose:

```
storePassword=<the keystore password>
keyPassword=<the key password>
keyAlias=upload
storeFile=../app/upload-keystore.jks
```

This file is **also in `.gitignore`** — verify with:

```bash
git status --ignored android/key.properties android/app/upload-keystore.jks
```

Both should appear as "ignored".

## Step 3 — Verify the signing config is wired

`android/app/build.gradle.kts` already contains:

```kotlin
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String?
                keyPassword = keystoreProperties["keyPassword"] as String?
                storeFile = keystoreProperties["storeFile"]?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as String?
            }
        }
    }
    buildTypes {
        release {
            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
            }
            // ...
        }
    }
}
```

No edits needed.

## Step 4 — Build a signed release

```bash
flutter build apk --release
flutter build appbundle --release
```

You can verify the APK is signed:

```bash
# Show signers (should NOT say "(no signers)")
$ANDROID_HOME/build-tools/35.0.0/apksigner verify --print-certs \
  build/app/outputs/flutter-apk/app-release.apk
```

## Step 5 — Securely back up the keystore

Treat the keystore the same as the Play Store account password:

- ✅ Save in a password manager that supports file attachments
  (1Password, Bitwarden Premium, KeePassXC)
- ✅ Or save in an encrypted disk image (LUKS, Veracrypt, macOS DMG)
- ✅ Make at least one offline backup on a separate physical device
- ❌ **NEVER** commit it to git, even in a private repo
- ❌ **NEVER** email it or paste it in chat
- ❌ **NEVER** store it in unencrypted cloud storage

If you lose the keystore, **your Play Store listing is effectively dead**.
You'd have to create a new listing with a new package name and ask all
users to migrate. Don't lose it.

## Step 6 — Set up Play App Signing (recommended)

Once you've uploaded the AAB to Play Console, enable **Play App Signing**:
this means Google holds the *final* distribution key on their side, and
you only need to keep your *upload* key safe. If you lose the upload
key in the future, Google can reset it for you (their final key stays
the same, so installs continue to work).

To enable: Play Console → Setup → App integrity → App signing → Enable.

## Step 7 — CI keystore (optional)

For automated releases via GitHub Actions:

1. Base64-encode the keystore:
   ```bash
   base64 -w0 < android/app/upload-keystore.jks > /tmp/keystore.b64
   ```

2. In the GitHub repo settings → Secrets and variables → Actions, add:
   - `ANDROID_KEYSTORE_BASE64`: contents of `/tmp/keystore.b64`
   - `ANDROID_KEYSTORE_PASSWORD`: the storePassword
   - `ANDROID_KEY_PASSWORD`: the keyPassword
   - `ANDROID_KEY_ALIAS`: `upload`

3. Update `.github/workflows/release.yml` to decode the keystore and
   write a `key.properties` at the start of the build job, then run the
   normal `flutter build appbundle --release`.

A reference snippet for the CI workflow is in `.github/workflows/release.yml`.
Currently the workflow builds unsigned binaries — wire the secrets when
you're ready to automate signing.

---

## Summary checklist

- [ ] Keystore generated at `android/app/upload-keystore.jks`
- [ ] Passwords saved in password manager
- [ ] `android/key.properties` created with real values
- [ ] `git status --ignored` shows both files as ignored
- [ ] `flutter build apk --release` produces a signed APK
- [ ] `apksigner verify` shows the cert chain
- [ ] At least one offline backup of the keystore + passwords exists
- [ ] Play App Signing enabled on the Play Console listing
- [ ] CI secrets set (if using automated releases)

اللهم احفظ هذا العمل من أن تذهب جهوده هباءً بسبب فقد مفتاح.
