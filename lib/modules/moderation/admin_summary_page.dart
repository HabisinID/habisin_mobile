import 'package:flutter/material.dart';

import '../../core/widgets/module_page.dart';

class AdminSummaryPage extends StatelessWidget {
  const AdminSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePage(
      module: 6,
      title: 'Ringkasan Admin',
      owner: 'Damica Adreeza Ramadhan',
      standalone: false,
      endpoints: ['GET /api/admin/summary'],
    );
  }
}
