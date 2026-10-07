import 'package:flutter/material.dart';

// Same background as the wordmark PNG so the logo blends in.
const Color kHeaderBg = Color(0xFFEBE2D3);
const Color kHeaderBrown = Color(0xFF6B4423);
const Color kHeaderDark = Color(0xFF3B2314);

class HigopHeader extends StatelessWidget {
  /// Shows a "Log In" button on the right when not null (use it for guests).
  final VoidCallback? onLoginTap;

  /// Optional small line under the logo, e.g. "Higop muna. Pick your drink."
  final String? tagline;

  const HigopHeader({super.key, this.onLoginTap, this.tagline});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: kHeaderBg,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Height only, so the logo keeps its proportions.
                  Image.asset(
                    'assets/icon/higop_wordmark.png',
                    height: 64,
                    fit: BoxFit.contain,
                  ),
                  const Spacer(),
                  if (onLoginTap != null)
                    TextButton.icon(
                      onPressed: onLoginTap,
                      icon: const Icon(Icons.login, size: 20),
                      label: const Text('Log In'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: kHeaderBrown,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                ],
              ),
              if (tagline != null) ...[
                const SizedBox(height: 8),
                Text(
                  tagline!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: kHeaderDark,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}