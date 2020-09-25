## [1.2.6+2] - September 24th, 2020

* Actually checked in the `fromDynamic` on the `TestReport`


## [1.2.6+1] - September 24th, 2020

* Minor fix to pass `ignoreImageData` properly from `TestReport` to the `TestImage` list.


## [1.2.6] - September 24th, 2020

* Added in `_passing` variable so tests can "sense" when the previous steps are passing.
* Updated both `TestReport` and `TestImage` to utilize `JsonClass` to be self "json-able".
* Added optional `stopOnFirstFail` to `TestController` to stop tests on the first failed step.


## [1.2.5] - September 23rd, 2020

* Added a flag for `subStep` so plugins can identify steps w/in steps on the `TestReport`.
* Added optional `screenshotOnFail` flag to the `TestController` to automatically take a screenshot when a test step fails.


## [1.2.4+1] - September 23rd, 2020

* Fixed `TestStepPicker` on discard changes.


## [1.2.4] - September 23rd, 2020

* Fix for reversing height / width in `TestDeviceInfo`.


## [1.2.3] - September 22nd, 2020

* Refactored `executeStep` out of the `execute` function in the `TestController` so plugins can execute sub-steps while ensuring those steps are part of the final report.
* Removed `skipScreenshots` because it was causing more problems than it solved.  If screenshots need to be conditionally skipped, the [flow control](https://pub.dev/packages/automated_testing_framework_plugin_flow_control) plugin can do that via the `conditional` step.
* Updated `TestReport` to guarantee steps are kept in order of start rather than end.
* Fixed issue in `TestStepPicker` that prevented it from showing the selected step.


## [1.2.2] - September 22nd, 2020

* Adding `id` to `TestDeviceInfo`.


## [1.2.1+1] - September 21st, 2020

* Updated the example to the latest.


## [1.2.1] - September 21st, 2020

* Updated the `screenshot` step to support an id and added the id to the `TestReport`.
* Added "captureImage" capability to the `Testable` to allow capturing images of just that widget.
* Added "hide" and "obscure" capability to the `Testable` so it can self-obscure dynamic widgets for golden screenshots.
* Added capability for saving and loading golden images.


## [1.2.0+1] - September 19th, 2020

* Updated the example to the latest.


## [1.2.0] - September 19th, 2020

* Added the concept of test suites to the framework.


## [1.1.1] - September 15th, 2020

* Exposed the `TestStepRegistry` to via the `TestController`.
* Changed from `key` to `variableName` on the `set_variable` step, but still accept `key` for compatibility.


## [1.1.0] - September 14th, 2020

* Changed "minified" test steps render on the Current Test Steps page to allow for drag-and-drop too.
* Added variable support to the test steps.
* Added `set_variable` step.
* Added ability to attach appplication logs to the `TestReport`.
* Swapped attributes on the ios device info to get better data.


## [1.0.5+1] - September 13th, 2020

* Updated README with references to the newly available plugins.


## [1.0.5] - September 12th, 2020

* Added logging to when a `TestStep` fails.
* Added screenshots to the `TestReport` page.


## [1.0.4] - September 11th, 2020

* Added example for `linux`.


## [1.0.3] - September 9th, 2020

* Updated `TestStep` to be able to copy w/o the image.
* Added `AsyncTestLoader` to provide more test loading options.
* Updated with device info on the test reports.
* Switched static `AssetTestStore` to an instance to better follow the object model.


## [1.0.2] - September 7th, 2020

* Added `exit_app` step
* Added image capture support to Desktop.  Web is still unsupported.
* Added support for secondary tap / secondary long-press.
* Extracted the core example code to a new package to allow it to be reused across plugins.


## [1.0.1] - September 3rd, 2020

* Brought in the minimal amount of `flutter_test` to remove the dependency of the SDK version due to incompatibilities between Flutter 1.20 / 1.21.
* Added Web and MacOS to the example app.
  * _Note_: image capture is not supported in Flutter outside of iOS and Android currently.


## [1.0.0] - September 2nd, 2020

* Fix for typo in the EnsureExists registry.
* Updated `AssetTestStore` to support an index file or a list of individual files.
* Added added ability to pass a `Theme` to the `TestRunner` to give the test framework a unique theme vs the rest of the app.
* Reformatted the TestReport page to provide more useful information.
* Added a "minify test steps" option to the Test Steps page to make reordering easier.
* Added a `TestSuiteReportPage` to display a summary of all the test results in a test suite run.


## [0.2.3] - September 1st, 2020

* Fix to disable Quick Add in the test steps page when a step doesn't support it.
* Fix to not submit a report at the end of an individual step run.
* Fix for when values passed to a `Testable` are types other than `String`.
* Fix for running individual steps from the `TestStepPage` that was opened via the dialog.
* Accept a null or empty id on `Testable` as a way to disable it.


## [0.2.2] - September 1st, 2020

* Added LongPress tests support.
* Implemented `pump` function in `override_widget_tester.dart`.
* Added `widgetLongPressMoveUpdate` testable gesture.


## [0.2.1] - September 1st, 2020

* Fix to make the registry optional on `TestController`, as was originally intended.


## [0.2.0] - August 30th, 2020

* More documentation updates.
* Removed the `FileTestStore` to preserve web compatibility in the core framework.


## [0.1.2] - August 25th, 2020

* More documentation updates.
* Update to auto-run the example tests in `profile` mode.
* Updated to a more memory efficient way to load all tests for running.


## [0.1.1] - August 22nd, 2020

* Lots of documentation updates; tentatively ready for production use.


## [0.1.0] - August 21st, 2020

* First public release; not for production use.
