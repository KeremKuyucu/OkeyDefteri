import '../services/localization_service.dart';

/// Skor giriş türleri
enum ScoreType {
  islekAtti, // +101 İşlek attı
  okeyAtti, // +101 Okey attı
  okeyiniAldilar, // +101 Okeyini aldılar
  yanlisElActi, // +101 Yanlış el açtı
  normalBitti, // -101 Normal bitti (elle kapattı)
  eldenBitti, // -202 Elden bitti
  okeyAtarakBitti, // -202 Okey atarak bitti
  okeyAtarakEldenBitti, // 2x + -404 Okey atarak elden bitti
  acamadi, // +202 Açamadı
  attigiTasiAldilar, // Manuel puan - Attığı taşı aldılar
  eldeKalanTaslar, // Manuel puan - Elde kalan taşlar
  // Americano'ya özel
  americanoEldeKalan, // Elde kalan kart değeri (Americano)
  americanoIslek, // İşlek atma cezası +50 (Americano)
  americanoHile, // Hile yakalanma cezası +50 (Americano)
  americanoKazandi, // Turu kazandı (-30 puan) (Americano)
  americanoOkeyElindeKaldi, // Okey elinde kaldı cezası +30 puan (Americano)
  americanoTakimYokOkeyAldi, // Takım yok okeyini alma cezası +50 (Americano)
  americanoOkeyAtti, // Okey atma cezası +50 (Americano)
  americanoYanlisElActi, // Yanlış el açma cezası +50 (Americano)
  americanoIslekAtarakBitti, // İşlek atarak bitti +100 puan ceza (Americano)
  americanoOkeyAtarakBitti, // Okey atarak bitti -100 puan (Americano)
  americanoYanlisBitti, // Yanlış bitti cezası +100 puan (Americano)
  // Normal Okey'e özel
  normalOkeyBitti, // Kazanan - 1 puan
  normalOkeyAtarakBitti, // Kazanan (Okey atarak) - 2 puan
  normalOkeyCiftBitti, // Kazanan (Çift biterek) - 2 puan
  normalOkeyCiftVeOkeyBitti, // Kazanan (Hem Çift hem Okey atarak) - 4 puan
}

extension ScoreTypeExtension on ScoreType {
  String get label {
    switch (this) {
      case ScoreType.islekAtti:
        return Localization.t('score_types.islek_atti');
      case ScoreType.okeyAtti:
        return Localization.t('score_types.okey_atti');
      case ScoreType.okeyiniAldilar:
        return Localization.t('score_types.okeyini_aldilar');
      case ScoreType.yanlisElActi:
        return Localization.t('score_types.yanlis_el_acti');
      case ScoreType.normalBitti:
        return Localization.t('score_types.normal_bitti');
      case ScoreType.eldenBitti:
        return Localization.t('score_types.elden_bitti');
      case ScoreType.okeyAtarakBitti:
        return Localization.t('score_types.okey_atarak_bitti');
      case ScoreType.okeyAtarakEldenBitti:
        return Localization.t('score_types.okey_atarak_elden_bitti');
      case ScoreType.acamadi:
        return Localization.t('score_types.acamadi');
      case ScoreType.attigiTasiAldilar:
        return Localization.t('score_types.attigi_tasi_aldilar');
      case ScoreType.eldeKalanTaslar:
        return Localization.t('score_types.elde_kalan_taslar');
      case ScoreType.americanoEldeKalan:
        return Localization.t('score_types.americano_elde_kalan');
      case ScoreType.americanoIslek:
        return Localization.t('score_types.americano_islek');
      case ScoreType.americanoHile:
        return Localization.t('score_types.americano_hile');
      case ScoreType.americanoKazandi:
        return Localization.t('score_types.americano_kazandi');
      case ScoreType.americanoOkeyElindeKaldi:
        return Localization.t('score_types.americano_okey_elinde_kaldi');
      case ScoreType.americanoTakimYokOkeyAldi:
        return Localization.t('score_types.americano_takim_yok_okey_aldi');
      case ScoreType.americanoOkeyAtti:
        return Localization.t('score_types.americano_okey_atti');
      case ScoreType.americanoYanlisElActi:
        return Localization.t('score_types.americano_yanlis_el_acti');
      case ScoreType.americanoIslekAtarakBitti:
        return Localization.t('score_types.americano_islek_atarak_bitti');
      case ScoreType.americanoOkeyAtarakBitti:
        return Localization.t('score_types.americano_okey_atarak_bitti');
      case ScoreType.americanoYanlisBitti:
        return Localization.t('score_types.americano_yanlis_bitti');
      case ScoreType.normalOkeyBitti:
        return Localization.t('score_types.normal_okey_bitti');
      case ScoreType.normalOkeyAtarakBitti:
        return Localization.t('score_types.normal_okey_okey_atti');
      case ScoreType.normalOkeyCiftBitti:
        return Localization.t('score_types.normal_okey_cift_bitti');
      case ScoreType.normalOkeyCiftVeOkeyBitti:
        return Localization.t('score_types.normal_okey_cift_ve_okey_bitti');
    }
  }

