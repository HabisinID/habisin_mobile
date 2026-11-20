import 'package:flutter/material.dart';

import '../../core/widgets/module_page.dart';

class PartnerListingsPage extends StatelessWidget {
  const PartnerListingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePage(
      module: 3,
      title: 'Kelola Listing',
      owner: 'Christiano Hosea',
      standalone: false,
      endpoints: [
        'GET/POST /api/partner/listings',
        'GET/PATCH/DELETE /api/partner/listings/<id>',
        'POST /api/partner/listings/<id>/sold-out',
        'POST /api/partner/listings/<id>/undo-sold-out',
      ],
    );
  }
}
