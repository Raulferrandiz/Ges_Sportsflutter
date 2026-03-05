import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:login/models/pista.dart';
import 'package:login/providers/pista_provider.dart';

enum _BackAction { cancel, discard, save }

class PistaFormScreen extends StatefulWidget {
  const PistaFormScreen({super.key, this.pistaToEdit});

  final Pista? pistaToEdit;

  @override
  State<PistaFormScreen> createState() => _PistaFormScreenState();
}

class _PistaFormScreenState extends State<PistaFormScreen> {
  static const Color appOrange = Color(0xFFF59E0B);

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nombreCtrl;
  late final TextEditingController direccionCtrl;
  late final TextEditingController tipoCtrl;

  late bool activa;

  late final String _initialNombre;
  late final String _initialDireccion;
  late final String _initialTipo;
  late final bool _initialActiva;

  bool get isEdit => widget.pistaToEdit != null;

  @override
  void initState() {
    super.initState();

    nombreCtrl = TextEditingController(text: widget.pistaToEdit?.nombre ?? '');
    direccionCtrl = TextEditingController(text: widget.pistaToEdit?.direccion ?? '');
    tipoCtrl = TextEditingController(text: widget.pistaToEdit?.tipo ?? '');

    activa = widget.pistaToEdit?.activa ?? true;

    _initialNombre = nombreCtrl.text;
    _initialDireccion = direccionCtrl.text;
    _initialTipo = tipoCtrl.text;
    _initialActiva = activa;
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    direccionCtrl.dispose();
    tipoCtrl.dispose();
    super.dispose();
  }

  bool get _hasUnsavedChanges {
    return nombreCtrl.text != _initialNombre ||
        direccionCtrl.text != _initialDireccion ||
        tipoCtrl.text != _initialTipo ||
        activa != _initialActiva;
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

    final provider = context.read<PistaProvider>();

    final nombre = nombreCtrl.text.trim();
    final direccion = direccionCtrl.text.trim();
    final tipo = tipoCtrl.text.trim().toLowerCase(); 
    if (isEdit) {
      final updated = widget.pistaToEdit!.copyWith(
        nombre: nombre,
        direccion: direccion,
        tipo: tipo,
        activa: activa,
      );
      await provider.update(updated.id, updated);
    } else {
      final newPista = Pista(
        id: '',
        activa: activa,
        direccion: direccion,
        nombre: nombre,
        tipo: tipo,
      );
      await provider.add(newPista);
    }

    if (popAfterSave && mounted) Navigator.pop(context);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final titleText = isEdit ? 'Editar pista' : 'Nueva pista';

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: appOrange),
                onPressed: _handleBack,
                tooltip: 'Volver',
              ),
              Image.asset(
                'assets/images/gesports.png',
                width: 28,
                height: 28,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  titleText,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: appOrange,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _input(
                  controller: nombreCtrl,
                  label: 'Nombre',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Introduce un nombre' : null,
                ),
                const SizedBox(height: 16),
                _input(
                  controller: direccionCtrl,
                  label: 'Dirección / Identificador',
                ),
                const SizedBox(height: 16),
                _input(
                  controller: tipoCtrl,
                  label: 'Tipo (deporte)',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Introduce un tipo (ej: padel)' : null,
                ),
                const SizedBox(height: 20),
                _card(
                  child: SwitchListTile(
                    title: const Text('Pista activa', style: TextStyle(fontWeight: FontWeight.w600)),
                    value: activa,
                    activeColor: appOrange,
                    onChanged: (v) => setState(() => activa = v),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appOrange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () => _guardar(popAfterSave: true),
                    child: Text(
                      isEdit ? 'GUARDAR CAMBIOS' : 'GUARDAR PISTA',
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
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
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