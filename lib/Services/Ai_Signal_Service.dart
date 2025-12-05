import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/trading_models.dart';

class AISignalService {
  // DeepSeek API Configuration
  static const String deepSeekBaseUrl = 'https://api.deepseek.com';
  static const String deepSeekApiKey = 'sk-7660ebdd022047ad81d7ada1244f494c';

  // Singleton pattern
  static final AISignalService _instance = AISignalService._internal();
  factory AISignalService() => _instance;
  AISignalService._internal();

  /// Generate trading signal using DeepSeek AI
  Future<TradingSignal> generateSignal({
    required String symbol,
    required List<CandleData> candles,
    required TechnicalIndicators indicators,
    required String timeframe,
    String tradingStyle = 'intraday', // scalping, intraday, swing, longterm
  }) async {
    try {
      // Prepare market data summary for AI
      final marketDataSummary = _prepareMarketDataSummary(candles, indicators);

      // Create the AI prompt
      final prompt = _buildAnalysisPrompt(
        symbol: symbol,
        marketData: marketDataSummary,
        indicators: indicators,
        timeframe: timeframe,
        tradingStyle: tradingStyle,
      );

      // Call DeepSeek API
      final response = await _callDeepSeekAPI(prompt);

      // Parse AI response into TradingSignal
      return _parseAIResponse(response, symbol, timeframe, candles.last.close);
    } catch (e) {
      throw Exception('AI Signal generation failed: $e');
    }
  }

  /// Prepare market data summary
  Map<String, dynamic> _prepareMarketDataSummary(
      List<CandleData> candles,
      TechnicalIndicators indicators,
      ) {
    if (candles.isEmpty) {
      return {'error': 'No candle data available'};
    }

    // Get recent candles summary
    final recentCandles = candles.take(20).toList();
    final currentPrice = candles.last.close;
    final previousClose = candles.length > 1 ? candles[candles.length - 2].close : currentPrice;
    final priceChange = ((currentPrice - previousClose) / previousClose) * 100;

    // Calculate high/low from recent candles
    double recentHigh = recentCandles.map((c) => c.high).reduce((a, b) => a > b ? a : b);
    double recentLow = recentCandles.map((c) => c.low).reduce((a, b) => a < b ? a : b);

    // Count bullish vs bearish candles
    int bullishCount = recentCandles.where((c) => c.isBullish).length;
    int bearishCount = recentCandles.where((c) => c.isBearish).length;

    // Calculate average volume
    double avgVolume = recentCandles.map((c) => c.volume).reduce((a, b) => a + b) / recentCandles.length;
    bool volumeIncreasing = candles.last.volume > avgVolume * 1.2;

    return {
      'currentPrice': currentPrice,
      'priceChange': priceChange,
      'recentHigh': recentHigh,
      'recentLow': recentLow,
      'bullishCandles': bullishCount,
      'bearishCandles': bearishCount,
      'avgVolume': avgVolume,
      'currentVolume': candles.last.volume,
      'volumeIncreasing': volumeIncreasing,
      'candlePattern': _detectCandlePattern(recentCandles),
    };
  }

  /// Detect candlestick patterns
  String _detectCandlePattern(List<CandleData> candles) {
    if (candles.length < 3) return 'insufficient_data';

    final last = candles.last;
    final prev = candles[candles.length - 2];
    final prevPrev = candles[candles.length - 3];

    // Doji detection
    double bodySize = last.bodySize;
    double totalRange = last.high - last.low;
    if (totalRange > 0 && bodySize / totalRange < 0.1) {
      return 'doji';
    }

    // Hammer / Hanging Man
    if (last.lowerWick > last.bodySize * 2 && last.upperWick < last.bodySize * 0.5) {
      return last.isBullish ? 'hammer' : 'hanging_man';
    }

    // Engulfing patterns
    if (last.isBullish && prev.isBearish && last.open < prev.close && last.close > prev.open) {
      return 'bullish_engulfing';
    }
    if (last.isBearish && prev.isBullish && last.open > prev.close && last.close < prev.open) {
      return 'bearish_engulfing';
    }

    // Three white soldiers / Three black crows
    if (last.isBullish && prev.isBullish && prevPrev.isBullish) {
      return 'three_white_soldiers';
    }
    if (last.isBearish && prev.isBearish && prevPrev.isBearish) {
      return 'three_black_crows';
    }

    return 'no_pattern';
  }

