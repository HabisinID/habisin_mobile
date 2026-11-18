import 'package:flutter/material.dart';

import '../../core/widgets/module_page.dart';

class PartnerDashboardPage extends StatelessWidget {
  const PartnerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePage(
      module: 10,
      title: 'Dasbor Statistik',
      owner: 'Raihan Daffa Aprilianda',
      standalone: false,
      endpoints: [
        'GET /api/partner/dashboard',
        'GET /api/dashboard',
      ],
    );
  }
}
