//using the code from https://gist.github.com/ProjectInitiative/1051cf9b368d60f20a2b1062ec269579
// FlutterLicense utility class
import 'package:flutter/foundation.dart';

class FlutterLicense extends LicenseEntry {
  final packages;
  final paragraphs;

  FlutterLicense(this.packages, this.paragraphs);
}

// Actually add the licenses
Stream<LicenseEntry> licenses() async* {
  yield FlutterLicense(['Swimming-Pool Icon'],
      [LicenseParagraph('App-Icon made by Freepik from www.flaticon.com', 0)]);
}

void addLicenses() {
  LicenseRegistry.addLicense(licenses);
}
