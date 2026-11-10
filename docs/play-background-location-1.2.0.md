# Play Console: background location declaration (1.2.0+9)

Needed as long as the bundle contains `ACCESS_BACKGROUND_LOCATION`.
Play Console → Uygulama içeriği → Konum izinleri. Google requires the video to
show the prominent disclosure, so the video filed on 16 July 2026 must be replaced.

## App purpose (Uygulamanın amacı, max 500)

FireWatch TR shows satellite heat detections from NASA FIRMS and a fire risk index for Türkiye, and alerts users about detections near them or near places they follow. Detections are not confirmed fires; the app tells users to call 112 if they see a fire.

Türkçe: FireWatch TR, NASA FIRMS uydu ısı tespitlerini ve Türkiye için yangın riski endeksini gösterir; kullanıcıları yakınlarındaki veya takip ettikleri yerlerin yakınındaki tespitler için uyarır. Tespitler doğrulanmış yangın değildir; uygulama yangın görülürse 112'nin aranmasını söyler.

## Background feature (Konum erişimi, max 500)

Automatic monitoring is off by default and is started by the user on the Notifications screen. When the app is closed or not in use, a periodic background task reads the device location and compares it, on the phone, with recent satellite heat detections within 50 km. If any are found, it shows a local notification. During these checks the location is not sent to our server, stored or shared.

Türkçe: Otomatik tarama varsayılan olarak kapalıdır ve kullanıcı tarafından Bildirimler ekranında başlatılır. Uygulama kapalıyken veya kullanılmıyorken düzenli bir arka plan görevi cihaz konumunu okur ve telefonda 50 km içindeki güncel uydu ısı tespitleriyle karşılaştırır. Tespit varsa yerel bildirim gösterir. Bu denetimlerde konum sunucumuza gönderilmez, saklanmaz ve paylaşılmaz.

## Video (30 seconds or less, English app language, unlisted YouTube link)

Start from a fresh install, so the first disclosure appears.

1. 0-3 s: open the app, choose English, tap Skip on the intro.
2. 3-9 s: stay on "We collect your location data". Scroll slowly if needed, so the "when the app is closed or not in use" sentence is readable.
3. 9-12 s: tap "I agree". The system prompt appears. Choose "While using the app".
4. 12-14 s: on the notification page tap "No, thanks". Close the tips.
5. 14-17 s: tap the bell, scroll to Notification Tools, tap "Start Auto Monitoring".
6. 17-22 s: stay on "Location data in the background" so all of it is readable. Tap "I agree".
7. 22-25 s: on the system screen choose "Allow all the time", then go back.
8. 25-30 s: show "Monitoring On" and the status line. Tap "Stop Auto Monitoring" if time allows.
