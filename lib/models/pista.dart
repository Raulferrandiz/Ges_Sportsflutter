import 'package:cloud_firestore/cloud_firestore.dart';

class Pista {
  final String id;
  final bool activa;
  final String direccion; // en tu captura: "pista 1"
  final String nombre;    // "Pista de padel 1"
  final String tipo;      // "padel"

  const Pista({
    required this.id,
    required this.activa,
    required this.direccion,
    required this.nombre,
    required this.tipo,
  });

  factory Pista.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Pista(
      id: doc.id,
      activa: (data['activa'] as bool?) ?? true,
      direccion: (data['direccion'] as String?) ?? '',
      nombre: (data['nombre'] as String?) ?? '',
      tipo: (data['tipo'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'activa': activa,
      'direccion': direccion,
      'nombre': nombre,
      'tipo': tipo,
    };
  }

  Pista copyWith({
    bool? activa,
    String? direccion,
    String? nombre,
    String? tipo,
  }) {
    return Pista(
      id: id,
      activa: activa ?? this.activa,
      direccion: direccion ?? this.direccion,
      nombre: nombre ?? this.nombre,
      tipo: tipo ?? this.tipo,
    );
  }
}