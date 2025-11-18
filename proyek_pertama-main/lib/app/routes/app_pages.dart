import 'package:flutter/widgets.dart';
import 'app_routes.dart';

typedef PageBuilder = Widget Function(BuildContext);

class AppPages {
  static final Map<String, PageBuilder> routes = {
    AppRoutes.login: (ctx) => const SizedBox(), // placeholders
    AppRoutes.register: (ctx) => const SizedBox(),
    AppRoutes.home: (ctx) => const SizedBox(),
    AppRoutes.dosenHome: (ctx) => const SizedBox(),
  };
}