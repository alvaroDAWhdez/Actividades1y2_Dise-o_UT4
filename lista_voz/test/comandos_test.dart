import 'package:flutter_test/flutter_test.dart';
import 'package:lista_voz/comandos.dart';

void main() {
  test('reconoce añadir con tilde', () {
    expect(interpretarComando('Añade'), Comando.anadir);
  });

  test('no distingue mayúsculas ni tildes', () {
    expect(interpretarComando('anade'), Comando.anadir);
    expect(interpretarComando('AÑADIR'), Comando.anadir);
  });

  test('reconoce la orden dentro de una frase', () {
    expect(interpretarComando('por favor añade uno'), Comando.anadir);
  });

  test('sinónimos de borrar', () {
    expect(interpretarComando('quitar'), Comando.borrar);
    expect(interpretarComando('Elimina'), Comando.desconocido); // no es sinónimo
    expect(interpretarComando('eliminar'), Comando.borrar);
  });

  test('leer y cuántos', () {
    expect(interpretarComando('lee'), Comando.leer);
    expect(interpretarComando('¿Cuántos hay?'), Comando.leer);
  });

  test('ayuda y comandos', () {
    expect(interpretarComando('comandos'), Comando.ayuda);
    expect(interpretarComando('AYUDA'), Comando.ayuda);
  });

  test('texto desconocido o vacío', () {
    expect(interpretarComando('hola'), Comando.desconocido);
    expect(interpretarComando(''), Comando.desconocido);
  });
}