import 'package:flutter/material.dart';

import '../../core/widgets/module_page.dart';

class PartnerApprovalPage extends StatelessWidget {
  const PartnerApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePage(
      module: 6,
      title: 'Pendaftaran Mitra',
      owner: 'Damica Adreeza Ramadhan',
      standalone: false,
      endpoints: [
        'GET /api/admin/partner-approvals',
        'GET /api/admin/partner-approvals/<id>',
        'POST /api/admin/partner-approvals/<id>/approve',
        'POST /api/admin/partner-approvals/<id>/reject',
      ],
    );
  }
}
