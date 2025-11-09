class Ticket {
  final String pnr;
  final String seatNo;
  final String status;
  final int trainId;

  Ticket({
    required this.pnr,
    required this.seatNo,
    required this.status,
    required this.trainId,
  });

  factory Ticket.fromJson(Map<String, dynamic> j) => Ticket(
        pnr: j['pnr'] as String,
        seatNo: (j['seat_no'] ?? j['seatNo'] ?? '').toString(),
        status: j['status'] as String,
        trainId: j['train_id'] is int ? j['train_id'] : int.parse(j['train_id'].toString()),
      );
}
