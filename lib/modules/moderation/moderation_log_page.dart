import 'package:flutter/material.dart';

import '../../core/widgets/module_page.dart';

class ModerationLogPage extends StatelessWidget {
  const ModerationLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePage(
      module: 6,
      title: 'Log Moderasi',
      owner: 'Damica Adreeza Ramadhan',
      standalone: false,
      endpoints: [
        'GET/POST /api/admin/moderation-logs/',
        'GET/PUT/PATCH/DELETE /api/admin/moderation-logs/<id>/',
      ],
    );
  }
}
