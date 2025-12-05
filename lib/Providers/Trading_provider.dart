import 'package:flutter/material.dart';
import '../Services/MarketData_Service.dart';
import '../models/trading_models.dart';
import '../services/ai_signal_service.dart';
import '../services/firebase_service.dart';

enum TradingStatus {
  initial,
  loading,
  loaded,
  analyzing,
  error,
}

class TradingProvider extends ChangeNotifier {
  final MarketDataService _marketService = MarketDataService();
  final AISignalService _aiService = AISignalService();
  final FirebaseService _firebaseService = FirebaseService();

  TradingStatus _status = TradingStatus.initial;
  String? _errorMessage;

  // Market Data
  List<TradingPair> _popularPairs = [];
  List<TradingPair> _allPairs = [];
  TradingPair? _selectedPair;
  List<CandleData> _candles = [];
  Map<String, dynamic> _ticker24h = {};
  double _currentPrice = 0;

  // Technical Indicators
  TechnicalIndicators? _indicators;

  // Trading Signal
  TradingSignal? _currentSignal;
  List<TradingSignal> _signalHistory = [];

  // Settings
  String _selectedTimeframe = '15m';
  String _tradingStyle = 'intraday';

  // Getters
  TradingStatus get status => _status;
  String? get errorMessage => _errorMessage;
  List<TradingPair> get popularPairs => _popularPairs;
  List<TradingPair> get allPairs => _allPairs;
  TradingPair? get selectedPair => _selectedPair;
  List<CandleData> get candles => _candles;
  Map<String, dynamic> get ticker24h => _ticker24h;
  double get currentPrice => _currentPrice;
  TechnicalIndicators? get indicators => _indicators;
  TradingSignal? get currentSignal => _currentSignal;
  List<TradingSignal> get signalHistory => _signalHistory;
  String get selectedTimeframe => _selectedTimeframe;
  String get tradingStyle => _tradingStyle;

  TradingProvider() {
    _init();
  }

  void _init() {
    _popularPairs = _marketService.getAllPopularPairs();
    _loadSignalHistory();
  }

  /// Load signal history from Firebase
  Future<void> _loadSignalHistory() async {
    try {
      _signalHistory = await _firebaseService.getSignalHistory();
      notifyListeners();
    } catch (e) {
      // Handle error silently
    }
  }