  /// Build the analysis prompt for AI
  String _buildAnalysisPrompt({
    required String symbol,
    required Map<String, dynamic> marketData,
    required TechnicalIndicators indicators,
    required String timeframe,
    required String tradingStyle,
  }) {
    return '''
You are an expert trading analyst. Analyze the following market data and provide a trading signal.

SYMBOL: $symbol
TIMEFRAME: $timeframe
TRADING STYLE: $tradingStyle

CURRENT MARKET DATA:
- Current Price: ${marketData['currentPrice']}
- Price Change: ${marketData['priceChange']?.toStringAsFixed(2)}%
- Recent High: ${marketData['recentHigh']}
- Recent Low: ${marketData['recentLow']}
- Bullish Candles (last 20): ${marketData['bullishCandles']}
- Bearish Candles (last 20): ${marketData['bearishCandles']}
- Volume Increasing: ${marketData['volumeIncreasing']}
- Candle Pattern: ${marketData['candlePattern']}

TECHNICAL INDICATORS:
- RSI (14): ${indicators.rsi?.toStringAsFixed(2)}
- MACD: ${indicators.macd?.toStringAsFixed(6)}
- MACD Signal: ${indicators.macdSignal?.toStringAsFixed(6)}
- MACD Histogram: ${indicators.macdHistogram?.toStringAsFixed(6)}
- EMA 9: ${indicators.ema9?.toStringAsFixed(6)}
- EMA 21: ${indicators.ema21?.toStringAsFixed(6)}
- EMA 50: ${indicators.ema50?.toStringAsFixed(6)}
- Bollinger Upper: ${indicators.bollingerUpper?.toStringAsFixed(6)}
- Bollinger Middle: ${indicators.bollingerMiddle?.toStringAsFixed(6)}
- Bollinger Lower: ${indicators.bollingerLower?.toStringAsFixed(6)}
- ATR: ${indicators.atr?.toStringAsFixed(6)}
- Trend: ${indicators.trend}
- Momentum: ${indicators.momentum}

Please provide your analysis in the following JSON format ONLY (no other text):
{
  "signal": "BUY" or "SELL" or "WAIT",
  "confidence": 0-100,
  "entry_price": number,
  "stop_loss": number,
  "take_profit": number,
  "trade_duration": "estimated duration in minutes/hours",
  "analysis": "brief market analysis",
  "reasons": ["reason1", "reason2", "reason3"],
  "risk_level": "low" or "medium" or "high"
}

Consider:
1. Trend direction and strength
2. Momentum indicators (RSI overbought/oversold)
3. MACD crossover signals
4. Price action patterns
5. Support/resistance from Bollinger Bands
6. Volume confirmation
7. Risk management (appropriate SL/TP based on ATR)
''';
  }

