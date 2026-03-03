import 'package:cloud_firestore/cloud_firestore.dart';

class Equipo {
  final String id;
  final bool activo; // en tu captura: "activo"
  final String deporte;
  final String entrenadorID;
  final List<String> miembros;
  final String nombre;

  const Equipo({
    required this.id,
    required this.activo,
    required this.deporte,
    required this.entrenadorID,
    required this.miembros,
    required this.nombre,
  });

  factory Equipo.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    final rawMiembros = data['miembros'];
    final miembros = (rawMiembros is List)
        ? rawMiembros.whereType<String>().toList()
        : <String>[];

    return Equipo(
      id: doc.id,
      activo: (data['activo'] as bool?) ?? true,
      deporte: (data['deporte'] as String?) ?? '',
      entrenadorID: (data['entrenadorID'] as String?) ?? '',
      miembros: miembros,
      nombre: (data['nombre'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'activo': activo,
      'deporte': deporte,
      'entrenadorID': entrenadorID,
      'miembros': miembros,
      'nombre': nombre,
    };
  }

  Equipo copyWith({
    bool? activo,
    String? deporte,
    String? entrenadorID,
    List<String>? miembros,
    String? nombre,
  }) {
    return Equipo(
      id: id,
      activo: activo ?? this.activo,
      deporte: deporte ?? this.deporte,
      entrenadorID: entrenadorID ?? this.entrenadorID,
      miembros: miembros ?? this.miembros,
      nombre: nombre ?? this.nombre,
    );
  }
}