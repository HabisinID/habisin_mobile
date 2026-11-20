import 'package:flutter/material.dart';

import '../../modules/auth/login_page.dart';
import '../../modules/catalog/explore_page.dart';
import '../../modules/dashboard/partner_dashboard_page.dart';
import '../../modules/listing/partner_listings_page.dart';
import '../../modules/moderation/admin_listings_page.dart';
import '../../modules/moderation/admin_summary_page.dart';
import '../../modules/moderation/moderation_log_page.dart';
import '../../modules/moderation/partner_approval_page.dart';
import '../../modules/order/order_list_page.dart';
import '../../modules/order/partner_orders_page.dart';
import '../../modules/review/admin_complaints_page.dart';
import '../../modules/verification/cashier_page.dart';
import '../routes.dart';
import '../session.dart';
import '../theme.dart';

typedef _Tab = ({String label, IconData icon, Widget page});

/// Bottom navigation per peran, sesuai komponen Nav/Pembeli, Nav/Mitra, dan Nav/Admin di design.pen.
const Map<Role, List<_Tab>> _tabs = {
  Role.pembeli: [
    (label: 'Jelajahi', icon: Icons.map_outlined, page: ExplorePage()),
    (
      label: 'Pesanan',
      icon: Icons.receipt_long_outlined,
      page: OrderListPage(),
    ),
    (label: 'Akun', icon: Icons.person_outline, page: LoginPage()),
  ],
  Role.mitra: [
    (
      label: 'Dasbor',
      icon: Icons.dashboard_outlined,
      page: PartnerDashboardPage(),
    ),
    (
      label: 'Listing',
      icon: Icons.format_list_bulleted,
      page: PartnerListingsPage(),
    ),
    (label: 'Verifikasi', icon: Icons.qr_code_scanner, page: CashierPage()),
    (
      label: 'Pesanan',
      icon: Icons.receipt_long_outlined,
      page: PartnerOrdersPage(),
    ),
    (label: 'Akun', icon: Icons.person_outline, page: LoginPage()),
  ],
  Role.admin: [
    (
      label: 'Ringkasan',
      icon: Icons.space_dashboard_outlined,
      page: AdminSummaryPage(),
    ),
    (
      label: 'Pendaftaran',
      icon: Icons.how_to_reg_outlined,
      page: PartnerApprovalPage(),
    ),
    (
      label: 'Listing',
      icon: Icons.inventory_2_outlined,
      page: AdminListingsPage(),
    ),
    (label: 'Laporan', icon: Icons.flag_outlined, page: AdminComplaintsPage()),
    (label: 'Log', icon: Icons.history, page: ModerationLogPage()),
  ],
};

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    // Key per peran: tab kembali ke indeks 0 saat peran berganti.
    return ValueListenableBuilder(
      valueListenable: currentRole,
      builder: (_, role, _) => _RoleShell(key: ValueKey(role), role: role),
    );
  }
}

class _RoleShell extends StatefulWidget {
  const _RoleShell({super.key, required this.role});
  final Role role;

  @override
  State<_RoleShell> createState() => _RoleShellState();
}

class _RoleShellState extends State<_RoleShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = _tabs[widget.role]!;
    return Scaffold(
      appBar: AppBar(
        title: Text(tabs[_index].label),
        actions: [
          // Admin tidak punya tab Akun; akun dibuka dari avatar (desain 20).
          if (widget.role == Role.admin)
            IconButton(
              tooltip: 'Akun',
              icon: const CircleAvatar(
                radius: 16,
                child: Icon(Icons.person, size: 18),
              ),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.account),
            ),
        ],
      ),
      // IndexedStack menjaga state tiap tab (scroll, input) saat berpindah.
      body: IndexedStack(
        index: _index,
        children: [for (final t in tabs) t.page],
      ),
      bottomNavigationBar: BottomNav(
        tabs: [for (final t in tabs) (label: t.label, icon: t.icon)],
        index: _index,
        onTap: (i) => setState(() => _index = i),
        // Nav/Mitra: tab tengah (Verifikasi) jadi tombol bulat yang menonjol.
        fabIndex: widget.role == Role.mitra ? 2 : null,
      ),
    );
  }
}

/// Ikon outline yang sama untuk aktif/tidak aktif; hanya warnanya yang berubah (sesuai desain).
typedef NavTab = ({String label, IconData icon});

/// Bottom nav sesuai komponen Nav/Pembeli & Nav/Mitra di design.pen:
/// kapsul primary-tint 12 membungkus ikon + label; opsional tombol bulat menonjol di tengah.
class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.tabs,
    required this.index,
    required this.onTap,
    this.fabIndex,
  });

  final List<NavTab> tabs;
  final int index;
  final ValueChanged<int> onTap;
  final int? fabIndex;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final hasFab = fabIndex != null;
    // Nav/Pembeli: tinggi 64, item 80 · Nav/Mitra: tinggi 72, item 68 (5 tab).
    final itemWidth = tabs.length > 3 ? 68.0 : 80.0;
    return Container(
      key: const Key('bottom-nav'),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: hasFab ? 72 : 64,
          padding: EdgeInsets.fromLTRB(8, hasFab ? 0 : 6, 8, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final (i, t) in tabs.indexed)
                i == fabIndex
                    ? _FabItem(tab: t, onTap: () => onTap(i))
                    : _NavItem(
                        tab: t,
                        width: itemWidth,
                        selected: i == index,
                        onTap: () => onTap(i),
                      ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.width,
    required this.selected,
    required this.onTap,
  });

  final NavTab tab;
  final double width;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final fg = selected ? c.primary : c.textMuted;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? c.primaryTint : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onTap,
          child: SizedBox(
            width: width,
            height: 52,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(tab.icon, size: 24, color: fg),
                const SizedBox(height: 2),
                Text(
                  tab.label,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: fg,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tombol Verifikasi: lingkaran 60, garis surface 4, bayangan, ikon 28; menonjol 16 px di atas bar.
class _FabItem extends StatelessWidget {
  const _FabItem({required this.tab, required this.onTap});

  final NavTab tab;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    // Slot setinggi item biasa (52); isi 80 (60 + 4 + 16) digambar keluar ke atas.
    return SizedBox(
      width: 84,
      height: 52,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Semantics(
              button: true,
              label: tab.label,
              child: GestureDetector(
                onTap: onTap,
                behavior: HitTestBehavior.opaque,
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: c.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: c.surface, width: 4),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x2E14301F),
                            offset: Offset(0, 4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Icon(tab.icon, size: 28, color: c.onPrimary),
                    ),
                    const SizedBox(height: 4),
                    ExcludeSemantics(
                      child: Text(
                        tab.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: c.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
