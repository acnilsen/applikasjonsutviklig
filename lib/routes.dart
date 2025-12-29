import 'package:flutter/material.dart';
import 'pages/home_page.dart';

/// Routes for the app.
class Routes {
  static const String home = '/';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => HomePage(),
    };
  }
}