  String get emoji {
    switch (this) {
      case ScoreType.islekAtti:
        return '🎯';
      case ScoreType.okeyAtti:
        return '🃏❌';
      case ScoreType.okeyiniAldilar:
        return '🃏';
      case ScoreType.yanlisElActi:
        return '❌';
      case ScoreType.normalBitti:
        return '✅';
      case ScoreType.eldenBitti:
        return '🏆';
      case ScoreType.okeyAtarakBitti:
        return '🃏🏆';
      case ScoreType.okeyAtarakEldenBitti:
        return '👑🃏';
      case ScoreType.acamadi:
        return '🚫';
      case ScoreType.attigiTasiAldilar:
        return '🪨';
      case ScoreType.eldeKalanTaslar:
        return '✋';
      case ScoreType.americanoEldeKalan:
        return '🃏';
      case ScoreType.americanoIslek:
        return '🎯';
      case ScoreType.americanoHile:
        return '🚫';
      case ScoreType.americanoKazandi:
        return '🏆';
      case ScoreType.americanoOkeyElindeKaldi:
        return '🃏✋';
      case ScoreType.americanoTakimYokOkeyAldi:
        return '🃏⚠️';
      case ScoreType.americanoOkeyAtti:
        return '🃏❌';
      case ScoreType.americanoYanlisElActi:
        return '❌';
      case ScoreType.americanoIslekAtarakBitti:
        return '🎯🏁';
      case ScoreType.americanoOkeyAtarakBitti:
        return '🃏🏆';
      case ScoreType.americanoYanlisBitti:
        return '⚠️❌';
      case ScoreType.normalOkeyBitti:
        return '✅';
      case ScoreType.normalOkeyAtarakBitti:
        return '🃏🏆';
      case ScoreType.normalOkeyCiftBitti:
        return '👥🏆';
      case ScoreType.normalOkeyCiftVeOkeyBitti:
        return '👑🃏';
    }
  }

  int get defaultPoints {
    switch (this) {
      case ScoreType.islekAtti:
        return 101;
      case ScoreType.okeyAtti:
        return 101;
      case ScoreType.okeyiniAldilar:
        return 101;
      case ScoreType.yanlisElActi:
        return 101;
      case ScoreType.normalBitti:
        return -101;
      case ScoreType.eldenBitti:
        return -202;
      case ScoreType.okeyAtarakBitti:
        return -202;
      case ScoreType.okeyAtarakEldenBitti:
        return -404;
      case ScoreType.acamadi:
        return 202;
      case ScoreType.attigiTasiAldilar:
        return 0; // Manuel giriş
      case ScoreType.eldeKalanTaslar:
        return 0; // Manuel giriş
      case ScoreType.americanoEldeKalan:
        return 0; // Manuel giriş
      case ScoreType.americanoIslek:
        return 50;
      case ScoreType.americanoHile:
        return 50;
      case ScoreType.americanoKazandi:
        return -30;
      case ScoreType.americanoOkeyElindeKaldi:
        return 30;
      case ScoreType.americanoTakimYokOkeyAldi:
        return 50;
      case ScoreType.americanoOkeyAtti:
        return 50;
      case ScoreType.americanoYanlisElActi:
        return 50;
      case ScoreType.americanoIslekAtarakBitti:
        return 100;
      case ScoreType.americanoOkeyAtarakBitti:
        return -100;
      case ScoreType.americanoYanlisBitti:
        return 100;
      case ScoreType.normalOkeyBitti:
        return 1;
      case ScoreType.normalOkeyAtarakBitti:
        return 2;
      case ScoreType.normalOkeyCiftBitti:
        return 2;
      case ScoreType.normalOkeyCiftVeOkeyBitti:
        return 4;
    }
  }

  bool get isManual {
    return this == ScoreType.attigiTasiAldilar ||
        this == ScoreType.eldeKalanTaslar ||
        this == ScoreType.americanoEldeKalan;
  }

  /// Bu tür Americano'ya özel ek ceza tipi mi?
  bool get isAmericanoPenalty {
    return this == ScoreType.americanoIslek ||
        this == ScoreType.americanoHile ||
        this == ScoreType.americanoOkeyElindeKaldi ||
        this == ScoreType.americanoTakimYokOkeyAldi ||
        this == ScoreType.americanoOkeyAtti ||
        this == ScoreType.americanoYanlisElActi ||
        this == ScoreType.americanoIslekAtarakBitti ||
        this == ScoreType.americanoYanlisBitti;
  }

