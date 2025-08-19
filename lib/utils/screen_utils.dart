import 'package:flutter/material.dart';
import 'dart:math';

class ScreenUtils {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double safeAreaHorizontal;
  static late double safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;
  static late double textScaleFactor;
  static late bool isTablet;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - safeAreaVertical) / 100;

    textScaleFactor = _mediaQueryData.textScaleFactor;
    isTablet = screenWidth > 600;
  }

  // Responsive width
  static double wp(double percentage) {
    return percentage * screenWidth / 100;
  }

  // Responsive height
  static double hp(double percentage) {
    return percentage * screenHeight / 100;
  }

  // Responsive font size
  static double sp(double size) {
    return size * (screenWidth / 3) / 100;
  }

  // Calculate optimal grid cell size for 15x10
  static double getOptimalCellSize() {
    // Reserve space for UI elements
    double reservedHeight = hp(35);
    double availableHeight = screenHeight - reservedHeight;

    // Calculate cell size for 15 rows and 10 columns
    double cellSizeByHeight = availableHeight / 15; // 15 rows
    double cellSizeByWidth = (screenWidth - wp(8)) / 10; // 10 columns

    double cellSize = min(cellSizeByHeight, cellSizeByWidth);
    return cellSize.clamp(20.0, 40.0); // Adjusted for 15 rows
  }

  // Get grid dimensions that fit on screen
  static Size getOptimalGridSize() {
    double cellSize = getOptimalCellSize();
    return Size(cellSize * 10, cellSize * 10);
  }

  // Calculate responsive padding
  static EdgeInsets getResponsivePadding() {
    return EdgeInsets.symmetric(horizontal: wp(4), vertical: hp(2));
  }

  // Calculate button size
  static double getButtonSize() {
    return isTablet ? wp(15) : wp(20);
  }

  // Get text style with responsive size
  static TextStyle getResponsiveTextStyle({
    required double baseFontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return TextStyle(
      fontSize: sp(baseFontSize),
      fontWeight: fontWeight,
      color: color,
    );
  }

  // Check if device is small (height < 600)
  static bool get isSmallDevice => screenHeight < 600;

  // Check if device is large (height > 800)
  static bool get isLargeDevice => screenHeight > 800;

  // Get scaled size for any dimension
  static double getScaledSize(double size) {
    return size * min(screenWidth / 375, screenHeight / 667);
  }

  // Get safe area insets
  static EdgeInsets get safeAreaInsets => _mediaQueryData.padding;

  // Calculate available height for game grid
  static double getAvailableGameHeight() {
    double statusBarHeight = _mediaQueryData.padding.top;
    double navigationBarHeight = _mediaQueryData.padding.bottom;
    double reservedForUI = hp(30); // Header, controls, spacing

    return screenHeight - statusBarHeight - navigationBarHeight - reservedForUI;
  }

  // Calculate optimal number of visible rows
  static int getOptimalVisibleRows() {
    return 15; // Always show all 15 rows for 10x10 grid
  }
}
