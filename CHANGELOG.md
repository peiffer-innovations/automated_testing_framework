## [4.0.7+6] - October 25, 2022

* Automated dependency updates


## [4.0.7+5] - October 18, 2022

* Automated dependency updates


## [4.0.7+4] - October 11, 2022

* Automated dependency updates


## [4.0.7+3] - September 27, 2022

* Automated dependency updates


## [4.0.7+2] - September 20, 2022

* Automated dependency updates


## [4.0.7+1] - August 30, 2022

* Automated dependency updates


## [4.0.7] - August 24th, 2022

* Revert fix for Flutter 3.3 to restore 3.0 compatiblity


## [4.0.6] - August 20th, 2022

* Minor changes to a few classes


## [4.0.5+1] - August 16, 2022

* Automated dependency updates


## [4.0.5] - August 11th, 2022

* Fix for updated `device_info_plus`


## [4.0.4+2] - August 9, 2022

* Automated dependency updates


## [4.0.4+1] - August 2, 2022

* Automated dependency updates


## [4.0.4] - August 1st, 2022

* Fix for finding a `Testable`


## [4.0.3] - July 28th, 2022

* Minor change to how the framework searches for a `Testable`.


## [4.0.2+1] - July 26, 2022

* Automated dependency updates


## [4.0.2] - July 14th, 2022

* Added more support to `TestDeviceInfoHelper` for not mobile platforms.
* Added screenshot support for Web when on CanvasKit


## [4.0.1+8] - July 12, 2022

* Automated dependency updates


## [4.0.1+7] - July 5, 2022

* Automated dependency updates


## [4.0.1+6] - June 28, 2022

* Automated dependency updates


## [4.0.1+5] - June 21, 2022

* Automated dependency updates


## [4.0.1+4] - June, 14, 2022

* Automated dependency updates


## [4.0.1+3] - June, 7, 2022

* Automated dependency updates


## [4.0.1+2] - May, 31, 2022

* Automated dependency updates


## [4.0.1+1] - May, 30, 2022

* Automated dependency updates


## [4.0.1] - May 18th, 2022

* Dependency updates


## [4.0.0] - May 14th, 2022

* Flutter 3.0


## [3.3.1+1] - April 16th, 2022

* Dependency updates


## [3.3.1] - February 26th, 2022

* Fix for screenshot handler


## [3.3.0+1] - February 16th, 2022

* Added `gestures` to `TestableTextFormField`, `TestableFormField`, and `TestableDropdownButtonFormField`.
* Swapped `device_info` for `device_info_plus`
* Dependency updates to latest


## [3.2.3] - February 6th, 2022

* Flutter 2.10


## [3.2.2] - January 17th, 2022

* Fixed possible race condition with `ResetNavigationStateMixin`.


## [3.2.1] - January 10th, 2022

* Bug fixes


## [3.2.0] - January 9th, 2022

* Deprecated `TestController.reset` in favor of a stream approach.
* Created `ResetNavigationStateMixin` to simplify listening to reset requests and popping a page off the navigation stack.
* Removed deprecated `setVariable` and `removeVariable` functions.


## [3.1.2] - December 28th, 2021

* Fixed test imports


## [3.1.1+2] - November 14th, 2021

* Removed `uses-material-design` from pubspec


## [3.1.1+1] - September 27th, 2021

* Readme updates


## [3.1.1] - September 26th, 2021

* Added `IoTestStore`
* Fix for adding global variables to the `TestController` via the constructor


## [3.1.0+4] - September 19th, 2021

* Dependency updates


## [3.1.0+3] - September 18th, 2021

* Dependency updates


## [3.1.0+2] - August 22nd, 2021

* Dependency updates


## [3.1.0] - June 21st, 2021

* Added variable `disable_screenshot` that can be set on the `TestController` to allow for disabling the `screenshot` step when set to `true`.
* Updated the `TestController` to isolate variables set in a test vs set globally for the application.
* Added `set_global_variable`, `remove_global_variable`, and `remove_variable` steps.
* Added the ability to pin a step so that steps can be added anywhere in an already existing test vs always at the end.
* Fixed an issue where attempting to run a single step from an immediately loaded test would pop too far off the stack.


## [3.0.8] - May 30th, 2021

* Added `assert_semantics` step


## [3.0.7+3] - May 21st, 2021

* Dependency updates


## [3.0.7+2] - May 17th, 2021

* Fix for `drag` step when setting only `dy`.
* Updated to ensure `screenshot` always has a stable id from run to run.


## [3.0.7] - May 11th, 2021

* Added `drag` step.


## [3.0.6+3] - May 9th, 2021

