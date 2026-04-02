import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

void showTopMessage(
  BuildContext context,
  String message, {
  required bool isError,
}) {
  final ms = ScaffoldMessenger.of(context);
  ms.clearMaterialBanners();
  ms.showMaterialBanner(
    MaterialBanner(
      content: Text(
        message,
        style: GoogleFonts.cabin(color: AppTheme.textHigh, fontSize: 14),
      ),
      backgroundColor: isError ? AppTheme.danger : AppTheme.success,
      actions: [
        IconButton(
          icon: const Icon(Icons.close_rounded, color: AppTheme.textHigh),
          onPressed: () => ms.hideCurrentMaterialBanner(),
        ),
      ],
    ),
  );
  Future<void>.delayed(const Duration(seconds: 3), () {
    if (!context.mounted) return;
    ms.clearMaterialBanners();
  });
}
