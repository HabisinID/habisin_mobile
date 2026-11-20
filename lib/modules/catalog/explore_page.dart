import 'package:flutter/material.dart';

import '../map/map_page.dart';
import 'catalog_page.dart';

/// Tab Jelajahi: toggle Peta (Modul 4) / Daftar (Modul 5), sesuai desain 1a/1b.
class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  bool _showMap = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: true,
                icon: Icon(Icons.map_outlined),
                label: Text('Peta'),
              ),
              ButtonSegment(
                value: false,
                icon: Icon(Icons.list),
                label: Text('Daftar'),
              ),
            ],
            selected: {_showMap},
            onSelectionChanged: (s) => setState(() => _showMap = s.first),
          ),
        ),
        Expanded(child: _showMap ? const MapPage() : const CatalogPage()),
      ],
    );
  }
}
