class Train {
  final int id;
  final String name;
  final String source;
  final String destination;
  final String departure;
  final String arrival;

  Train({
    required this.id,
    required this.name,
    required this.source,
    required this.destination,
    required this.departure,
    required this.arrival,
  });

  factory Train.fromJson(Map<String, dynamic> j) => Train(
        id: j['id'] is int ? j['id'] : int.parse(j['id'].toString()),
        name: j['name'] as String,
        source: j['source'] as String,
        destination: j['destination'] as String,
        departure: j['departure'] as String,
        arrival: j['arrival'] as String,
      );
}
