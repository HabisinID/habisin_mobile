import 'package:flutter/material.dart';

import '../../core/widgets/module_page.dart';

class AdminListingsPage extends StatelessWidget {
  const AdminListingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePage(
      module: 6,
      title: 'Listing Publik',
      owner: 'Damica Adreeza Ramadhan',
      standalone: false,
      endpoints: [
        'GET /api/admin/listings/',
        'POST /api/admin/listings/<id>/take-down/',
        'POST /api/admin/listings/<id>/restore/',
      ],
    );
  }
}
