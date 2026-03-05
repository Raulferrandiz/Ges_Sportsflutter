import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:login/models/incidencia.dart';
import 'package:login/providers/incidencia_provider.dart';

class IncidenciaFormScreen extends StatefulWidget {
  const IncidenciaFormScreen({super.key, this.incidenciaToEdit});

  final Incidencia? incidenciaToEdit;

  @override
  State<IncidenciaFormScreen> createState() => _IncidenciaFormScreenState();
}

class _IncidenciaFormScreenState extends State<IncidenciaFormScreen> {
  static const Color appOrange = Color(0xFFF59E0B);

  final _formKey = GlobalKey<FormState>();
  final _mensajeCtrl = TextEditingController();

  late DateTime _fecha;
  String _tipo = 'cancelacion';

  bool _saving = false;

  bool get isEdit => widget.incidenciaToEdit != null;

  @override
  void initState() {
    super.initState();
    final i = widget.incidenciaToEdit;
    if (i == null) {
      _fecha = DateTime.now();
      _tipo = 'cancelacion';
      _mensajeCtrl.text = '';
    } else {
      _fecha = i.fecha;
      _tipo = (i.tipo.trim().isEmpty) ? 'cancelacion' : i.tipo.trim();
      _mensajeCtrl.text = i.mensaje;
    }
  }

  @override
  void dispose() {
    _mensajeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_fecha),
    );
    if (pickedTime == null) return;

    setState(() {
      _fecha = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (!isEdit && (uid == null || uid.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay sesión activa.')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final provider = context.read<IncidenciaProvider>();

      if (isEdit) {
        final updated = widget.incidenciaToEdit!.copyWith(
          fecha: _fecha,
          tipo: _tipo.trim().toLowerCase(),
          mensaje: _mensajeCtrl.text.trim(),
        );
        await provider.update(updated.id, updated);
      } else {
        final nueva = Incidencia(
          id: '',
          creadorID: uid!,
          fecha: _fecha,
          mensaje: _mensajeCtrl.text.trim(),
          tipo: _tipo.trim().toLowerCase(),
        );
        await provider.add(nueva);
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEdit ? 'Incidencia actualizada' : 'Incidencia creada')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error guardando: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = isEdit ? 'Editar incidencia' : 'Nueva incidencia';
    final fechaStr = DateFormat('dd/MM/yyyy HH:mm').format(_fecha);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: appOrange),
              onPressed: _saving ? null : () => Navigator.of(context).pop(),
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
                title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800, color: appOrange),
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
              _card(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Fecha: $fechaStr',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _saving ? null : _pickDateTime,
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: const Text('Cambiar'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _tipo,
                decoration: _decoration('Tipo'),
                items: const [
                  DropdownMenuItem(value: 'cancelacion', child: Text('cancelacion')),
                  DropdownMenuItem(value: 'mantenimiento', child: Text('mantenimiento')),
                  DropdownMenuItem(value: 'ausencia', child: Text('ausencia')),
                  DropdownMenuItem(value: 'otro', child: Text('otro')),
                ],
                onChanged: _saving ? null : (v) => setState(() => _tipo = v ?? 'cancelacion'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mensajeCtrl,
                enabled: !_saving,
                maxLines: 5,
                validator: (v) {
                  final value = (v ?? '').trim();
                  if (value.isEmpty) return 'Escribe un mensaje';
                  return null;
                },
                decoration: _decoration('Mensaje').copyWith(alignLabelWithHint: true),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appOrange,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: _saving ? null : _save,
                  child: Text(
                    _saving ? 'GUARDANDO...' : (isEdit ? 'GUARDAR CAMBIOS' : 'CREAR INCIDENCIA'),
                    style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
      child: child,
    );
  }
}