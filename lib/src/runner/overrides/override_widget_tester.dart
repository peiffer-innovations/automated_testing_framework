// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Keep users from needing multiple imports to test semantics.
export 'package:flutter/rendering.dart' show SemanticsHandle;

/// Class that programmatically interacts with widgets and the test environment.
///
/// For convenience, instances of this class (such as the one provided by
/// `testWidget`) can be used as the `vsync` for `AnimationController` objects.
class OverrideWidgetTester extends WidgetController
    implements HitTestDispatcher, TickerProvider {
  OverrideWidgetTester(WidgetsBinding binding) : super(binding) {
    if (binding is LiveTestWidgetsFlutterBinding)
      // ignore: curly_braces_in_flow_control_structures
      binding.deviceEventDispatcher = this;
  }

  /// The description string of the test currently being run.
  String get testDescription => _testDescription;
  // ignore: prefer_final_fields
  String _testDescription = '';

  /// The binding instance used by the testing framework.
  @override
  WidgetsBinding get binding => super.binding;

  Future<void> pumpWidget(
    Widget widget, [
    Duration duration,
    EnginePhase phase = EnginePhase.sendSemanticsUpdate,
  ]) =>
      throw UnimplementedError();

  @override
  Future<void> pump([
    Duration duration,
    EnginePhase phase = EnginePhase.sendSemanticsUpdate,
  ]) async {
    if (duration != null)
      // ignore: curly_braces_in_flow_control_structures
      await Future<void>.delayed(duration);
    binding.scheduleFrame();
    await binding.endOfFrame;
  }

  /// Whether there are any any transient callbacks scheduled.
  ///
  /// This essentially checks whether all animations have completed.
  ///
  /// See also:
  ///
  ///  * [pumpAndSettle], which essentially calls [pump] until there are no
  ///    scheduled frames.
  ///  * [SchedulerBinding.transientCallbackCount], which is the value on which
  ///    this is based.
  ///  * [SchedulerBinding.hasScheduledFrame], which is true whenever a frame is
  ///    pending. [SchedulerBinding.hasScheduledFrame] is made true when a
  ///    widget calls [State.setState], even if there are no transient callbacks
  ///    scheduled. This is what [pumpAndSettle] uses.
  bool get hasRunningAnimations => binding.transientCallbackCount > 0;

  Set<Ticker> _tickers;

  @override
  Ticker createTicker(TickerCallback onTick) {
    _tickers ??= <_TestTicker>{};
    // ignore: omit_local_variable_types
    final _TestTicker result = _TestTicker(onTick, _removeTicker);
    _tickers.add(result);
    return result;
  }

  void _removeTicker(_TestTicker ticker) {
    assert(_tickers != null);
    assert(_tickers.contains(ticker));
    _tickers.remove(ticker);
  }

  /// Throws an exception if any tickers created by the [WidgetTester] are still
  /// active when the method is called.
  ///
  /// An argument can be specified to provide a string that will be used in the
  /// error message. It should be an adverbial phrase describing the current
  /// situation, such as "at the end of the test".
  void verifyTickersWereDisposed([String when = 'when none should have been']) {
    assert(when != null);
    if (_tickers != null) {
      // ignore: omit_local_variable_types
      for (final Ticker ticker in _tickers) {
        if (ticker.isActive) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary('A Ticker was active $when.'),
            ErrorDescription('All Tickers must be disposed.'),
            ErrorHint('Tickers used by AnimationControllers '
                'should be disposed by calling dispose() on the AnimationController itself. '
                'Otherwise, the ticker will leak.'),
            ticker.describeForError('The offending ticker was')
          ]);
        }
      }
    }
  }

  // ignore: unused_element
  void _endOfTestVerifications() {
    verifyTickersWereDisposed('at the end of the test');
    _verifySemanticsHandlesWereDisposed();
  }

  void _verifySemanticsHandlesWereDisposed() {
    assert(_lastRecordedSemanticsHandles != null);
    if (binding.pipelineOwner.debugOutstandingSemanticsHandles >
        _lastRecordedSemanticsHandles) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('A SemanticsHandle was active at the end of the test.'),
        ErrorDescription(
            'All SemanticsHandle instances must be disposed by calling dispose() on '
            'the SemanticsHandle.'),
        ErrorHint('If your test uses SemanticsTester, it is '
            'sufficient to call dispose() on SemanticsTester. Otherwise, the '
            'existing handle will leak into another test and alter its behavior.')
      ]);
    }
    _lastRecordedSemanticsHandles = null;
  }

  int _lastRecordedSemanticsHandles;

  // ignore: unused_element
  void _recordNumberOfSemanticsHandles() {
    _lastRecordedSemanticsHandles =
        binding.pipelineOwner.debugOutstandingSemanticsHandles;
  }

  /// Simulates sending physical key down and up events through the system channel.
  ///
  /// This only simulates key events coming from a physical keyboard, not from a
  /// soft keyboard.
  ///
  /// Specify `platform` as one of the platforms allowed in
  /// [Platform.operatingSystem] to make the event appear to be from that type
  /// of system. Defaults to "android". Must not be null. Some platforms (e.g.
  /// Windows, iOS) are not yet supported.
  ///
  /// Keys that are down when the test completes are cleared after each test.
  ///
  /// This method sends both the key down and the key up events, to simulate a
  /// key press. To simulate individual down and/or up events, see
  /// [sendKeyDownEvent] and [sendKeyUpEvent].
  ///
  /// See also:
  ///
  ///  - [sendKeyDownEvent] to simulate only a key down event.
  ///  - [sendKeyUpEvent] to simulate only a key up event.
  Future<void> sendKeyEvent(LogicalKeyboardKey key,
      {String platform = 'android'}) async {
    assert(platform != null);
    await simulateKeyDownEvent(key, platform: platform);
    // Internally wrapped in async guard.
    return simulateKeyUpEvent(key, platform: platform);
  }

  /// Simulates sending a physical key down event through the system channel.
  ///
  /// This only simulates key down events coming from a physical keyboard, not
  /// from a soft keyboard.
  ///
  /// Specify `platform` as one of the platforms allowed in
  /// [Platform.operatingSystem] to make the event appear to be from that type
  /// of system. Defaults to "android". Must not be null. Some platforms (e.g.
  /// Windows, iOS) are not yet supported.
  ///
  /// Keys that are down when the test completes are cleared after each test.
  ///
  /// See also:
  ///
  ///  - [sendKeyUpEvent] to simulate the corresponding key up event.
  ///  - [sendKeyEvent] to simulate both the key up and key down in the same call.
  Future<void> sendKeyDownEvent(LogicalKeyboardKey key,
      {String platform = 'android'}) async {
    assert(platform != null);
    // Internally wrapped in async guard.
    return simulateKeyDownEvent(key, platform: platform);
  }

  /// Simulates sending a physical key up event through the system channel.
  ///
  /// This only simulates key up events coming from a physical keyboard,
  /// not from a soft keyboard.
  ///
  /// Specify `platform` as one of the platforms allowed in
  /// [Platform.operatingSystem] to make the event appear to be from that type
  /// of system. Defaults to "android". May not be null.
  ///
  /// See also:
  ///
  ///  - [sendKeyDownEvent] to simulate the corresponding key down event.
  ///  - [sendKeyEvent] to simulate both the key up and key down in the same call.
  Future<void> sendKeyUpEvent(LogicalKeyboardKey key,
      {String platform = 'android'}) async {
    assert(platform != null);
    // Internally wrapped in async guard.
    return simulateKeyUpEvent(key, platform: platform);
  }

  /// Makes an effort to dismiss the current page with a Material [Scaffold] or
  /// a [CupertinoPageScaffold].
  ///
  /// Will throw an error if there is no back button in the page.
  Future<void> pageBack() async {
    return TestAsyncUtils.guard<void>(() async {
      // ignore: omit_local_variable_types
      Finder backButton = find.byTooltip('Back');
      if (backButton.evaluate().isEmpty) {
        backButton = find.byType(CupertinoNavigationBarBackButton);
      }

      expectSync(backButton, findsOneWidget,
          reason: 'One back button expected on screen');

      await tap(backButton);
    });
  }

  /// Attempts to find the [SemanticsNode] of first result from `finder`.
  ///
  /// If the object identified by the finder doesn't own it's semantic node,
  /// this will return the semantics data of the first ancestor with semantics.
  /// The ancestor's semantic data will include the child's as well as
  /// other nodes that have been merged together.
  ///
  /// Will throw a [StateError] if the finder returns more than one element or
  /// if no semantics are found or are not enabled.
  SemanticsNode getSemantics(Finder finder) {
    if (binding.pipelineOwner.semanticsOwner == null)
      // ignore: curly_braces_in_flow_control_structures
      throw StateError('Semantics are not enabled.');
    // ignore: omit_local_variable_types
    final Iterable<Element> candidates = finder.evaluate();
    if (candidates.isEmpty) {
      throw StateError('Finder returned no matching elements.');
    }
    if (candidates.length > 1) {
      throw StateError('Finder returned more than one element.');
    }
    // ignore: omit_local_variable_types
    final Element element = candidates.single;
    // ignore: omit_local_variable_types
    RenderObject renderObject = element.findRenderObject();
    // ignore: omit_local_variable_types
    SemanticsNode result = renderObject.debugSemantics;
    while (renderObject != null && result == null) {
      renderObject = renderObject?.parent as RenderObject;
      result = renderObject?.debugSemantics;
    }
    if (result == null) throw StateError('No Semantics data found.');
    return result;
  }

  /// Enable semantics in a test by creating a [SemanticsHandle].
  ///
  /// The handle must be disposed at the end of the test.
  SemanticsHandle ensureSemantics() {
    return binding.pipelineOwner.ensureSemantics();
  }

  /// Given a widget `W` specified by [finder] and a [Scrollable] widget `S` in
  /// its ancestry tree, this scrolls `S` so as to make `W` visible.
  ///
  /// Shorthand for `Scrollable.ensureVisible(tester.element(finder))`
  Future<void> ensureVisible(Finder finder) =>
      Scrollable.ensureVisible(element(finder));

  @override
  void dispatchEvent(PointerEvent event, HitTestResult result) =>
      throw UnimplementedError();
}

typedef _TickerDisposeCallback = void Function(_TestTicker ticker);

class _TestTicker extends Ticker {
  _TestTicker(TickerCallback onTick, this._onDispose) : super(onTick);

  final _TickerDisposeCallback _onDispose;

  @override
  void dispose() {
    if (_onDispose != null) _onDispose(this);
    super.dispose();
  }
}
