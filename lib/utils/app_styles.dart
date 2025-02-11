import 'package:flutter/material.dart';

class AppStyles {
  // Cores mais minimalistas
  static const Color primaryColor = Color(0xFF0984E3); // Azul principal
  static const Color backgroundColor = Color(0xFFF9F9F9); // Fundo geral
  static const Color surfaceColor = Colors.white; // Superfícies (cards, inputs)
  static const Color textPrimaryColor = Color(0xFF2D3436); // Texto principal
  static const Color textSecondaryColor = Color(0xFF636E72); // Texto secundário
  static const Color errorColor = Color(0xFFD63031); // Vermelho para erros
  static const Color successColor = Color(0xFF00B894); // Verde para sucesso
  static const Color accentColor = Color(0xFFFF7F11); // Cor de destaque

  // Sombras
  static final BoxShadow softShadow = BoxShadow(
    color: Colors.black.withValues(alpha: 0.05),
    blurRadius: 10,
    offset: Offset(0, 2),
  );

  // Tipografia padronizada
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
    letterSpacing: -0.5,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: textPrimaryColor,
    letterSpacing: -0.3,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: textPrimaryColor,
    letterSpacing: -0.2,
  );

  static const TextStyle labelStyle = TextStyle(
    fontSize: 14,
    color: textSecondaryColor,
    letterSpacing: -0.2,
  );

  static const TextStyle amountStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: primaryColor,
    letterSpacing: -0.2,
  );

  // Estilos de card
  static const Color cardColor = Color(0xFFFFFFFF); // Cor do card
  static const TextStyle cardTitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static const TextStyle cardSubtitleStyle = TextStyle(
    fontSize: 14,
    color: textSecondaryColor,
  );

  // Decorações padronizadas
  static final BorderRadius borderRadius = BorderRadius.circular(12);

  static final InputDecoration textFieldDecoration = InputDecoration(
    filled: true,
    fillColor: surfaceColor,
    border: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: textSecondaryColor.withValues(alpha: 0.2)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: textSecondaryColor.withValues(alpha: 0.2)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: primaryColor, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: errorColor),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: errorColor, width: 1.5),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    labelStyle: labelStyle,
    errorStyle: labelStyle.copyWith(color: errorColor),
  );

  // Estilos de botões padronizados
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: borderRadius),
  );

  static final ButtonStyle secondaryButtonStyle = TextButton.styleFrom(
    foregroundColor: primaryColor,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: borderRadius),
  );
}
