# Remorder.
## Introduction.
This application allows the user to connect the Remo device with an Android device, start a data transmission, visualise the data on a cartesian chart and optionally store the recorded data in the local filesystem.
The application was built using [Dart & Flutter](https://flutter.dev/) and using the BLoCs pattern via the [bloc library](https://bloclibrary.dev/#/). It could potentially be deployed on all platforms supported by Flutter, however it is currently constrained by its Bluetooth usage provided by the [flutter_bluetooth_serial library](https://pub.dev/packages/flutter_bluetooth_serial), which currently only supports Android.
## Roadmap.
You can find the planned and under development list of features [here](https://gitlab.com/artificial-physiology/remorder/-/boards).
## Installing the application.
The application is available for internal and closed tests on Google Play Store.
To accept the invitation for the beta you have to follow one of these links:
- [Internal tests](https://play.google.com/apps/internaltest/4699958797245170877).
- [Link web for closed tests](https://play.google.com/apps/testing/com.morecognition.remorder_flutter).
- [Android link for closed tests](https://play.google.com/store/apps/details?id=com.morecognition.remorder_flutter).

## Building the application from source.
After [setting up your environment](https://flutter.dev/docs/get-started/install) you can test the application by simply writing `flutter run` on the console or you can build it by writing `flutter build apk` (more about this [here](https://flutter.dev/docs/deployment/android)). The master branch is updated with the last stable version, the development branch contains the latest implemented features and other versions can be found in their release branches or here [here](https://gitlab.com/artificial-physiology/remo_physiotherapy/-/releases).
