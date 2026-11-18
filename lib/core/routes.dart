import 'package:flutter/material.dart';

import '../modules/auth/auth_page.dart';
import '../modules/auth/login_page.dart';
import '../modules/review/review_page.dart';
import '../modules/store/store_page.dart';
import 'widgets/component_gallery.dart';

/// Named route untuk halaman di luar bottom navigation.
class AppRoutes {
  static const account = '/account';
  static const store = '/store';
  static const review = '/review';
  static const components = '/components';
  static const login = '/login';
  static const register = '/register';

  static final Map<String, WidgetBuilder> routes = {
    login: (_) => const AuthPage(),
    register: (_) => const AuthPage(register: true),
    account: (_) => const LoginPage(standalone: true),
    store: (_) => const StorePage(),
    review: (_) => const ReviewPage(),
    components: (_) => const ComponentGallery(),
  };
}
