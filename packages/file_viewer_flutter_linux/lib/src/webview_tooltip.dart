import 'dart:async';

import 'package:flutter/material.dart';

/// Displays delayed CEF tooltip text in the Flutter overlay above its view.
class WebviewTooltip {
  /// Uses the view [context] to obtain its overlay and render-box bounds.
  WebviewTooltip(BuildContext context) {
    _overlayState = Overlay.of(context);
    _box = context.findRenderObject() as RenderBox;
  }
  late OverlayState _overlayState;
  OverlayEntry? _overlayEntry;
  Timer? _timer;
  TooltipStatus _eStatus = TooltipStatus.hide;
  /// Pointer position relative to the browser widget, used to place the tooltip.
  Offset cursorOffset = Offset.zero;
  late RenderBox _box;
  final TextStyle _textStyle =
      const TextStyle(color: Colors.black, fontSize: 14);

  void _buildOverlayEntry(String text) {
    //往Overlay中插入插入OverlayEntry
    _timer = Timer(const Duration(milliseconds: 500), () {
      if (_disposed) return;
      _overlayEntry = OverlayEntry(builder: (context) {
        double height = _box.size.height;
        double width = _box.size.width;
        TextPainter textPainter = TextPainter(
          locale: Localizations.localeOf(context),
          textDirection: TextDirection.ltr,
          text: TextSpan(text: text, style: _textStyle),
          maxLines: 5,
          ellipsis: '...',
        )..layout(maxWidth: width - 16);
        if (cursorOffset.dy + textPainter.height + 25 > height) {
          cursorOffset =
              Offset(cursorOffset.dx, height - textPainter.height - 10);
          if (cursorOffset.dy < 0) {
            cursorOffset = Offset(cursorOffset.dx, 0);
          }
        } else {
          cursorOffset = Offset(cursorOffset.dx, cursorOffset.dy + 15);
        }

        if (cursorOffset.dx + textPainter.width + 40 > width) {
          cursorOffset =
              Offset(width - textPainter.width - 25, cursorOffset.dy);
          if (cursorOffset.dx < 0) {
            cursorOffset = Offset(0, cursorOffset.dy);
          }
        } else {
          cursorOffset = Offset(cursorOffset.dx + 15, cursorOffset.dy);
        }
        return Positioned(
          top: cursorOffset.dy,
          left: cursorOffset.dx,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: textPainter.width + 16,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 2, color: Colors.black.withValues(alpha: .2))
                ],
              ),
              child: RichText(
                text: TextSpan(text: text, style: _textStyle),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      });
      _overlayState.insert(_overlayEntry!);
      _eStatus = TooltipStatus.shown;
    });
  }

  bool _disposed = false;

  /// Cancels pending display and removes any existing tooltip overlay.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _timer?.cancel();
    if (_overlayEntry?.mounted == true) _overlayEntry!.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
  }

  /// Schedules [text] for display, or hides the tooltip when [text] is empty.
  void showToolTip(String text) {
    if (_disposed) return;
    if (text.isEmpty) {
      if (_eStatus == TooltipStatus.prepare) {
        _timer?.cancel();
      } else {
        if (_overlayEntry?.mounted == true) _overlayEntry!.remove();
        _overlayEntry?.dispose();
        _overlayEntry = null;
      }
      _eStatus = TooltipStatus.hide;
      return;
    } else if (_eStatus == TooltipStatus.hide) {
      _eStatus = TooltipStatus.prepare;
      _buildOverlayEntry(text);
    }
  }
}

/// Lifecycle of the adapter's delayed tooltip overlay.
enum TooltipStatus {
  /// The display timer is waiting to show the tooltip.
  prepare,
  /// The tooltip's overlay entry is visible.
  shown,
  /// No tooltip is currently visible or scheduled.
  hide
}
