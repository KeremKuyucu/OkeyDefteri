import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import '../models/game_models.dart';

class ShareService {
  /// Verilen [key]'deki widget'ı PNG'ye çevirip paylaşım sayfasını açar.
  static Future<void> shareGameCard({
    required GlobalKey repaintKey,
    required Game game,
  }) async {
    try {
      final boundary = repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      // Yüksek çözünürlük için pixelRatio 3.0
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/okey_sonuc_${game.id}.png');
      await file.writeAsBytes(bytes);

      final winTeam = game.leadingTeam;
      final subject = winTeam != null
          ? '🏆 ${winTeam.name} kazandı! — Okey Defteri'
          : '🎴 Okey sonuçları — Okey Defteri';

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          subject: subject,
        ),
      );
    } catch (e) {
      debugPrint('ShareService error: $e');
    }
  }
}