  /// Select a trading pair
  Future<void> selectPair(TradingPair pair) async {
    _selectedPair = pair;
    _status = TradingStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _fetchMarketData(pair);
      _status = TradingStatus.loaded;
    } catch (e) {
      _status = TradingStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  /// Fetch market data for selected pair
  Future<void> _fetchMarketData(TradingPair pair) async {
    try {
      if (pair.category == 'crypto') {
        // Fetch from Binance
        _candles = await _marketService.getBinanceKlines(
          symbol: pair.symbol,
          interval: _selectedTimeframe,
          limit: 100,
        );
        _currentPrice = await _marketService.getBinancePrice(pair.symbol);
        _ticker24h = await _marketService.getBinance24hrStats(pair.symbol);
      } else {
        // Fetch from Alpha Vantage for forex
        _candles = await _marketService.getForexData(
          fromSymbol: pair.baseAsset,
          toSymbol: pair.quoteAsset,
          interval: _convertTimeframe(_selectedTimeframe),
        );
        _currentPrice = _candles.isNotEmpty ? _candles.last.close : 0;
      }

      // Calculate technical indicators
      if (_candles.isNotEmpty) {
        _indicators = _marketService.calculateAllIndicators(_candles);
      }
    } catch (e) {
      throw Exception('Failed to fetch market data: $e');
    }
  }

  /// Convert timeframe format for Alpha Vantage
  String _convertTimeframe(String timeframe) {
    switch (timeframe) {
      case '1m':
        return '1min';
      case '5m':
        return '5min';
      case '15m':
        return '15min';
      case '30m':
        return '30min';
      case '1h':
        return '60min';
      default:
        return '15min';
    }
  }

  /// Change timeframe
  Future<void> setTimeframe(String timeframe) async {
    if (_selectedTimeframe == timeframe) return;

    _selectedTimeframe = timeframe;
    notifyListeners();

    if (_selectedPair != null) {
      await selectPair(_selectedPair!);
    }
  }

  /// Change trading style
  void setTradingStyle(String style) {
    _tradingStyle = style;
    notifyListeners();
  }

  /// Generate AI trading signal
  Future<void> generateSignal({bool useFullAI = true}) async {
    if (_selectedPair == null || _candles.isEmpty || _indicators == null) {
      _errorMessage = 'Please select a trading pair first';
      notifyListeners();
      return;
    }

    _status = TradingStatus.analyzing;
    _errorMessage = null;
    notifyListeners();

    try {
      if (useFullAI) {
        // Use DeepSeek AI for full analysis
        _currentSignal = await _aiService.generateSignal(
          symbol: _selectedPair!.symbol,
          candles: _candles,
          indicators: _indicators!,
          timeframe: _selectedTimeframe,
          tradingStyle: _tradingStyle,
        );
      } else {
        // Use quick local analysis
        _currentSignal = _aiService.quickAnalysis(
          symbol: _selectedPair!.symbol,
          candles: _candles,
          indicators: _indicators!,
          timeframe: _selectedTimeframe,
        );
      }

      // Save to Firebase
      if (_currentSignal != null) {
        await _firebaseService.saveSignalToHistory(_currentSignal!);
        _signalHistory.insert(0, _currentSignal!);
      }

      _status = TradingStatus.loaded;
    } catch (e) {
      _status = TradingStatus.error;
      _errorMessage = 'Signal generation failed: $e';
    }
    notifyListeners();
  }

  /// Refresh market data
  Future<void> refreshData() async {
    if (_selectedPair != null) {
      await selectPair(_selectedPair!);
    }
  }

  /// Clear current signal
  void clearSignal() {
    _currentSignal = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Search trading pairs
  List<TradingPair> searchPairs(String query) {
    if (query.isEmpty) return _popularPairs;

    query = query.toLowerCase();
    return _popularPairs.where((pair) {
      return pair.symbol.toLowerCase().contains(query) ||
          pair.name.toLowerCase().contains(query) ||
          pair.baseAsset.toLowerCase().contains(query);
    }).toList();
  }

  /// Get pairs by category
  List<TradingPair> getPairsByCategory(String category) {
    return _popularPairs.where((pair) => pair.category == category).toList();
  }

  /// Add to favorites
  Future<void> addToFavorites(String symbol) async {
    await _firebaseService.addFavoriteSymbol(symbol);
  }

  /// Remove from favorites
  Future<void> removeFromFavorites(String symbol) async {
    await _firebaseService.removeFavoriteSymbol(symbol);
  }

  /// Get price change percentage
  double get priceChange24h {
    if (_ticker24h.isEmpty) return 0;
    return double.tryParse(_ticker24h['priceChangePercent'] ?? '0') ?? 0;
  }

  /// Get 24h volume
  double get volume24h {
    if (_ticker24h.isEmpty) return 0;
    return double.tryParse(_ticker24h['volume'] ?? '0') ?? 0;
  }

  /// Get 24h high
  double get high24h {
    if (_ticker24h.isEmpty) return 0;
    return double.tryParse(_ticker24h['highPrice'] ?? '0') ?? 0;
  }

  /// Get 24h low
  double get low24h {
    if (_ticker24h.isEmpty) return 0;
    return double.tryParse(_ticker24h['lowPrice'] ?? '0') ?? 0;
  }

  /// Available timeframes
  List<String> get availableTimeframes => [
    '1m',
    '5m',
    '15m',
    '30m',
    '1h',
    '4h',
    '1d',
  ];

  /// Trading styles
  List<Map<String, String>> get tradingStyles => [
    {'key': 'scalping', 'label': 'Scalping', 'duration': '1-15 min'},
    {'key': 'intraday', 'label': 'Intraday', 'duration': '15-120 min'},
    {'key': 'swing', 'label': 'Swing', 'duration': '4-24 hours'},
    {'key': 'longterm', 'label': 'Long Term', 'duration': '1-7 days'},
  ];
}