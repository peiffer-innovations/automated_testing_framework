import 'dart:async';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:example/src/pages/buttons_page.dart';
import 'package:example/src/pages/dropdown_page.dart';
import 'package:example/src/pages/edit_text_page.dart';
import 'package:example/src/pages/icons_gesture_page.dart';
import 'package:example/src/pages/stacked_scroll_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  final Map<String, Widget> _pages = {
    'Buttons': ButtonsPage(),
    'Dropdown': DropdownPage(),
    'Edit Text': EditTextPage(),
    'Icons Gesture': IconsGesturePage(),
    'Stacked Scroll Page': StackedScrollPage(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Automated Tests'),
        actions: [
          Testable(
            id: 'theme_switcher',
            child: IconButton(
              icon: Icon(Icons.sync),
              onPressed: () => Provider.of<StreamController<void>>(
                context,
                listen: false,
              ).add(null),
              tooltip: 'Switch theme light / dark',
            ),
          ),
        ],
      ),
      body: Material(
        child: ListView(
          children: <Widget>[
            for (var entry in _pages.entries)
              Testable(
                id: 'test_page_${entry.key}',
                child: ListTile(
                  title: Text(entry.key),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (BuildContext context) => entry.value),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
