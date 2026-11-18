import 'package:flutter/material.dart';

import '../../core/widgets/module_page.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePage(
      module: 5,
      title: 'Katalog & Pencarian',
      owner: 'Christiano Hosea',
      standalone: false,
      endpoints: [
        'GET /api/listings',
      ],
    );
  }
}
