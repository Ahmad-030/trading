import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/trading_models.dart';

class MarketDataService {
  // API Keys and Endpoints
  static const String binanceBaseUrl = 'https://api.binance.com';
  static const String alphaVantageBaseUrl = 'https://www.alphavantage.co';
  static const String alphaVantageApiKey = 'V208J9FL9HUITXCL';

  // Singleton pattern
  static final MarketDataService _instance = MarketDataService._internal();
  factory MarketDataService() => _instance;
  MarketDataService._internal();

  // ==================== BINANCE API ====================

  /// Fetch OHLC candlestick data from Binance
  Future<List<CandleData>> getBinanceKlines({
    required String symbol,
    String interval = '15m',
    int limit = 100,
  }) async {
    try {
      final url = Uri.parse(
        '$binanceBaseUrl/api/v3/klines?symbol=$symbol&interval=$interval&limit=$limit',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => CandleData.fromBinance(e)).toList();
      } else {
        throw Exception('Failed to fetch Binance data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Binance API error: $e');
    }
  }

  /// Get current price from Binance
  Future<double> getBinancePrice(String symbol) async {
    try {
      final url = Uri.parse(
        '$binanceBaseUrl/api/v3/ticker/price?symbol=$symbol',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return double.parse(data['price']);
      } else {
        throw Exception('Failed to fetch price: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Binance price API error: $e');
    }
  }

  /// Get 24hr ticker statistics
  Future<Map<String, dynamic>> getBinance24hrStats(String symbol) async {
    try {
      final url = Uri.parse(
        '$binanceBaseUrl/api/v3/ticker/24hr?symbol=$symbol',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch 24hr stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Binance 24hr API error: $e');
    }
  }

  /// Get all trading pairs from Binance
  Future<List<TradingPair>> getBinanceTradingPairs() async {
    try {
      final url = Uri.parse('$binanceBaseUrl/api/v3/exchangeInfo');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final symbols = data['symbols'] as List;

        return symbols
            .where((s) => s['status'] == 'TRADING')
            .map((s) => TradingPair(
          symbol: s['symbol'],
          name: '${s['baseAsset']}/${s['quoteAsset']}',
          category: 'crypto',
          baseAsset: s['baseAsset'],
          quoteAsset: s['quoteAsset'],
        ))
            .toList();
      } else {
        throw Exception('Failed to fetch trading pairs');
      }
    } catch (e) {
      throw Exception('Binance exchange info error: $e');
    }
  }

  // ==================== ALPHA VANTAGE API ====================

  /// Fetch Forex OHLC data from Alpha Vantage
  Future<List<CandleData>> getForexData({
    required String fromSymbol,
    required String toSymbol,
    String interval = '15min',
  }) async {
    try {
      final url = Uri.parse(
        '$alphaVantageBaseUrl/query?function=FX_INTRADAY'
            '&from_symbol=$fromSymbol'
            '&to_symbol=$toSymbol'
            '&interval=$interval'
            '&apikey=$alphaVantageApiKey'
            '&outputsize=compact',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timeSeries = data['Time Series FX (Intraday)'] as Map<String, dynamic>?;

        if (timeSeries == null) {
          throw Exception('No forex data available');
        }

        return timeSeries.entries.map((e) {
          return CandleData(
            time: DateTime.parse(e.key),
            open: double.parse(e.value['1. open']),
            high: double.parse(e.value['2. high']),
            low: double.parse(e.value['3. low']),
            close: double.parse(e.value['4. close']),
            volume: 0,
          );
        }).toList();
      } else {
        throw Exception('Failed to fetch forex data');
      }
    } catch (e) {
      throw Exception('Alpha Vantage forex error: $e');
    }
  }

  /// Fetch stock OHLC data from Alpha Vantage
  Future<List<CandleData>> getStockData({
    required String symbol,
    String interval = '15min',
  }) async {
    try {
      final url = Uri.parse(
        '$alphaVantageBaseUrl/query?function=TIME_SERIES_INTRADAY'
            '&symbol=$symbol'
            '&interval=$interval'
            '&apikey=$alphaVantageApiKey'
            '&outputsize=compact',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timeSeriesKey = 'Time Series ($interval)';
        final timeSeries = data[timeSeriesKey] as Map<String, dynamic>?;

        if (timeSeries == null) {
          throw Exception('No stock data available');
        }

        return timeSeries.entries.map((e) {
          return CandleData.fromAlphaVantage(e.value, e.key);
        }).toList();
      } else {
        throw Exception('Failed to fetch stock data');
      }
    } catch (e) {
      throw Exception('Alpha Vantage stock error: $e');
    }
  }

  /// Get forex exchange rate
  Future<double> getForexRate({
    required String fromCurrency,
    required String toCurrency,
  }) async {
    try {
      final url = Uri.parse(
        '$alphaVantageBaseUrl/query?function=CURRENCY_EXCHANGE_RATE'
            '&from_currency=$fromCurrency'
            '&to_currency=$toCurrency'
            '&apikey=$alphaVantageApiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rateData = data['Realtime Currency Exchange Rate'];
        return double.parse(rateData['5. Exchange Rate']);
      } else {
        throw Exception('Failed to fetch forex rate');
      }
    } catch (e) {
      throw Exception('Alpha Vantage rate error: $e');
    }
  }

  // ==================== POPULAR PAIRS ====================

  /// Get popular crypto pairs
  List<TradingPair> getPopularCryptoPairs() {
    return [
      TradingPair(
        symbol: 'BTCUSDT',
        name: 'Bitcoin/USDT',
        category: 'crypto',
        baseAsset: 'BTC',
        quoteAsset: 'USDT',
      ),
      TradingPair(
        symbol: 'ETHUSDT',
        name: 'Ethereum/USDT',
        category: 'crypto',
        baseAsset: 'ETH',
        quoteAsset: 'USDT',
      ),
      TradingPair(
        symbol: 'BNBUSDT',
        name: 'BNB/USDT',
        category: 'crypto',
        baseAsset: 'BNB',
        quoteAsset: 'USDT',
      ),
      TradingPair(
        symbol: 'XRPUSDT',
        name: 'XRP/USDT',
        category: 'crypto',
        baseAsset: 'XRP',
        quoteAsset: 'USDT',
      ),
      TradingPair(
        symbol: 'SOLUSDT',
        name: 'Solana/USDT',
        category: 'crypto',
        baseAsset: 'SOL',
        quoteAsset: 'USDT',
      ),
      TradingPair(
        symbol: 'ADAUSDT',
        name: 'Cardano/USDT',
        category: 'crypto',
        baseAsset: 'ADA',
        quoteAsset: 'USDT',
      ),
      TradingPair(
        symbol: 'DOGEUSDT',
        name: 'Doge/USDT',
        category: 'crypto',
        baseAsset: 'DOGE',
        quoteAsset: 'USDT',
      ),
      TradingPair(
        symbol: 'DOTUSDT',
        name: 'Polkadot/USDT',
        category: 'crypto',
        baseAsset: 'DOT',
        quoteAsset: 'USDT',
      ),
    ];
  }

  /// Get popular forex pairs
  List<TradingPair> getPopularForexPairs() {
    return [
      TradingPair(
        symbol: 'EURUSD',
        name: 'Euro/USD',
        category: 'forex',
        baseAsset: 'EUR',
        quoteAsset: 'USD',
      ),
      TradingPair(
        symbol: 'GBPUSD',
        name: 'GBP/USD',
        category: 'forex',
        baseAsset: 'GBP',
        quoteAsset: 'USD',
      ),
      TradingPair(
        symbol: 'USDJPY',
        name: 'USD/JPY',
        category: 'forex',
        baseAsset: 'USD',
        quoteAsset: 'JPY',
      ),
      TradingPair(
        symbol: 'AUDUSD',
        name: 'AUD/USD',
        category: 'forex',
        baseAsset: 'AUD',
        quoteAsset: 'USD',
      ),
      TradingPair(
        symbol: 'USDCAD',
        name: 'USD/CAD',
        category: 'forex',
        baseAsset: 'USD',
        quoteAsset: 'CAD',
      ),
      TradingPair(
        symbol: 'XAUUSD',
        name: 'Gold/USD',
        category: 'commodities',
        baseAsset: 'XAU',
        quoteAsset: 'USD',
      ),
    ];
  }

  /// Get all popular pairs
  List<TradingPair> getAllPopularPairs() {
    return [...getPopularCryptoPairs(), ...getPopularForexPairs()];
  }

  // ==================== TECHNICAL INDICATORS ====================

  /// Calculate RSI
  double calculateRSI(List<CandleData> candles, {int period = 14}) {
    if (candles.length < period + 1) return 50.0;

    List<double> gains = [];
    List<double> losses = [];

    for (int i = 1; i <= period; i++) {
      double change = candles[i].close - candles[i - 1].close;
      if (change >= 0) {
        gains.add(change);
        losses.add(0);
      } else {
        gains.add(0);
        losses.add(change.abs());
      }
    }

    double avgGain = gains.reduce((a, b) => a + b) / period;
    double avgLoss = losses.reduce((a, b) => a + b) / period;

    if (avgLoss == 0) return 100.0;

    double rs = avgGain / avgLoss;
    return 100 - (100 / (1 + rs));
  }

  /// Calculate EMA
  double calculateEMA(List<double> prices, int period) {
    if (prices.length < period) return prices.last;

    double multiplier = 2 / (period + 1);
    double ema = prices.take(period).reduce((a, b) => a + b) / period;

    for (int i = period; i < prices.length; i++) {
      ema = (prices[i] - ema) * multiplier + ema;
    }

    return ema;
  }

  /// Calculate MACD
  Map<String, double> calculateMACD(List<CandleData> candles) {
    List<double> closes = candles.map((c) => c.close).toList();

    double ema12 = calculateEMA(closes, 12);
    double ema26 = calculateEMA(closes, 26);
    double macd = ema12 - ema26;

    // Calculate signal line (9-period EMA of MACD)
    // Simplified for this implementation
    double signal = macd * 0.9; // Approximation

    return {
      'macd': macd,
      'signal': signal,
      'histogram': macd - signal,
    };
  }

  /// Calculate Bollinger Bands
  Map<String, double> calculateBollingerBands(List<CandleData> candles, {int period = 20}) {
    if (candles.length < period) {
      return {'upper': 0, 'middle': 0, 'lower': 0};
    }

    List<double> closes = candles.take(period).map((c) => c.close).toList();
    double sma = closes.reduce((a, b) => a + b) / period;

    double variance = closes.map((c) => (c - sma) * (c - sma)).reduce((a, b) => a + b) / period;
    double stdDev = variance > 0 ? variance * 0.5 : 0; // Simplified sqrt

    return {
      'upper': sma + (2 * stdDev),
      'middle': sma,
      'lower': sma - (2 * stdDev),
    };
  }

  /// Calculate ATR (Average True Range)
  double calculateATR(List<CandleData> candles, {int period = 14}) {
    if (candles.length < period + 1) return 0;

    List<double> trueRanges = [];

    for (int i = 1; i < candles.length && i <= period; i++) {
      double highLow = candles[i].high - candles[i].low;
      double highClose = (candles[i].high - candles[i - 1].close).abs();
      double lowClose = (candles[i].low - candles[i - 1].close).abs();

      double tr = [highLow, highClose, lowClose].reduce((a, b) => a > b ? a : b);
      trueRanges.add(tr);
    }

    return trueRanges.reduce((a, b) => a + b) / trueRanges.length;
  }

  /// Get all technical indicators
  TechnicalIndicators calculateAllIndicators(List<CandleData> candles) {
    List<double> closes = candles.map((c) => c.close).toList();

    double rsi = calculateRSI(candles);
    Map<String, double> macd = calculateMACD(candles);
    Map<String, double> bollinger = calculateBollingerBands(candles);
    double atr = calculateATR(candles);

    double ema9 = calculateEMA(closes, 9);
    double ema21 = calculateEMA(closes, 21);
    double ema50 = calculateEMA(closes, 50);

    // Determine trend
    String trend = 'neutral';
    if (ema9 > ema21 && ema21 > ema50) {
      trend = 'bullish';
    } else if (ema9 < ema21 && ema21 < ema50) {
      trend = 'bearish';
    }

    // Determine momentum
    String momentum = 'neutral';
    if (rsi > 70) {
      momentum = 'overbought';
    } else if (rsi < 30) {
      momentum = 'oversold';
    } else if (rsi > 50) {
      momentum = 'bullish';
    } else {
      momentum = 'bearish';
    }

    return TechnicalIndicators(
      rsi: rsi,
      macd: macd['macd'],
      macdSignal: macd['signal'],
      macdHistogram: macd['histogram'],
      ema9: ema9,
      ema21: ema21,
      ema50: ema50,
      bollingerUpper: bollinger['upper'],
      bollingerMiddle: bollinger['middle'],
      bollingerLower: bollinger['lower'],
      atr: atr,
      trend: trend,
      momentum: momentum,
    );
  }
}