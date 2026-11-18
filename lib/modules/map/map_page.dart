import 'package:flutter/material.dart';

import '../../core/widgets/module_page.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePage(
      module: 4,
      title: 'Peta Sebaran Makanan',
      owner: 'Christiano Hosea',
      standalone: false,
      endpoints: [
        'GET /api/listings',
        'GET /api/stores/<id>',
        'GET /api/stores/<id>/listings',
      ],
    );
  }
}