* Added a new `VariableResolver` class to allow applications to pass in custom resolvers.
* Added a new view that can render the test in a more [Behavior Driven Development](https://en.wikipedia.org/wiki/Behavior-driven_development) view.


## [3.0.5] - April 30th, 2021

* Updated to Ack a run test command with the device info and startup status


## [3.0.4] - April 22th, 2021

* Fix for `flash` for when the widget is removed before the flash animation is complete.


## [3.0.3] - April 20th, 2021

* Minor fix so that when using the matcher a `ValueKey<String>` and a `ValueKey<String?>` will match correctly.


## [3.0.2] - April 19th, 2021

* Added a comment test step
* Switched from using the `identifierForVendor` for iOS as the default device id for use with the test driver to `Uuid().v4()` to create a unique id in order to comply with: https://developer.apple.com/app-store/review/guidelines/#5.1.2


## [3.0.1+1] - April 13th, 2021

* Added a listener to each step to update the status on driven tests.


## [3.0.1] - April 7th, 2021

* Adjusted how the driver works to better clean up hanging driver sessions.


## [3.0.0] - March 8th, 2021

* Null Safety


## [2.0.0] - Februray 21st, 2021

* Added ability to cancel running tests.
* Upgraded to latest models that support more realtime test driving.
* Added test driver implementation that supports driving real timetime tests based off of communication sources.


## [1.3.4] - January 19th, 2021

* Fixed deadlock issue with `flash` on the `Testable` object when the widget is disposed in the middle of a flash call.
* Fixed sort for available tests page.
* Fixed filter for available tests pages when there are more filters than fit vertically.


## [1.3.3+2] - January 17th, 2021

* Dependency updates


## [1.3.3] - January 10th, 2021

* Swapped old Flat / Raised buttons for new Text / Elevated ones.


## [1.3.2+1] - January 9th, 2021

* Dependency updates


## [1.3.2] - December 22nd, 2020

* Fix for `set_value` to support non-string variables.


## [1.3.1+2] - December 22nd, 2020

* Documentation update only.


## [1.3.1+1] - December 21st, 2020

* Fix to put "caseSensitive" in the toJson on `assert_error_step` and `assert_value_step`.


## [1.3.1] - December 21st, 2020

* Added "caseSensitive" as an option to `assert_error_step` and `assert_value_step`.


## [1.3.0] - December 13th, 2020

* Updated dependencies


## [1.2.18+3] - November 3rd, 2020

* Updated to latest models


## [1.2.18+2] - November 3rd, 2020

* Added timestamp to `TestSuiteReportPage`.
* Moved common models out to a separate package.


## [1.2.18+1] - October 28th, 2020

* Added `appIdentifier` to `ExternalTestDriver` and `GoldenTestImages` id.
* Added `TestAppSettings`.


## [1.2.18] - October 28th, 2020

* Added `appIdentifier` to `DrivableDevice` and `TestDeviceInfo`.


## [1.2.17+5] - October 21th, 2020

* Update to return the `TestSuiteReport` from `runTests` and `runPendingTests`.


## [1.2.17+4] - October 21th, 2020

* Switch from `autovalidate` to `autovalidateMode` to match the direction Flutter is headed.


## [1.2.17+3] - October 20th, 2020

* Fix for test controller stating it is running until the `TestSuiteReportPage` is dismissed


## [1.2.17+2] - October 20th, 2020

* Minor fix for `Test.copyWith` when passing in a timestamp.


## [1.2.17+1] - October 19th, 2020

* Minor fix for `TestDeviceInfo` to work with Windows builds.
* Added Windows example.


## [1.2.17] - October 18th, 2020

* Added flag so the `TestController.runningTest` will return true when either a single or multiple tests are running.


## [1.2.16+2] - October 15th, 2020

* Added equals, hash, and id property to `GoldenTestImages`.


## [1.2.16+1] - October 15th, 2020

* Added equals and hash code to `DrivableDevice` and `ExternalTestDriver`.
* Added id generator util functions to `GoldenTestImages`.


## [1.2.16] - October 12th, 2020

* Added `_platform` reserved variable.
* Added `driverName` to `DrivableDevice`.


## [1.2.15+1] - October 11th, 2020

* Added the build number to the test suite report page.


## [1.2.15] - October 11th, 2020

* Fixed an issue with the screen capture request that could result in the wrong image size.


## [1.2.14+3] - October 11th, 2020

* Added `timestamp` to `GoldenTestImages`.


## [1.2.14+2] - October 10th, 2020

* Fixed a bug with the `TestSuiteReport` and `TestReport` when plugins are using the substep feature.


## [1.2.14+1] - October 10th, 2020

* Added `timestamp` to `Test`.


## [1.2.14] - October 8th, 2020

* Improved error message from `assert_value`
* Fixed an issue with single variable return from the new variable interpolation code.


## [1.2.13] - October 7th, 2020

* Upgraded the variable interpolation to search for variables in substrings rather than requiring them to be the whole string.


## [1.2.12] - October 7th, 2020

* Swapped out `crypto` with `pointycastle`.
* Fixed driver signatures for web apps.


## [1.2.11+1] - October 6th, 2020

* Minor update to disable the global overlay while tests are running.


## [1.2.11] - October 5th, 2020

* Data model updates to the external test runner framework.


## [1.2.10] - October 3rd, 2020

* Added ability to register a custom route to the `TestStepRegistry` and have that route be presented as an option on `TestStepsDialog` and `TestStepsPage`.
* Added variable for `_now` to return the current `DateTime`.
* Fixed bug in `TestStepForm` in the dropdown form when values aren't strings.
* Beginning of external test driver capabilities


## [1.2.8+2] - September 29th, 2020

* Null fix for suite name on test reports


## [1.2.8+1] - September 29th, 2020

* UI only tweaks to the test editor and report pages


## [1.2.8] - September 29th, 2020

* Minor fix for available tests page when tests in different suites have the same name.


## [1.2.7] - September 28th, 2020

* Minor fixes for nulls where the forms from the framework are used outside of a testable application.


## [1.2.6+3] - September 25th, 2020

* Fix for monospace fonts to be `monospaced` as opposed to the incorrect `monospace`.


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


















