/// Komponen reusable dari design.pen (frame "Fondasi · Komponen").
/// Import satu file ini: `import '../../core/widgets/components.dart';`
/// Lihat semuanya di halaman Akun → "Galeri komponen".
library;

import 'package:flutter/material.dart';

import '../theme.dart';

/// Format rupiah tanpa desimal: 8000 → `Rp8.000`.
String rupiah(int value) =>
    'Rp${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';

enum AppButtonVariant { primary, secondary, destructive }

/// Btn/Primary, Btn/Secondary, Btn/Destructive. Tinggi 48, radius 12.
/// `onPressed: null` = disabled. `loading: true` = spinner + disabled.
class AppButton extends StatelessWidget {
  const AppButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = false,
  }) : variant = AppButtonVariant.primary;
  const AppButton.secondary(
    this.label, {
    super.key,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = false,
  }) : variant = AppButtonVariant.secondary;
  const AppButton.destructive(
    this.label, {
    super.key,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = false,
  }) : variant = AppButtonVariant.destructive;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;

  /// Lebar penuh (untuk sticky CTA).
  final bool expand;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final secondary = variant == AppButtonVariant.secondary;
    final fg = secondary ? c.text : c.onPrimary;
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (loading)
          SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        else if (icon != null)
          Icon(icon, size: 20),
        if (loading || icon != null) const SizedBox(width: AppSpace.sm),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );
    final onTap = loading ? null : onPressed;
    final button = switch (variant) {
      AppButtonVariant.primary => FilledButton(onPressed: onTap, child: child),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: onTap,
        child: child,
      ),
      AppButtonVariant.destructive => FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: c.error,
          foregroundColor: c.onPrimary,
        ),
        child: child,
      ),
    };
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Input: label 14/600 di atas field 48, teks bantuan 12 di bawah.
class AppInput extends StatelessWidget {
  const AppInput({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.help,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffix,
    this.textInputAction,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? help;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int maxLines;
  final IconData? prefixIcon;
  final Widget? suffix;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          onChanged: onChanged,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          textInputAction: textInputAction,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            helperText: help,
            prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}

/// Chip filter (pill 36). Bungkus FilterChip agar ukuran konsisten.
class AppChip extends StatelessWidget {
  const AppChip(
    this.label, {
    super.key,
    this.selected = false,
    this.onSelected,
    this.icon,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return FilterChip(
      label: Text(label),
      avatar: icon == null ? null : Icon(icon, size: 18, color: c.text),
      selected: selected,
      showCheckmark: false,
      onSelected: onSelected ?? (_) {},
      side: BorderSide(color: selected ? c.primary : c.border),
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }
}

/// Countdown: badge 28 "2 jam 14 menit lagi". [urgent] = < 30 menit (oranye).
class Countdown extends StatelessWidget {
  const Countdown(this.label, {super.key, this.urgent = false});

  final String label;
  final bool urgent;

  /// Teks "x jam y menit lagi" dari sisa durasi.
  factory Countdown.fromDuration(Duration left, {Key? key}) {
    final h = left.inHours, m = left.inMinutes % 60;
    final text = left.isNegative
        ? 'Lewat batas ambil'
        : (h > 0 ? '$h jam $m menit lagi' : '$m menit lagi');
    return Countdown(text, key: key, urgent: left.inMinutes < 30);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final fg = urgent ? c.urgencyText : c.text;
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: urgent ? c.urgencyTint : c.primaryTint,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

/// Listing Row: thumbnail 72, judul, batas ambil (mono), toko, harga, dan "sumbu" sisa waktu.
class ListingRow extends StatelessWidget {
  const ListingRow({
    super.key,
    required this.title,
    required this.shop,
    required this.deadline,
    required this.price,
    this.normalPrice,
    this.stockLabel,
    this.imageUrl,
    this.timeLeft = 1,
    this.favorite = false,
    this.onTap,
    this.onFavorite,
  });

  final String title;

  /// Mis. "Toko Roti Margonda · 350 m".
  final String shop;

  /// Mis. "20.30".
  final String deadline;

  /// 0 = gratis (donasi).
  final int price;
  final int? normalPrice;

  /// Mis. "2 porsi tersisa".
  final String? stockLabel;
  final String? imageUrl;

  /// Sisa waktu ambil 0..1 untuk garis bawah.
  final double timeLeft;
  final bool favorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final save = (normalPrice != null && normalPrice! > 0 && price > 0)
        ? ((1 - price / normalPrice!) * 100).round()
        : null;
    return InkWell(
      onTap: onTap,
      child: Container(
        color: c.surface,
        padding: const EdgeInsets.only(top: AppSpace.md),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: Container(
                    width: 72,
                    height: 72,
                    color: c.surface2,
                    child: imageUrl == null
                        ? Icon(Icons.fastfood_outlined, color: c.textMuted)
                        : Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                const Icon(Icons.broken_image_outlined),
                          ),
                  ),
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpace.xs),
                      Wrap(
                        spacing: AppSpace.sm,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'Ambil sebelum $deadline',
                            style: AppText.mono.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (stockLabel != null)
                            Text(
                              stockLabel!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                      Text(
                        shop,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: c.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpace.xs),
                      Wrap(
                        spacing: AppSpace.sm,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            price == 0 ? 'Gratis' : rupiah(price),
                            style: AppText.mono.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (normalPrice != null && price > 0)
                            Text(
                              rupiah(normalPrice!),
                              style: AppText.mono.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: c.textMuted,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          if (save != null)
                            Text(
                              'Hemat $save%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: c.primary,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (onFavorite != null)
                  IconButton(
                    tooltip: favorite
                        ? 'Hapus dari favorit'
                        : 'Tambah ke favorit',
                    onPressed: onFavorite,
                    icon: Icon(
                      favorite ? Icons.favorite : Icons.favorite_border,
                      size: 22,
                      color: favorite ? c.error : c.textMuted,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpace.md),
            LinearProgressIndicator(value: timeLeft.clamp(0, 1), minHeight: 3),
          ],
        ),
      ),
    );
  }
}

/// Ticket Strip: bar gelap 48 berisi kode klaim, untuk pesanan aktif (sticky di atas nav).
class TicketStrip extends StatelessWidget {
  const TicketStrip({
    super.key,
    required this.code,
    required this.meta,
    this.onTap,
  });

  /// Mis. "H7K49" (ditampilkan "H7K · 49").
  final String code;

  /// Mis. "Ambil sebelum 20.30 · Roti Margonda".
  final String meta;
  final VoidCallback? onTap;

  static String formatCode(String c) =>
      c.length == 5 ? '${c.substring(0, 3)} · ${c.substring(3)}' : c;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Material(
      color: c.text,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
          decoration: const BoxDecoration(boxShadow: AppShadow.e1),
          child: Row(
            children: [
              Icon(
                Icons.confirmation_number_outlined,
                size: 20,
                color: c.sticker,
              ),
              const SizedBox(width: 10),
              Text(
                formatCode(code),
                style: AppText.mono.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: c.bg,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  meta,
                  style: TextStyle(fontSize: 12, color: c.bg),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.chevron_right, size: 20, color: c.bg),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stat/Struk: angka besar (mono 48) + satuan, dengan label dan badge opsional.
class StatStruk extends StatelessWidget {
  const StatStruk({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.badge,
    this.sub,
  });

  final String label;
  final String value;
  final String? unit;
  final String? badge;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final muted = TextStyle(color: c.textMuted);
    return Container(
      padding: const EdgeInsets.only(top: AppSpace.lg),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.divider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: muted.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  height: 22,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: c.surface2,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Center(
                    widthFactor: 1,
                    child: Text(
                      badge!,
                      style: muted.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpace.sm),
          Wrap(
            spacing: 10,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              Text(
                value,
                style: AppText.mono.copyWith(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              if (unit != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    unit!,
                    style: muted.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          if (sub != null) ...[
            const SizedBox(height: AppSpace.sm),
            Text(sub!, style: muted.copyWith(fontSize: 14)),
          ],
        ],
      ),
    );
  }
}

/// Chart/Bar sederhana. Batang terakhir disorot (periode berjalan).
class BarChart extends StatelessWidget {
  const BarChart({
    super.key,
    required this.values,
    required this.labels,
    this.height = 120,
  });

  /// Panjang harus sama dengan [labels].
  final List<num> values;
  final List<String> labels;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final max = values.fold<num>(0, (a, b) => b > a ? b : a);
    final last = values.length - 1;
    return Column(
      children: [
        SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final (i, v) in values.indexed) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: Tooltip(
                    message: '${labels[i]}: $v',
                    child: Container(
                      height: max == 0 ? 0 : height * v / max,
                      decoration: BoxDecoration(
                        color: i == last ? c.primaryTint : c.primary,
                        border: i == last ? Border.all(color: c.primary) : null,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpace.md),
        Row(
          children: [
            for (final (i, l) in labels.indexed) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: i == last ? FontWeight.w700 : FontWeight.w400,
                    color: i == last ? c.primary : c.textMuted,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Garis & ujung stiker selalu hijau tua (tidak berubah di mode gelap, sesuai design.pen).
const _stickerInk = Color(0xFF14301F);

enum StickerKind { price, free, urgent, selected }

/// Marker/Stiker peta: kuning = harga, putih-hijau = Gratis, oranye = < 30 menit, hijau = terpilih.
class Sticker extends StatelessWidget {
  const Sticker(this.label, {super.key, this.kind = StickerKind.price});

  final String label;
  final StickerKind kind;

  @override
  Widget build(BuildContext context) {
    // Stiker menempel di peta OSM yang tetap terang (desain 1n), jadi selalu pakai palet terang.
    const c = AppColors.light;
    final (bg, fg) = switch (kind) {
      StickerKind.price => (c.sticker, c.onSticker),
      StickerKind.free => (c.surface, c.primary),
      StickerKind.urgent => (c.urgency, c.onSticker),
      StickerKind.selected => (c.primary, c.onPrimary),
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: _stickerInk),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3314301F),
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Center(
            widthFactor: 1,
            child: Text(
              label,
              style: AppText.mono.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ),
        ),
        CustomPaint(size: const Size(12, 7), painter: _TipPainter()),
      ],
    );
  }
}

class _TipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) => canvas.drawPath(
    Path()
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close(),
    Paint()..color = _stickerInk,
  );

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Judul section 20/700 dengan aksi opsional di kanan (mis. "Lihat semua").
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
      if (action != null) TextButton(onPressed: onAction, child: Text(action!)),
    ],
  );
}

/// Status kosong / error / memuat yang seragam untuk semua modul.
class StateView extends StatelessWidget {
  const StateView({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.onAction,
  });

  /// Memuat (spinner).
  const StateView.loading({super.key})
    : icon = null,
      title = 'Memuat…',
      message = null,
      action = null,
      onAction = null;

  /// Gagal memuat + tombol coba lagi.
  const StateView.error({super.key, this.message, this.onAction})
    : icon = Icons.cloud_off_outlined,
      title = 'Gagal memuat data',
      action = 'Coba lagi';

  final IconData? icon;
  final String title;
  final String? message;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final t = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon == null)
              const CircularProgressIndicator()
            else
              Icon(icon, size: 48, color: c.textMuted),
            const SizedBox(height: AppSpace.lg),
            Text(title, style: t.titleMedium, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: AppSpace.xs),
              Text(
                message!,
                style: t.bodyMedium?.copyWith(color: c.textMuted),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpace.lg),
              AppButton.secondary(action!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}
