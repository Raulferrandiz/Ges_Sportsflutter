// MODELO MUTABLE 
class User {
  final String id;
  final String email;
  final String nombre;
  final String rol;
  final String imagen;
  final int colorfondo;
  bool activo;

  User({
    required this.id,
    required this.email,
    required this.nombre,
    required this.rol,
    required this.imagen,
    required this.colorfondo,
    this.activo = true,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      nombre: map['nombre'] ?? '',
      rol: map['rol'] ?? '',
      imagen: map['imagen'] ?? 'assets/images/jugador.png',
      colorfondo: map['colorfondo'] ?? 1,
      activo: map['activo'] ?? true,
    );
  }

  factory User.fromDoc(String id, Map<String, dynamic> map) {
    return User(
      id: id,
      email: (map['email'] ?? '') as String,
      nombre: (map['nombre'] ?? '') as String,
      rol: (map['rol'] ?? '') as String,
      imagen: (map['imagen'] ?? 'assets/images/jugador.png') as String,
      colorfondo: (map['colorfondo'] ?? 1) as int,
      activo: (map['activo'] ?? true) as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nombre': nombre,
      'rol': rol,
      'imagen': imagen,
      'colorfondo': colorfondo,
      'activo': activo,
    };
  }

  User copyWith({
    String? email,
    String? nombre,
    String? rol,
    String? imagen,
    int? colorfondo,
    bool? activo,
  }) {
    return User(
      id: id,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      rol: rol ?? this.rol,
      imagen: imagen ?? this.imagen,
      colorfondo: colorfondo ?? this.colorfondo,
      activo: activo ?? this.activo,
    );
  }
}