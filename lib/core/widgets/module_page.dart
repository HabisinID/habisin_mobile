import 'package:flutter/material.dart';

import '../theme.dart';

/// Kerangka halaman modul sementara. Ganti dengan UI modul masing-masing.
///
/// [standalone] = true untuk halaman di luar tab (punya AppBar + tombol kembali);
/// false untuk tab bottom navigation (AppBar dari HomeShell).
class ModulePage extends StatelessWidget {
  const ModulePage({
    super.key,
    required this.module,
    required this.title,
    required this.owner,
    required this.endpoints,
    this.standalone = false,
    this.children = const [],
  });

  final int module;
  final String title;
  final String owner;
  final List<String> endpoints;
  final bool standalone;

  /// Widget tambahan di bawah kartu endpoint (mis. tautan ke halaman lain).
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final muted = AppColors.of(context).textMuted;
    final body = ListView(
      padding: const EdgeInsets.all(AppSpace.lg),
      children: [
        Text(
          'MODUL $module',
          style: t.labelSmall?.copyWith(color: muted, letterSpacing: 1),
        ),
        const SizedBox(height: AppSpace.xs),
        Text(title, style: t.headlineSmall),
        const SizedBox(height: AppSpace.xs),
        Text(
          'Penanggung jawab: $owner',
          style: t.bodyMedium?.copyWith(color: muted),
        ),
        const SizedBox(height: AppSpace.xl),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpace.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Endpoint DRF', style: t.titleMedium),
                const SizedBox(height: AppSpace.sm),
                for (final e in endpoints)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      e,
                      style: AppText.mono.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        ...children,
      ],
    );
    return standalone
        ? Scaffold(
            appBar: AppBar(title: Text(title)),
            body: body,
          )
        : body;
  }
}
