import 'package:flutter/foundation.dart';
import '../models/train.dart';
import '../models/ticket.dart';
import 'api.dart';

class AppState extends ChangeNotifier {
  final ApiClient api = ApiClient();

  String? userName;
  List<Train> currentResults = [];
  Train? selectedTrain;
  Ticket? lastTicket;
  bool loading = false;
  String? lastError;

  void setUser(String name) {
    userName = name;
    notifyListeners();
  }

  Future<void> search({String? from, String? to}) async {
    loading = true;
    lastError = null;
    notifyListeners();
    try {
      currentResults = await api.fetchTrains(from: from, to: to);
    } catch (e) {
      lastError = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> book({
    required Train train,
    required String seatNo,
    required String travelClass,
    required String passengerName,
  }) async {
    loading = true;
    lastError = null;
    notifyListeners();
    try {
      lastTicket = await api.bookSeat(
        trainId: train.id,
        seatNo: seatNo,
        travelClass: travelClass,
        passengerName: passengerName,
        userName: userName,
      );
      selectedTrain = train;
      return true;
    } catch (e) {
      lastError = e.toString();
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
