import 'package:flutter/material.dart';

class PerfilCard extends StatelessWidget {
  const PerfilCard({
    super.key,
    required this.nombre,
    required this.rol,
    required this.imagen,
    required this.colorfondo,
    required this.activo,
    required this.onToggleActivo,
  });

  final String nombre;
  final String rol;
  final String imagen;
  final Color colorfondo;
  final bool activo;
  final VoidCallback onToggleActivo;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: activo ? 1.0 : 0.45,
      child: Container(
        height: 200,
        margin: const EdgeInsets.all(16),
        child: Card(
          color: colorfondo,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              nombre.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 24,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: onToggleActivo,
                            icon: Icon(
                              activo ? Icons.toggle_on : Icons.toggle_off,
                              size: 42,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        rol,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 140,
                  height: 140,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF2979FF), Color(0xFF00BCD4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: ClipOval(
                      child: Image.asset(
                        imagen,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/jugador.png', // imagen genérica
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
