import 'dart:math';

class DetectorAgitado {
  DetectorAgitado({
    this.umbral = 15,
    this.pausa = const Duration(seconds: 1),
  });

  final double umbral;
  final Duration pausa;
  DateTime? _ultimaSacudida;

  bool procesar(double x, double y, double z, DateTime instante) {
    final ultima = _ultimaSacudida;
    if (ultima != null && instante.difference(ultima) < pausa) {
      return false;
    }
    final modulo = sqrt(x * x + y * y + z * z);
    if (modulo > umbral) {
      _ultimaSacudida = instante;
      return true;
    }
    return false;
  }
}