  /// Call DeepSeek API
  Future<String> _callDeepSeekAPI(String prompt) async {
    try {
      final url = Uri.parse('$deepSeekBaseUrl/chat/completions');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $deepSeekApiKey',
        },
        body: json.encode({
          'model': 'deepseek-chat',
          'messages': [
            {
              'role': 'system',
              'content': 'You are an expert trading analyst. Always respond with valid JSON only, no markdown or extra text.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.3,
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('DeepSeek API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('DeepSeek API call failed: $e');
    }
  }

  /// Parse AI response into TradingSignal
  TradingSignal _parseAIResponse(
      String aiResponse,
      String symbol,
      String timeframe,
      double currentPrice,
      ) {
    try {
      // Clean the response (remove markdown if present)
      String cleanedResponse = aiResponse
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final data = json.decode(cleanedResponse);

      // Extract values with defaults
      String signalType = (data['signal'] ?? 'WAIT').toString().toUpperCase();
      double confidence = (data['confidence'] ?? 50).toDouble();
      double entryPrice = (data['entry_price'] ?? currentPrice).toDouble();
      double stopLoss = (data['stop_loss'] ?? currentPrice * 0.98).toDouble();
      double takeProfit = (data['take_profit'] ?? currentPrice * 1.02).toDouble();
      String tradeDuration = data['trade_duration'] ?? '30-60 minutes';
      String analysis = data['analysis'] ?? 'Market analysis completed.';
      List<String> reasons = List<String>.from(data['reasons'] ?? ['Technical analysis']);

      return TradingSignal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        symbol: symbol,
        signalType: signalType,
        entryPrice: entryPrice,
        stopLoss: stopLoss,
        takeProfit: takeProfit,
        confidence: confidence,
        timeframe: timeframe,
        tradeDuration: tradeDuration,
        analysis: analysis,
        reasons: reasons,
        indicators: {
          'risk_level': data['risk_level'] ?? 'medium',
        },
        createdAt: DateTime.now(),
      );
    } catch (e) {
      // Return a default WAIT signal if parsing fails
      return TradingSignal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        symbol: symbol,
        signalType: 'WAIT',
        entryPrice: currentPrice,
        stopLoss: currentPrice * 0.98,
        takeProfit: currentPrice * 1.02,
        confidence: 50,
        timeframe: timeframe,
        tradeDuration: 'N/A',
        analysis: 'Unable to generate clear signal. Market conditions unclear.',
        reasons: ['Insufficient data for analysis'],
        indicators: {'risk_level': 'high'},
        createdAt: DateTime.now(),
      );
    }
  }

  /// Quick analysis without full AI call (for faster response)
  TradingSignal quickAnalysis({
    required String symbol,
    required List<CandleData> candles,
    required TechnicalIndicators indicators,
    required String timeframe,
  }) {
    double currentPrice = candles.last.close;
    String signalType = 'WAIT';
    double confidence = 50;
    List<String> reasons = [];

    // RSI-based signals
    if (indicators.rsi != null) {
      if (indicators.rsi! < 30) {
        signalType = 'BUY';
        confidence += 15;
        reasons.add('RSI oversold (${indicators.rsi!.toStringAsFixed(1)})');
      } else if (indicators.rsi! > 70) {
        signalType = 'SELL';
        confidence += 15;
        reasons.add('RSI overbought (${indicators.rsi!.toStringAsFixed(1)})');
      }
    }

    // EMA crossover
    if (indicators.ema9 != null && indicators.ema21 != null) {
      if (indicators.ema9! > indicators.ema21!) {
        if (signalType == 'BUY' || signalType == 'WAIT') {
          signalType = 'BUY';
          confidence += 10;
          reasons.add('EMA 9 above EMA 21 (bullish)');
        }
      } else {
        if (signalType == 'SELL' || signalType == 'WAIT') {
          signalType = 'SELL';
          confidence += 10;
          reasons.add('EMA 9 below EMA 21 (bearish)');
        }
      }
    }

    // MACD
    if (indicators.macdHistogram != null) {
      if (indicators.macdHistogram! > 0) {
        if (signalType == 'BUY') confidence += 10;
        reasons.add('MACD histogram positive');
      } else {
        if (signalType == 'SELL') confidence += 10;
        reasons.add('MACD histogram negative');
      }
    }

    // Trend confirmation
    if (indicators.trend == 'bullish' && signalType == 'BUY') {
      confidence += 15;
      reasons.add('Confirmed bullish trend');
    } else if (indicators.trend == 'bearish' && signalType == 'SELL') {
      confidence += 15;
      reasons.add('Confirmed bearish trend');
    }

    // Calculate SL/TP based on ATR
    double atr = indicators.atr ?? (currentPrice * 0.01);
    double stopLoss = signalType == 'BUY'
        ? currentPrice - (atr * 1.5)
        : currentPrice + (atr * 1.5);
    double takeProfit = signalType == 'BUY'
        ? currentPrice + (atr * 2.5)
        : currentPrice - (atr * 2.5);

    // Cap confidence at 95
    confidence = confidence.clamp(0, 95);

    // Estimate trade duration based on timeframe
    String tradeDuration;
    switch (timeframe) {
      case '1m':
      case '5m':
        tradeDuration = '5-15 minutes';
        break;
      case '15m':
        tradeDuration = '15-45 minutes';
        break;
      case '30m':
        tradeDuration = '30-90 minutes';
        break;
      case '1h':
        tradeDuration = '1-4 hours';
        break;
      case '4h':
        tradeDuration = '4-12 hours';
        break;
      default:
        tradeDuration = '1-24 hours';
    }

    if (reasons.isEmpty) {
      reasons.add('No clear signal detected');
    }

    return TradingSignal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      symbol: symbol,
      signalType: signalType,
      entryPrice: currentPrice,
      stopLoss: stopLoss,
      takeProfit: takeProfit,
      confidence: confidence,
      timeframe: timeframe,
      tradeDuration: tradeDuration,
      analysis: 'Quick technical analysis based on key indicators.',
      reasons: reasons,
      indicators: {
        'rsi': indicators.rsi,
        'trend': indicators.trend,
        'momentum': indicators.momentum,
      },
      createdAt: DateTime.now(),
    );
  }
}