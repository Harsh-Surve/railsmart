import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/train.dart';
import '../models/ticket.dart';

class ApiClient {
  // For Android emulator use 10.0.2.2 instead of localhost.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE',
    // Default to localhost to work in Flutter web/desktop out of the box.
    defaultValue: 'http://localhost:5000',
  );

  Future<List<Train>> fetchTrains({String? from, String? to}) async {
    final uri = Uri.parse('$baseUrl/api/trains').replace(queryParameters: {
      if (from != null && from.isNotEmpty) 'from': from,
      if (to != null && to.isNotEmpty) 'to': to,
    });
    final resp = await http.get(uri).timeout(const Duration(seconds: 8));
    if (resp.statusCode != 200) {
      throw Exception('Failed to load trains (${resp.statusCode})');
    }
    final data = jsonDecode(resp.body) as List;
    return data.map((e) => Train.fromJson(e)).toList();
  }

  Future<Ticket> bookSeat({
    required int trainId,
    required String seatNo,
    required String travelClass,
    required String passengerName,
    String? userName,
  }) async {
    final uri = Uri.parse('$baseUrl/api/book');
    final body = jsonEncode({
      'train_id': trainId,
      'seat_no': seatNo,
      'class': travelClass,
      'passenger_name': passengerName,
      if (userName != null) 'user_name': userName,
    });
  final resp = await http
    .post(uri, headers: {'Content-Type': 'application/json'}, body: body)
        .timeout(const Duration(seconds: 10));
    if (resp.statusCode != 201) {
      final error = _safeError(resp.body);
      throw Exception('Booking failed (${resp.statusCode}): $error');
    }
    final data = jsonDecode(resp.body);
    return Ticket.fromJson(data);
  }

  String _safeError(String raw) {
    try {
      final m = jsonDecode(raw);
      return m['error']?.toString() ?? raw;
    } catch (_) {
      return raw;
    }
  }
}
