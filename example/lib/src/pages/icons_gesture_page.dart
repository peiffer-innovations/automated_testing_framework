import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:example/src/pages/center_text_page.dart';
import 'package:flutter/material.dart';

class IconsGesturePage extends StatelessWidget {
  IconsGesturePage({Key key}) : super(key: key);

  static const Map<String, IconData> _icons = {
    'android': Icons.android,
    'bug_report': Icons.bug_report,
    'cake': Icons.cake,
    'directions_walk': Icons.directions_walk,
    'email': Icons.email,
    'favorite': Icons.favorite,
    'games': Icons.games,
    'headset': Icons.headset,
    'image': Icons.image,
    'keyboard_voice': Icons.keyboard_voice,
    'lock_outline': Icons.lock_outline,
    'menu': Icons.menu,
    'network_wifi': Icons.network_wifi,
    'ondemand_video': Icons.ondemand_video,
    'panorama': Icons.panorama,
    'question_answer': Icons.question_answer,
    'remove_circle_outline': Icons.remove_circle_outline,
    'school': Icons.school,
    'terrain': Icons.terrain,
    'usb': Icons.usb,
    'verified_user': Icons.verified_user,
    'watch_later': Icons.watch_later,
    'youtube_searched_for': Icons.youtube_searched_for,
    'zoom_out_map': Icons.zoom_out_map
  };

  final List<String> _keys = _icons.keys.toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Icon Buttons'),
      ),
      body: ListView.builder(
        itemCount: _icons.length,
        itemBuilder: (BuildContext context, int index) {
          final key = _keys[index];
          return Padding(
            padding: EdgeInsets.only(top: 16.0),
            child: Container(
              alignment: Alignment.center,
              width: double.infinity,
              child: Testable(
                gestures: TestableGestures(
                  widgetLongPress: null,
                  widgetTap: TestableGestureAction.open_test_actions_dialog,
                ),
                id: 'icon_${key}',
                child: GestureDetector(
                  onLongPress: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) => CenterTextPage(
                        text: key,
                      ),
                    ),
                  ),
                  child: Icon(
                    _icons[key],
                    size: 75,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
