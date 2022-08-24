import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

/// Test store that uses `dart:io` to perform CRUD operations on tests, reports,
/// and images.  This is not supported on the web platform, and all functions
/// are set to no-op when on web to prevent compile issues if accidentally
/// included in a web build.
class IoTestStore {
  IoTestStore({
    this.imagePath = 'output/images',
    this.reportPath = 'output/reports',
    this.testPath = 'output/tests',
  });

  static final Logger _logger = Logger('IoTestStore');

  final String imagePath;
  final String reportPath;
  final String testPath;

  /// When running on a non-web platform this will write the golden images from
  /// the given [report] to the file system using the [imagePath].
  Future<void> goldenImageWriter(TestReport report) async {
    if (kIsWeb) {
      _logger.warning(
        '[IoTestStore] -- goldenImageWriter not supported on web',
      );
    } else {
      var path = imagePath;
      if (report.suiteName?.isNotEmpty == true) {
        path = '${path}/_Suite_${report.suiteName}_';
      } else {
        path = '$path/';
      }

      path = '${path}Test_${report.name}_';

      for (var image in report.images) {
        if (image.goldenCompatible) {
          var file = File('${path}${image.id}.png');
          file.createSync(recursive: true);

          var data = image.image!;
          file.writeAsBytesSync(data);

          final testImageCodec = await instantiateImageCodec(data);
          final testImage = (await testImageCodec.getNextFrame()).image;

          _logger.info(
            '[IMAGE]: ${file.absolute.path} -- (${testImage.width}, ${testImage.height})',
          );
        }
      }
    }
  }

  /// When running on a non-web platform this will read the images from the file
  /// system using the [imagePath].
  Future<Uint8List?> testImageReader({
    required TestDeviceInfo deviceInfo,
    required String imageId,
    String? suiteName,
    required String testName,
    int? testVersion,
  }) async {
    Uint8List? image;

    if (kIsWeb) {
      _logger.warning(
        '[IoTestStore] -- testImageReader not supported on web',
      );
    } else {
      var path = imagePath;

      if (suiteName?.isNotEmpty == true) {
        path = '${path}/_Suite_${suiteName}_';
      } else {
        path = '$path/';
      }

      path = '${path}Test_${testName}_$imageId.png';

      try {
        image = File(path).readAsBytesSync();
      } catch (e) {
        // no_op
      }
    }

    return image;
  }

  /// When running on a non-web platform this will read the tests from the file
  /// system using the [testPath].
  Future<List<PendingTest>?> testReader(
    BuildContext? context, {
    String? suiteName,
  }) async {
    var pendingTests = <PendingTest>[];

    if (kIsWeb) {
      _logger.warning(
        '[IoTestStore] -- testReader not supported on web',
      );
    } else {
      var path = testPath;

      if (suiteName != null) {
        path = '$path/$suiteName';
      }

      var files = Directory(path).listSync(recursive: true);

      for (var file in files) {
        try {
          if (file is File && file.path.endsWith('.json')) {
            var data = json.decode(file.readAsStringSync());

            var test = Test.fromDynamic(data);
            pendingTests.add(PendingTest.memory(test));
          }
        } catch (e) {
          // no-op
        }
      }
    }

    return pendingTests;
  }

  /// When running on a non-web platform this will write the [report] to the
  /// file system using the [reportPath].
  Future<bool> testReporter(TestReport report) async {
    var result = false;
    if (kIsWeb) {
      _logger.warning(
        '[IoTestStore] -- testReader not supported on web',
      );
    } else {
      var path = reportPath;

      if (report.suiteName != null) {
        path = '$path/${report.suiteName}';
      }

      path = '$path/${report.name}.json';

      var encoder = JsonEncoder.withIndent('  ');
      var file = File(path);

      file.createSync(recursive: true);
      file.writeAsStringSync(encoder.convert(report.toJson()));
      _logger.info('[REPORT]: ${file.absolute.path}');
      result = true;
    }
    return result;
  }

  /// When running on a non-web platform this will write the [test] to the file
  /// system using the [testPath].
  Future<bool> testWriter(
    BuildContext context,
    Test test,
  ) async {
    var result = false;
    if (kIsWeb) {
      _logger.warning(
        '[IoTestStore] -- testReader not supported on web',
      );
    } else {
      var path = testPath;

      if (test.suiteName != null) {
        path = '${path}/${test.suiteName}_';
      } else {
        path = '$path/';
      }

      path = '$path${test.name}.json';

      var encoder = JsonEncoder.withIndent('  ');
      var file = File(path);

      file.createSync(recursive: true);

      var testData = test
          .copyWith(
            steps: test.steps
                .map((e) => e.copyWith(image: Uint8List.fromList([])))
                .toList(),
            timestamp: DateTime.now(),
            version: test.version,
          )
          .toJson();

      file.writeAsStringSync(encoder.convert(testData));
      _logger.info('[REPORT]: ${file.absolute.path}');
    }
    return result;
  }
}
