import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Alces UI Kit - Design System Components

// --------------------------------------------------------
// BUTTONS
// --------------------------------------------------------

class AlcesButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isLoading;

  const AlcesButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? AppTheme.primaryGold : Colors.transparent,
          foregroundColor: isPrimary ? Colors.black : AppTheme.primaryGold,
          elevation: isPrimary ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isPrimary 
                ? BorderSide.none 
                : const BorderSide(color: AppTheme.primaryGold, width: 2),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              )
            : Text(
                text.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isPrimary ? Colors.black : AppTheme.primaryGold,
                ),
              ),
      ),
    );
  }
}

class AlcesTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const AlcesTextButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.primaryGold,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppTheme.primaryGold,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// --------------------------------------------------------
// INPUTS
// --------------------------------------------------------

class AlcesTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;

  const AlcesTextField({
    super.key,
    required this.label,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

// --------------------------------------------------------
// CARDS & CONTAINERS
// --------------------------------------------------------

class AlcesCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const AlcesCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: card,
      );
    }
    
    return card;
  }
}

// --------------------------------------------------------
// LOGO
// --------------------------------------------------------

class AlcesLogo extends StatelessWidget {
  final double height;
  
  const AlcesLogo({super.key, this.height = 120});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback if logo fails to load
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.content_cut, size: 64, color: AppTheme.primaryGold),
            const SizedBox(height: 8),
            Text(
              'ALCE\'S',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                letterSpacing: 8,
              ),
            ),
          ],
        );
      },
    );
  }
}
