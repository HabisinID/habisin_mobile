import 'package:flutter/material.dart';

import '../../core/widgets/module_page.dart';

class StorePage extends StatelessWidget {
  const StorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePage(
      module: 2,
      title: 'Profil Toko',
      owner: 'Rozan Laudzai',
      standalone: true,
      endpoints: [
        'POST /api/partner/geocode',
        'GET/POST /api/partner/stores',
        'GET/PATCH/DELETE /api/partner/stores/<id>',
        'POST /api/partner/stores/<id>/close',
      ],
    );
  }
}
