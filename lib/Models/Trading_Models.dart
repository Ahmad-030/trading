import 'package:cloud_firestore/cloud_firestore.dart';

// Trading Pair Model
class TradingPair {
  final String symbol;
  final String name;
  final String category; // forex, crypto, commodities
  final String baseAsset;
  final String quoteAsset;
  final String iconUrl;
  final bool isFavorite;

  TradingPair({
    required this.symbol,
    required this.name,
    required this.category,
    required this.baseAsset,
    required this.quoteAsset,
    this.iconUrl = '',
    this.isFavorite = false,
  });

  factory TradingPair.fromJson(Map<String, dynamic> json) {
    return TradingPair(
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? 'crypto',
      baseAsset: json['baseAsset'] ?? '',
      quoteAsset: json['quoteAsset'] ?? '',
      iconUrl: json['iconUrl'] ?? '',
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'category': category,
      'baseAsset': baseAsset,
      'quoteAsset': quoteAsset,
      'iconUrl': iconUrl,
      'isFavorite': isFavorite,
    };
  }
}

// OHLC Candle Model
class CandleData {
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  CandleData({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  factory CandleData.fromBinance(List<dynamic> data) {
    return CandleData(
      time: DateTime.fromMillisecondsSinceEpoch(data[0]),
      open: double.parse(data[1]),
      high: double.parse(data[2]),
      low: double.parse(data[3]),
      close: double.parse(data[4]),
      volume: double.parse(data[5]),
    );
  }

  factory CandleData.fromAlphaVantage(Map<String, dynamic> data, String dateKey) {
    return CandleData(
      time: DateTime.parse(dateKey),
      open: double.parse(data['1. open'] ?? '0'),
      high: double.parse(data['2. high'] ?? '0'),
      low: double.parse(data['3. low'] ?? '0'),
      close: double.parse(data['4. close'] ?? '0'),
      volume: double.parse(data['5. volume'] ?? '0'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time.toIso8601String(),
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'volume': volume,
    };
  }

  bool get isBullish => close > open;
  bool get isBearish => close < open;
  double get bodySize => (close - open).abs();
  double get upperWick => high - (isBullish ? close : open);
  double get lowerWick => (isBullish ? open : close) - low;
}

// Trading Signal Model
class TradingSignal {
  final String id;
  final String symbol;
  final String signalType; // BUY, SELL, WAIT
  final double entryPrice;
  final double stopLoss;
  final double takeProfit;
  final double confidence;
  final String timeframe;
  final String tradeDuration;
  final String analysis;
  final List<String> reasons;
  final Map<String, dynamic> indicators;
  final DateTime createdAt;
  final String status; // active, completed, cancelled

  TradingSignal({
    required this.id,
    required this.symbol,
    required this.signalType,
    required this.entryPrice,
    required this.stopLoss,
    required this.takeProfit,
    required this.confidence,
    required this.timeframe,
    required this.tradeDuration,
    required this.analysis,
    required this.reasons,
    required this.indicators,
    required this.createdAt,
    this.status = 'active',
  });

  factory TradingSignal.fromJson(Map<String, dynamic> json) {
    return TradingSignal(
      id: json['id'] ?? '',
      symbol: json['symbol'] ?? '',
      signalType: json['signalType'] ?? 'WAIT',
      entryPrice: (json['entryPrice'] ?? 0).toDouble(),
      stopLoss: (json['stopLoss'] ?? 0).toDouble(),
      takeProfit: (json['takeProfit'] ?? 0).toDouble(),
      confidence: (json['confidence'] ?? 0).toDouble(),
      timeframe: json['timeframe'] ?? '15m',
      tradeDuration: json['tradeDuration'] ?? 'N/A',
      analysis: json['analysis'] ?? '',
      reasons: List<String>.from(json['reasons'] ?? []),
      indicators: Map<String, dynamic>.from(json['indicators'] ?? {}),
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'signalType': signalType,
      'entryPrice': entryPrice,
      'stopLoss': stopLoss,
      'takeProfit': takeProfit,
      'confidence': confidence,
      'timeframe': timeframe,
      'tradeDuration': tradeDuration,
      'analysis': analysis,
      'reasons': reasons,
      'indicators': indicators,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }

  double get riskRewardRatio {
    final risk = (entryPrice - stopLoss).abs();
    final reward = (takeProfit - entryPrice).abs();
    return risk > 0 ? reward / risk : 0;
  }

  double get potentialProfit {
    return ((takeProfit - entryPrice) / entryPrice * 100).abs();
  }

  double get potentialLoss {
    return ((stopLoss - entryPrice) / entryPrice * 100).abs();
  }
}

// User Model
class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final bool isApproved;
  final bool isAdmin;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final List<String> favoriteSymbols;
  final Map<String, dynamic> preferences;

  AppUser({
    required this.uid,
    required this.email,
    this.displayName = '',
    this.photoUrl = '',
    this.isApproved = false,
    this.isAdmin = false,
    required this.createdAt,
    this.approvedAt,
    this.favoriteSymbols = const [],
    this.preferences = const {},
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      isApproved: json['isApproved'] ?? false,
      isAdmin: json['isAdmin'] ?? false,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      approvedAt: json['approvedAt'] != null
          ? (json['approvedAt'] is Timestamp
          ? (json['approvedAt'] as Timestamp).toDate()
          : DateTime.parse(json['approvedAt']))
          : null,
      favoriteSymbols: List<String>.from(json['favoriteSymbols'] ?? []),
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'isApproved': isApproved,
      'isAdmin': isAdmin,
      'createdAt': createdAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'favoriteSymbols': favoriteSymbols,
      'preferences': preferences,
    };
  }
}

// Signal History Model
class SignalHistory {
  final String id;
  final String signalId;
  final String userId;
  final String symbol;
  final String signalType;
  final double entryPrice;
  final double? exitPrice;
  final double? profitLoss;
  final bool? wasSuccessful;
  final DateTime createdAt;
  final DateTime? closedAt;
  final String notes;

  SignalHistory({
    required this.id,
    required this.signalId,
    required this.userId,
    required this.symbol,
    required this.signalType,
    required this.entryPrice,
    this.exitPrice,
    this.profitLoss,
    this.wasSuccessful,
    required this.createdAt,
    this.closedAt,
    this.notes = '',
  });

  factory SignalHistory.fromJson(Map<String, dynamic> json) {
    return SignalHistory(
      id: json['id'] ?? '',
      signalId: json['signalId'] ?? '',
      userId: json['userId'] ?? '',
      symbol: json['symbol'] ?? '',
      signalType: json['signalType'] ?? '',
      entryPrice: (json['entryPrice'] ?? 0).toDouble(),
      exitPrice: json['exitPrice']?.toDouble(),
      profitLoss: json['profitLoss']?.toDouble(),
      wasSuccessful: json['wasSuccessful'],
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      closedAt: json['closedAt'] != null
          ? (json['closedAt'] is Timestamp
          ? (json['closedAt'] as Timestamp).toDate()
          : DateTime.parse(json['closedAt']))
          : null,
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'signalId': signalId,
      'userId': userId,
      'symbol': symbol,
      'signalType': signalType,
      'entryPrice': entryPrice,
      'exitPrice': exitPrice,
      'profitLoss': profitLoss,
      'wasSuccessful': wasSuccessful,
      'createdAt': createdAt.toIso8601String(),
      'closedAt': closedAt?.toIso8601String(),
      'notes': notes,
    };
  }
}

// Technical Indicators Model
class TechnicalIndicators {
  final double? rsi;
  final double? macd;
  final double? macdSignal;
  final double? macdHistogram;
  final double? ema9;
  final double? ema21;
  final double? ema50;
  final double? sma20;
  final double? sma50;
  final double? sma200;
  final double? bollingerUpper;
  final double? bollingerMiddle;
  final double? bollingerLower;
  final double? atr;
  final double? adx;
  final double? stochK;
  final double? stochD;
  final String? trend;
  final String? momentum;

  TechnicalIndicators({
    this.rsi,
    this.macd,
    this.macdSignal,
    this.macdHistogram,
    this.ema9,
    this.ema21,
    this.ema50,
    this.sma20,
    this.sma50,
    this.sma200,
    this.bollingerUpper,
    this.bollingerMiddle,
    this.bollingerLower,
    this.atr,
    this.adx,
    this.stochK,
    this.stochD,
    this.trend,
    this.momentum,
  });

  factory TechnicalIndicators.fromJson(Map<String, dynamic> json) {
    return TechnicalIndicators(
      rsi: json['rsi']?.toDouble(),
      macd: json['macd']?.toDouble(),
      macdSignal: json['macdSignal']?.toDouble(),
      macdHistogram: json['macdHistogram']?.toDouble(),
      ema9: json['ema9']?.toDouble(),
      ema21: json['ema21']?.toDouble(),
      ema50: json['ema50']?.toDouble(),
      sma20: json['sma20']?.toDouble(),
      sma50: json['sma50']?.toDouble(),
      sma200: json['sma200']?.toDouble(),
      bollingerUpper: json['bollingerUpper']?.toDouble(),
      bollingerMiddle: json['bollingerMiddle']?.toDouble(),
      bollingerLower: json['bollingerLower']?.toDouble(),
      atr: json['atr']?.toDouble(),
      adx: json['adx']?.toDouble(),
      stochK: json['stochK']?.toDouble(),
      stochD: json['stochD']?.toDouble(),
      trend: json['trend'],
      momentum: json['momentum'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rsi': rsi,
      'macd': macd,
      'macdSignal': macdSignal,
      'macdHistogram': macdHistogram,
      'ema9': ema9,
      'ema21': ema21,
      'ema50': ema50,
      'sma20': sma20,
      'sma50': sma50,
      'sma200': sma200,
      'bollingerUpper': bollingerUpper,
      'bollingerMiddle': bollingerMiddle,
      'bollingerLower': bollingerLower,
      'atr': atr,
      'adx': adx,
      'stochK': stochK,
      'stochD': stochD,
      'trend': trend,
      'momentum': momentum,
    };
  }
}