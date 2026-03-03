import 'package:flutter/material.dart';

class BasicToogle extends StatefulWidget {
  final bool initial;
  final ValueChanged<bool>? onChanged; // equivale a void Function(bool)?

  const BasicToogle({super.key, this.initial = false, this.onChanged});

  @override
  State<BasicToogle> createState() => _BasicToogleState();
}

class _BasicToogleState extends State<BasicToogle> {
  late bool activo;

  final TextEditingController _nameCtrl = TextEditingController(
    text: "Introduce el login",
  );
  final String administrador = "admin@gmail.com";

  @override
  void initState() {
    super.initState();
    activo = widget.initial;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _nameCtrl.text = "Inicio";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(activo ? "ON" : "OFF"),
          const SizedBox(height: 8),
          Switch(
            value: activo,
            onChanged: (v) {
              setState(() => activo = v);
              widget.onChanged?.call(v);
            },
          ),

          const SizedBox(height: 20),

          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: "Login",
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}), // refresca vista al escribir
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              final texto = _nameCtrl.text;
              var mensaje = "";
              if (texto == administrador) {
                mensaje = "USUARIO CORRECTO";
              } else {
                mensaje = "USUARIO INCORRECTO";
              }
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(mensaje)));
            },
            child: Text("LOGUEAR"),
          ),
        ],
      ),
    );
  }
}
