// MODELO MUTABLE 
class User {
  final String id;
  final String email;
  final String nombre;
  final String rol;
  bool activo;

  User({
    required this.id,
    required this.email,
    required this.nombre,
    required this.rol,
    this.activo = true,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      nombre: map['nombre'] ?? '',
      rol: map['rol'] ?? '',
      activo: map['activo'] ?? true,
    );
  }

  factory User.fromDoc(String id, Map<String, dynamic> map) {
    return User(
      id: id,
      email: (map['email'] ?? '') as String,
      nombre: (map['nombre'] ?? '') as String,
      rol: (map['rol'] ?? '') as String,
      activo: (map['activo'] ?? true) as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nombre': nombre,
      'rol': rol,
      'activo': activo,
    };
  }

  User copyWith({
    String? email,
    String? nombre,
    String? rol,
    bool? activo,
  }) {
    return User(
      id: id,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      rol: rol ?? this.rol,
      activo: activo ?? this.activo,
    );
  }
}