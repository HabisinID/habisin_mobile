import 'package:flutter/material.dart';

import '../../core/widgets/module_page.dart';

class OrderListPage extends StatelessWidget {
  const OrderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePage(
      module: 7,
      title: 'Pesanan Saya',
      owner: 'Violin Monica',
      standalone: false,
      endpoints: [
        'GET/POST /api/reservations',
        'GET/PATCH/DELETE /api/reservations/<id>',
        'POST /api/reservations/<id>/pay',
        'POST /api/reservations/<id>/cancel',
      ],
    );
  }
}
