import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:login/providers/user_provider.dart';
import 'package:login/models/user.dart';

enum _BackAction { cancel, discard, save }

class UserFormScreen extends StatefulWidget {
  final User? userToEdit;

  const UserFormScreen({super.key, this.userToEdit});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();

  static const Color appOrange = Color(0xFFF59E0B);

  late final TextEditingController emailCtrl;
  late final TextEditingController nombreCtrl;
  late final TextEditingController imagenCtrl;

  late bool activo;
  late String rolSeleccionado;

  late final String _initialEmail;
  late final String _initialNombre;
  late final String _initialImagen;
  late final bool _initialActivo;
  late final String _initialRol;

  late final int _fixedColorFondo;

  bool get isEdit => widget.userToEdit != null;

  @override
  void initState() {
    super.initState();

    emailCtrl = TextEditingController(text: widget.userToEdit?.email ?? '');
    nombreCtrl = TextEditingController(text: widget.userToEdit?.nombre ?? '');
    imagenCtrl = TextEditingController(
      text: widget.userToEdit?.imagen ?? 'assets/images/jugador.png',
    );

    activo = widget.userToEdit?.activo ?? true;

    final rolInicial = (widget.userToEdit?.rol ?? 'jugador').toLowerCase();
    const rolesValidos = {'admin', 'jugador', 'entrenador'};
    rolSeleccionado = rolesValidos.contains(rolInicial) ? rolInicial : 'jugador';

    _initialEmail = emailCtrl.text;
    _initialNombre = nombreCtrl.text;
    _initialImagen = imagenCtrl.text;
    _initialActivo = activo;
    _initialRol = rolSeleccionado;

    _fixedColorFondo = widget.userToEdit?.colorfondo ?? 0xFF93D2E7;
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    nombreCtrl.dispose();
    imagenCtrl.dispose();
    super.dispose();
  }

  bool get _hasUnsavedChanges {
    return emailCtrl.text != _initialEmail ||
        nombreCtrl.text != _initialNombre ||
        imagenCtrl.text != _initialImagen ||
        activo != _initialActivo ||
        rolSeleccionado != _initialRol;
  }

  Future<void> _handleBack() async {
    if (!_hasUnsavedChanges) {
      if (mounted) Navigator.pop(context);
      return;
    }

    final action = await showDialog<_BackAction>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Guardar cambios?'),
        content: const Text('Tienes cambios sin guardar. ¿Qué quieres hacer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _BackAction.cancel),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _BackAction.discard),
            child: const Text('Salir sin guardar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: appOrange),
            onPressed: () => Navigator.pop(context, _BackAction.save),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (action == _BackAction.discard) {
      Navigator.pop(context);
      return;
    }

    if (action == _BackAction.save) {
      final ok = await _guardar(popAfterSave: false);
      if (ok && mounted) Navigator.pop(context);
    }
  }

  Future<bool> _guardar({required bool popAfterSave}) async {
    if (!_formKey.currentState!.validate()) return false;

    final provider = context.read<UserProvider>();

    if (isEdit) {
      final updated = widget.userToEdit!.copyWith(
        nombre: nombreCtrl.text.trim(),
        rol: rolSeleccionado,
        imagen: imagenCtrl.text.trim(),
        colorfondo: _fixedColorFondo,
        activo: activo,
      );

      await provider.update(updated.id, updated);
    } else {
      final newUser = User(
        id: '',
        email: emailCtrl.text.trim().toLowerCase(),
        nombre: nombreCtrl.text.trim(),
        rol: rolSeleccionado,
        imagen: imagenCtrl.text.trim(),
        colorfondo: _fixedColorFondo,
        activo: activo,
      );

      await provider.add(newUser);
    }

    if (popAfterSave && mounted) Navigator.pop(context);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _handleBack,
          ),
          title: Text(
            isEdit ? 'Editar usuario' : 'Nuevo usuario',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: appOrange,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _input(
                  controller: emailCtrl,
                  label: 'Email',
                  enabled: !isEdit,
                  validator: (v) {
                    final value = (v ?? '').trim();
                    if (value.isEmpty) return 'Introduce un email';
                    if (!value.contains('@')) return 'Email inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _input(
                  controller: nombreCtrl,
                  label: 'Nombre',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Introduce un nombre' : null,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: rolSeleccionado,
                  decoration: InputDecoration(
                    labelText: 'Rol',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('admin')),
                    DropdownMenuItem(value: 'jugador', child: Text('jugador')),
                    DropdownMenuItem(value: 'entrenador', child: Text('entrenador')),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => rolSeleccionado = v);
                  },
                ),

                const SizedBox(height: 16),

                _input(controller: imagenCtrl, label: 'Imagen (asset)'),

                const SizedBox(height: 20),

                _card(
                  child: SwitchListTile(
                    title: const Text(
                      'Usuario activo',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    value: activo,
                    activeColor: appOrange,
                    onChanged: (value) => setState(() => activo = value),
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () => _guardar(popAfterSave: true),
                    child: Text(
                      isEdit ? 'GUARDAR CAMBIOS' : 'GUARDAR USUARIO',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
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

  Widget _input({
    required TextEditingController controller,
    required String label,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: child,
    );
  }
}