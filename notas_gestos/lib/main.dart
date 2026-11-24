import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'detector_agitado.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notas con gestos',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const PantallaNotas(),
    );
  }
}

class PantallaNotas extends StatefulWidget {
  const PantallaNotas({super.key});

  @override
  State<PantallaNotas> createState() => _PantallaNotasState();
}

class _PantallaNotasState extends State<PantallaNotas> {
  final List<String> _notas = [];
  final TextEditingController _controlador = TextEditingController();
  final DetectorAgitado _detector = DetectorAgitado();

  // Última nota borrada y su posición
  String? _notaBorrada;
  int? _posicionBorrada;

  bool _agitarActivo = true;
  StreamSubscription<UserAccelerometerEvent>? _suscripcion;

  @override
  void initState() {
    super.initState();
    _escucharSensor();
  }

  void _escucharSensor() {
    _suscripcion?.cancel();
    _suscripcion = userAccelerometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen(
      (evento) {
        final agitado = _detector.procesar(
          evento.x,
          evento.y,
          evento.z,
          DateTime.now(),
        );
        if (agitado && _notaBorrada != null) {
          _restaurar('Nota recuperada al agitar');
        }
      },
      onError: (_) {
        _suscripcion?.cancel();
        _suscripcion = null;
        if (!mounted) return;
        setState(() => _agitarActivo = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Este dispositivo no tiene acelerómetro')),
        );
      },
      cancelOnError: true,
    );
  }

  void _cambiarAgitar(bool valor) {
    setState(() => _agitarActivo = valor);
    if (valor) {
      _escucharSensor();
    } else {
      _suscripcion?.cancel();
      _suscripcion = null;
    }
  }

  void _anadir() {
    final texto = _controlador.text.trim();
    if (texto.isEmpty) return;
    setState(() => _notas.add(texto));
    _controlador.clear();
  }

  void _borrar(int indice) {
    setState(() {
      _notaBorrada = _notas.removeAt(indice);
      _posicionBorrada = indice;
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Nota borrada'),
          action: SnackBarAction(
            label: 'Deshacer',
            onPressed: () => _restaurar(null),
          ),
        ),
      );
  }

  void _restaurar(String? mensaje) {
    final nota = _notaBorrada;
    final posicion = _posicionBorrada;
    if (nota == null || posicion == null) return;
    setState(() {
      _notas.insert(posicion.clamp(0, _notas.length), nota);
      _notaBorrada = null;
      _posicionBorrada = null;
    });
    if (mensaje != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(mensaje)));
    }
  }

  @override
  void dispose() {
    _suscripcion?.cancel();
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas'),
        actions: [
          Tooltip(
            message: _agitarActivo
                ? 'Agitar para deshacer: activado'
                : 'Agitar para deshacer: desactivado',
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(_agitarActivo ? Icons.vibration : Icons.mobile_off),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('Agitar para deshacer'),
            value: _agitarActivo,
            onChanged: _cambiarAgitar,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controlador,
                    decoration: const InputDecoration(labelText: 'Nueva nota'),
                    onSubmitted: (_) => _anadir(),
                  ),
                ),
                IconButton(
                  tooltip: 'Añadir nota',
                  icon: const Icon(Icons.add),
                  onPressed: _anadir,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _notas.length,
              itemBuilder: (context, i) {
                final nota = _notas[i];
                return Dismissible(
                  key: ValueKey('$nota-$i'),
                  onDismissed: (_) => _borrar(i),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    title: Text(nota),
                    trailing: IconButton(
                      tooltip: 'Borrar nota',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _borrar(i),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}