import 'package:flutter_test/flutter_test.dart';
import 'package:notas_gestos/detector_agitado.dart';

void main() {
  final t0 = DateTime(2026, 1, 1, 12, 0, 0);

  test('en reposo no detecta sacudida', () {
    final d = DetectorAgitado();
    expect(d.procesar(0.1, 0.2, 0.1, t0), isFalse);
  });

  test('una sacudida fuerte se detecta', () {
    final d = DetectorAgitado();
    expect(d.procesar(10, 10, 10, t0), isTrue); // módulo ≈ 17,3
  });

  test('segunda sacudida dentro de la pausa se ignora', () {
    final d = DetectorAgitado();
    expect(d.procesar(10, 10, 10, t0), isTrue);
    expect(
      d.procesar(10, 10, 10, t0.add(const Duration(milliseconds: 500))),
      isFalse,
    );
  });

  test('sacudida pasada la pausa se detecta', () {
    final d = DetectorAgitado();
    expect(d.procesar(10, 10, 10, t0), isTrue);
    expect(
      d.procesar(10, 10, 10, t0.add(const Duration(milliseconds: 1500))),
      isTrue,
    );
  });
}