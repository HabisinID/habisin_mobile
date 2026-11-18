import 'package:flutter/material.dart';

import '../../core/widgets/module_page.dart';

class CashierPage extends StatelessWidget {
  const CashierPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePage(
      module: 8,
      title: 'Verifikasi Kode',
      owner: 'Violin Monica',
      standalone: false,
      endpoints: [
        'POST /api/partner/verify/check',
        'POST /api/partner/verify/<id>/pickup',
        'POST /api/partner/verify/<id>/undo',
        'GET /api/partner/verify/recent',
      ],
    );
  }
}
