import 'package:flutter/material.dart';

import '../../core/widgets/module_page.dart';

class ReviewPage extends StatelessWidget {
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePage(
      module: 9,
      title: 'Ulasan & Komplain',
      owner: 'Raihan Daffa Aprilianda',
      standalone: true,
      endpoints: [
        'GET /api/stores/<id>/reviews',
        'POST /api/reviews',
        'GET /api/reviews/mine',
        'PATCH/DELETE /api/reviews/<id>',
        'POST /api/complaints',
      ],
    );
  }
}
