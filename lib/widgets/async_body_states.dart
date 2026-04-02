import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

class StreamLoadingBody extends StatelessWidget {
  const StreamLoadingBody({super.key, required this.r});

  final R r;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: r.dp(36),
        height: r.dp(36),
        child: CircularProgressIndicator(
          color: AppTheme.cyan,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class StreamErrorBody extends StatelessWidget {
  const StreamErrorBody({
    super.key,
    required this.r,
    required this.message,
    this.hint,
    this.onRetry,
  });

  final R r;
  final String message;
  final String? hint;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(r.dp(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppTheme.danger,
              size: r.dp(40),
            ),
            SizedBox(height: r.dp(12)),
            Text(
              'Could not load',
              style: GoogleFonts.cabin(
                color: AppTheme.textHigh,
                fontWeight: FontWeight.w700,
                fontSize: r.sp(16),
              ),
            ),
            SizedBox(height: r.dp(8)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.cabin(
                color: AppTheme.textMid,
                fontSize: r.sp(12),
              ),
            ),
            if (hint != null) ...[
              SizedBox(height: r.dp(8)),
              Text(
                hint!,
                textAlign: TextAlign.center,
                style: GoogleFonts.cabin(
                  color: AppTheme.textLow,
                  fontSize: r.sp(11),
                ),
              ),
            ],
            if (onRetry != null) ...[
              SizedBox(height: r.dp(16)),
              FilledButton.tonalIcon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class StreamEmptyBody extends StatelessWidget {
  const StreamEmptyBody({
    super.key,
    required this.r,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final R r;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: r.dp(44), color: AppTheme.textLow),
          SizedBox(height: r.dp(14)),
          Text(
            title,
            style: GoogleFonts.cabin(
              color: AppTheme.textMid,
              fontSize: r.sp(16),
            ),
          ),
          SizedBox(height: r.dp(6)),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.cabin(
              color: AppTheme.textLow,
              fontSize: r.sp(13),
            ),
          ),
        ],
      ),
    );
  }
}