  /// Americano'ya mı özel?
  bool get isAmericano {
    return this == ScoreType.americanoEldeKalan ||
        this == ScoreType.americanoIslek ||
        this == ScoreType.americanoHile ||
        this == ScoreType.americanoKazandi ||
        this == ScoreType.americanoOkeyElindeKaldi ||
        this == ScoreType.americanoTakimYokOkeyAldi ||
        this == ScoreType.americanoOkeyAtti ||
        this == ScoreType.americanoYanlisElActi ||
        this == ScoreType.americanoIslekAtarakBitti ||
        this == ScoreType.americanoOkeyAtarakBitti ||
        this == ScoreType.americanoYanlisBitti;
  }

  /// Normal Okey'e mi özel?
  bool get isNormalOkey {
    return this == ScoreType.normalOkeyBitti ||
        this == ScoreType.normalOkeyAtarakBitti ||
        this == ScoreType.normalOkeyCiftBitti ||
        this == ScoreType.normalOkeyCiftVeOkeyBitti;
  }

  /// Bu tür bir bitirme türü mü?
  bool get isFinishType {
    return this == ScoreType.normalBitti ||
        this == ScoreType.eldenBitti ||
        this == ScoreType.okeyAtarakBitti ||
        this == ScoreType.okeyAtarakEldenBitti ||
        this == ScoreType.americanoKazandi ||
        this == ScoreType.americanoIslekAtarakBitti ||
        this == ScoreType.americanoOkeyAtarakBitti ||
        this == ScoreType.americanoYanlisBitti ||
        this == ScoreType.normalOkeyBitti ||
        this == ScoreType.normalOkeyAtarakBitti ||
        this == ScoreType.normalOkeyCiftBitti ||
        this == ScoreType.normalOkeyCiftVeOkeyBitti;
  }

  /// Bu ceza türü için "kim yaptı?" sorusu sorulacak mı?
  bool get hasCausedBy {
    return this == ScoreType.okeyiniAldilar ||
        this == ScoreType.attigiTasiAldilar;
  }

  /// causedBy sorusu label'ı
  String get causedByLabel {
    switch (this) {
      case ScoreType.okeyiniAldilar:
        return Localization.t('score_types.caused_by_okeyini_aldilar');
      case ScoreType.attigiTasiAldilar:
        return Localization.t('score_types.caused_by_attigi_tasi_aldilar');
      default:
        return '';
    }
  }
}

class ScoreEntry {
  final String id;
  final ScoreType type;
  final int points;
  final bool isCiftli; // Oyuncu kendisi çiftli gidiyordu
  final bool isOkeyFinish; // O el okey atılarak bitti (x2)
  final bool isCauserCiftli; // Cezayı verdiren kişi çiftli gidiyordu (x2)
  final DateTime timestamp;
  final int roundNumber;
  final String? causedByPlayerId;

  ScoreEntry({
    required this.id,
    required this.type,
    required this.points,
    this.isCiftli = false,
    this.isOkeyFinish = false,
    this.isCauserCiftli = false,
    required this.timestamp,
    required this.roundNumber,
    this.causedByPlayerId,
  });

  int get effectivePoints {
    int p = points;
    if (isCiftli) p *= 2;
    if (isOkeyFinish) p *= 2;
    if (isCauserCiftli) p *= 2;
    return p;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'points': points,
    'isCiftli': isCiftli,
    'isOkeyFinish': isOkeyFinish,
    'isCauserCiftli': isCauserCiftli,
    'timestamp': timestamp.toIso8601String(),
    'roundNumber': roundNumber,
    'causedByPlayerId': causedByPlayerId,
  };

  factory ScoreEntry.fromJson(Map<String, dynamic> json) => ScoreEntry(
    id: json['id'],
    type: _parseScoreType(json['type']),
    points: json['points'],
    isCiftli: json['isCiftli'] ?? false,
    isOkeyFinish: json['isOkeyFinish'] ?? false,
    isCauserCiftli: json['isCauserCiftli'] ?? false,
    timestamp: DateTime.parse(json['timestamp']),
    roundNumber: json['roundNumber'],
    causedByPlayerId: json['causedByPlayerId'],
  );

  /// Geriye dönük uyumluluk: eski kayıtlarda int index, yenilerde String name
  static ScoreType _parseScoreType(dynamic raw) {
    if (raw is int) return ScoreType.values[raw];
    try {
      return ScoreType.values.byName(raw as String);
    } catch (_) {
      return ScoreType.eldeKalanTaslar; // bilinmeyen değer için fallback
    }
  }
}
