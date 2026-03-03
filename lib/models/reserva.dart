import 'package:cloud_firestore/cloud_firestore.dart';

class Reserva {
  final String id;
  final bool activa;
  final String deporte;
  final DateTime startAt;
  final DateTime endAt;
  final String pistaID;
  final String userID;

  const Reserva({
    required this.id,
    required this.activa,
    required this.deporte,
    required this.startAt,
    required this.endAt,
    required this.pistaID,
    required this.userID,
  });

  factory Reserva.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    final startTs = data['startAt'];
    final endTs = data['endAt'];

    DateTime toDate(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      // fallback seguro
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return Reserva(
      id: doc.id,
      activa: (data['activa'] as bool?) ?? true,
      deporte: (data['deporte'] as String?) ?? '',
      startAt: toDate(startTs),
      endAt: toDate(endTs),
      pistaID: (data['pistaID'] as String?) ?? '',
      userID: (data['userID'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'activa': activa,
      'deporte': deporte,
      'startAt': Timestamp.fromDate(startAt),
      'endAt': Timestamp.fromDate(endAt),
      'pistaID': pistaID,
      'userID': userID,
    };
  }

  Reserva copyWith({
    bool? activa,
    String? deporte,
    DateTime? startAt,
    DateTime? endAt,
    String? pistaID,
    String? userID,
  }) {
    return Reserva(
      id: id,
      activa: activa ?? this.activa,
      deporte: deporte ?? this.deporte,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      pistaID: pistaID ?? this.pistaID,
      userID: userID ?? this.userID,
    );
  }
}