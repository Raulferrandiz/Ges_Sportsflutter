import 'package:cloud_firestore/cloud_firestore.dart';

class Incidencia {
  final String id;
  final String creadorID; // en tu captura: "creadorID"
  final DateTime fecha;   // en tu captura: "fecha"
  final String mensaje;
  final String tipo;      // "cancelacion", etc.

  const Incidencia({
    required this.id,
    required this.creadorID,
    required this.fecha,
    required this.mensaje,
    required this.tipo,
  });

  factory Incidencia.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    DateTime toDate(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return Incidencia(
      id: doc.id,
      creadorID: (data['creadorID'] as String?) ?? '',
      fecha: toDate(data['fecha']),
      mensaje: (data['mensaje'] as String?) ?? '',
      tipo: (data['tipo'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'creadorID': creadorID,
      'fecha': Timestamp.fromDate(fecha),
      'mensaje': mensaje,
      'tipo': tipo,
    };
  }

  Incidencia copyWith({
    String? creadorID,
    DateTime? fecha,
    String? mensaje,
    String? tipo,
  }) {
    return Incidencia(
      id: id,
      creadorID: creadorID ?? this.creadorID,
      fecha: fecha ?? this.fecha,
      mensaje: mensaje ?? this.mensaje,
      tipo: tipo ?? this.tipo,
    );
  }
}