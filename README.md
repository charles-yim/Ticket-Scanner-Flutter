# Ticket Scanner Flutter
Scans given ticket using firebase_ml_vision to read and interpret text from camera. Designed specifically for custom tickets but could be modified.
Interprets the following:
* Customer/Name
* Tel
* Address
* Tips
* Subtotal
* VAT
* Total
* Delivery/Pickup

## Build Requirements:
* [Camera Plugin](https://pub.dev/packages/camera)
* [ML Kit Vision for Firebase](https://pub.dev/packages/firebase_ml_vision)

## Build:
To build the app as an app bundle:
```
flutter build appbundle
```
To build the app as an apk:
```
flutter build apk
```
