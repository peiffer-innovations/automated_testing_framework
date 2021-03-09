// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../flutter_test/flutter_test.dart';

/// Class that programmatically interacts with widgets and the test environment.
///
/// For convenience, instances of this class (such as the one provided by
/// `testWidget`) can be used as the `vsync` for `AnimationController` objects.
class OverrideWidgetTester extends WidgetController
    implements HitTestDispatcher, TickerProvider {
  OverrideWidgetTester(WidgetsBinding binding) : super(binding);

  /// The description string of the test currently being run.
  String get testDescription => _testDescription;
  // ignore: prefer_final_fields
  String _testDescription = '';

  /// The binding instance used by the testing framework.
  @override
  WidgetsBinding get binding => super.binding;

  @override
  Future<void> pump([
    Duration? duration,
  ]) async {
    if (duration != null) {
      await Future<void>.delayed(duration);
    }
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

  Set<Ticker>? _tickers;

  @override
  Ticker createTicker(TickerCallback onTick) {
    _tickers ??= <_TestTicker>{};
    // ignore: omit_local_variable_types
    final _TestTicker result = _TestTicker(onTick, _removeTicker);
    _tickers!.add(result);
    return result;
  }

  void _removeTicker(_TestTicker ticker) {
    assert(_tickers != null);
    assert(_tickers!.contains(ticker));
    _tickers!.remove(ticker);
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
      for (final Ticker ticker in _tickers!) {
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
        _lastRecordedSemanticsHandles!) {
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

  int? _lastRecordedSemanticsHandles;

  // ignore: unused_element
  void _recordNumberOfSemanticsHandles() {
    _lastRecordedSemanticsHandles =
        binding.pipelineOwner.debugOutstandingSemanticsHandles;
  }

  /// Makes an effort to dismiss the current page with a Material [Scaffold] or
  /// a [CupertinoPageScaffold].
  ///
  /// Will throw an error if there is no back button in the page.
  Future<void> pageBack() async {
    // ignore: omit_local_variable_types
    Finder backButton = find.byTooltip('Back');
    if (backButton.evaluate().isEmpty) {
      backButton = find.byType(CupertinoNavigationBarBackButton);
    }

    await tap(backButton);
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
    RenderObject? renderObject = element.findRenderObject();
    // ignore: omit_local_variable_types
    SemanticsNode? result = renderObject?.debugSemantics;
    while (renderObject != null && result == null) {
      renderObject = renderObject.parent as RenderObject;
      result = renderObject.debugSemantics;
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
