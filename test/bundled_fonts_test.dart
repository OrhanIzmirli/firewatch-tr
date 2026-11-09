// IBM Plex must render offline: every weight/style the app asks for has to
// resolve to a bundled file, with runtime fetching off as in main().
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('main() disables runtime font fetching', () {
    expect(File('lib/main.dart').readAsStringSync(), contains('GoogleFonts.config.allowRuntimeFetching = false;'));
  });

  test('every IBM Plex weight and style used by the app loads from assets', () async {
    // Weights used across lib/ (w400–w800; Plex tops out at 700, which w800
    // resolves to), the Material text theme (400/500), italics (400), and
    // the mono readouts.
    // google_fonts swallows a missing asset and only prints the error, so
    // capture what the loads print.
    final printed = <String>[];
    await runZoned(
      () async {
        for (final w in [FontWeight.w400, FontWeight.w500, FontWeight.w600, FontWeight.w700, FontWeight.w800]) {
          GoogleFonts.ibmPlexSans(fontWeight: w);
          GoogleFonts.ibmPlexMono(fontWeight: w);
        }
        GoogleFonts.ibmPlexSans(fontStyle: FontStyle.italic);
        GoogleFonts.ibmPlexSansTextTheme(ThemeData.light().textTheme);
        await GoogleFonts.pendingFonts();
      },
      zoneSpecification: ZoneSpecification(print: (self, parent, zone, line) => printed.add(line)),
    );
    expect(printed.where((l) => l.contains('unable to load font')), isEmpty);
  });

  test('the bundled files are the ones pubspec ships, with the licence', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('- assets/fonts/'));
    final names = Directory('assets/fonts').listSync().map((f) => f.uri.pathSegments.last).toSet();
    expect(names, containsAll(<String>[
      'IBMPlexSans-Regular.ttf', 'IBMPlexSans-Italic.ttf', 'IBMPlexSans-Medium.ttf',
      'IBMPlexSans-SemiBold.ttf', 'IBMPlexSans-Bold.ttf',
      'IBMPlexMono-Regular.ttf', 'IBMPlexMono-Medium.ttf', 'IBMPlexMono-SemiBold.ttf', 'IBMPlexMono-Bold.ttf',
      'OFL.txt',
    ]));
  });
}
