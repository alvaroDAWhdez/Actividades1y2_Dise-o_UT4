import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'comandos.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista por voz',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const PantallaLista(),
    );
  }
}

class PantallaLista extends StatefulWidget {
  const PantallaLista({super.key});

  @override
  State<PantallaLista> createState() => _PantallaListaState();
}

class _PantallaListaState extends State<PantallaLista> {
  final SpeechToText _stt = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  final List<String> _elementos = [];
  bool _vozDisponible = false;
  bool _escuchando = false;
  String _transcripcion = '';
  String _ultimaOrden = '';

  @override
  void initState() {
    super.initState();
    _iniciarVoz();
  }

  Future<void> _iniciarVoz() async {
    bool ok = false;
    try {
      ok = await _stt.initialize(
        onStatus: (estado) {
          if (estado == 'done' || estado == 'notListening') {
            if (mounted) setState(() => _escuchando = false);
          }
        },
        onError: (error) {
          if (mounted) setState(() => _escuchando = false);
        },
      );
      await _tts.setLanguage('es-ES');
    } catch (_) {
      ok = false;
    }
    if (mounted) setState(() => _vozDisponible = ok);
  }

  Future<void> _hablar(String texto) async {
    await _tts.speak(texto);
  }

  Future<void> _escuchar() async {
    if (!_vozDisponible) return;
    setState(() {
      _escuchando = true;
      _transcripcion = '';
    });
    await _stt.listen(
      localeId: 'es_ES',
      listenFor: const Duration(seconds: 5),
      onResult: (resultado) {
        setState(() => _transcripcion = resultado.recognizedWords);
        if (resultado.finalResult) {
          setState(() => _escuchando = false);
          _ejecutarTexto(resultado.recognizedWords);
        }
      },
    );
  }

  Future<void> _detener() async {
    await _stt.stop();
    if (mounted) setState(() => _escuchando = false);
  }

  void _ejecutarTexto(String texto) {
    final comando = interpretarComando(texto);
    setState(() => _ultimaOrden = comando.name);
    switch (comando) {
      case Comando.anadir:
        _anadir();
      case Comando.borrar:
        _borrar();
      case Comando.leer:
        _leer();
      case Comando.ayuda:
        _ayuda();
      case Comando.desconocido:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No he entendido «$texto». Di «ayuda» para oír las órdenes',
            ),
          ),
        );
    }
  }

  void _anadir() {
    setState(() => _elementos.add('Elemento ${_elementos.length + 1}'));
    _hablar('Añadido el elemento ${_elementos.length}');
  }

  void _borrar() {
    if (_elementos.isEmpty) {
      _hablar('La lista está vacía');
      return;
    }
    final numero = _elementos.length;
    setState(() => _elementos.removeLast());
    _hablar('Borrado el elemento $numero');
  }

  void _leer() {
    final n = _elementos.length;
    _hablar(n == 1 ? 'Hay 1 elemento' : 'Hay $n elementos');
  }

  void _ayuda() {
    _hablar(
      'Puedes decir: añadir, borrar, leer o ayuda. '
      'Añadir crea un elemento, borrar quita el último, '
      'leer dice cuántos hay y ayuda repite estas órdenes.',
    );
  }

  @override
  void dispose() {
    _stt.stop();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista controlada por voz')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton.filled(
                  tooltip: _vozDisponible
                      ? (_escuchando ? 'Dejar de escuchar' : 'Hablar')
                      : 'Micrófono no disponible',
                  style: IconButton.styleFrom(
                    backgroundColor: _escuchando ? Colors.red : null,
                  ),
                  icon: Icon(_escuchando ? Icons.mic : Icons.mic_none),
                  onPressed: !_vozDisponible
                      ? null
                      : (_escuchando ? _detener : _escuchar),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _vozDisponible
                        ? (_escuchando ? 'Escuchando…' : 'Pulsa el micrófono')
                        : 'Micrófono deshabilitado: falta el permiso o no hay '
                            'servicio de reconocimiento de voz. Usa los botones.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Transcripción: $_transcripcion'),
            Text('Última orden: $_ultimaOrden'),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: _anadir,
                  icon: const Icon(Icons.add),
                  label: const Text('Añadir'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _borrar,
                  icon: const Icon(Icons.delete),
                  label: const Text('Borrar'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _leer,
                  icon: const Icon(Icons.volume_up),
                  label: const Text('Leer'),
                ),
              ],
            ),
            const Divider(height: 32),
            Expanded(
              child: ListView.builder(
                itemCount: _elementos.length,
                itemBuilder: (context, i) => ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(_elementos[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}