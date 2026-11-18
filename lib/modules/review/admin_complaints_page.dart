import 'package:flutter/material.dart';

import '../../core/widgets/module_page.dart';

class AdminComplaintsPage extends StatelessWidget {
  const AdminComplaintsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePage(
      module: 9,
      title: 'Laporan Komplain',
      owner: 'Raihan Daffa Aprilianda',
      standalone: false,
      endpoints: [
        'GET /api/admin/complaints',
        'PATCH /api/admin/complaints/<id>',
      ],
    );
  }
}
