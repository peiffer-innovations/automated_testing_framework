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
* Added Web and MacOS to the example app
  * _Note_: image capture is not supported in Flutter outside of iOS and Android currently


## [1.0.0] - September 2nd, 2020

* Fix for typo in the EnsureExists registry
* Updated `AssetTestStore` to support an index file or a list of individual files
* Added added ability to pass a `Theme` to the `TestRunner` to give the test framework a unique theme vs the rest of the app
* Reformatted the TestReport page to provide more useful information
* Added a "minify test steps" option to the Test Steps page to make reordering easier
* Added a `TestSuiteReportPage` to display a summary of all the test results in a test suite run.


## [0.2.3] - September 1st, 2020

* Fix to disable Quick Add in the test steps page when a step doesn't support it
* Fix to not submit a report at the end of an individual step run
* Fix for when values passed to a `Testable` are types other than `String`
* Fix for running individual steps from the `TestStepPage` that was opened via the dialog
* Accept a null or empty id on `Testable` as a way to disable it


## [0.2.2] - September 1st, 2020

* Added LongPress tests support
* Implemented `pump` function in `override_widget_tester.dart`
* Added `widgetLongPressMoveUpdate` testable gesture


## [0.2.1] - September 1st, 2020

* Fix to make the registry optional on `TestController`, as was originally intended


## [0.2.0] - August 30th, 2020

* More documentation updates
* Removed the `FileTestStore` to preserve web compatibility in the core framework


## [0.1.2] - August 25th, 2020

* More documentation updates
* Update to auto-run the example tests in `profile` mode
* Updated to a more memory efficient way to load all tests for running


## [0.1.1] - August 22nd, 2020

* Lots of documentation updates; tentatively ready for production use


## [0.1.0] - August 21st, 2020

* First public release; not for production use.
