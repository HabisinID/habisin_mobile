import 'package:flutter/material.dart';

import '../../core/widgets/module_page.dart';

class PartnerOrdersPage extends StatelessWidget {
  const PartnerOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePage(
      module: 7,
      title: 'Pesanan Masuk',
      owner: 'Violin Monica',
      standalone: false,
      endpoints: [
        'GET /api/partner/orders',
        'POST /api/partner/reservations/<id>/cancel',
      ],
    );
  }
}
