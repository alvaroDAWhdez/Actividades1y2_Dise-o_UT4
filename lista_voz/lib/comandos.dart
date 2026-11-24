enum Comando { anadir, borrar, leer, ayuda, desconocido }

String _normalizar(String texto) {
  var t = texto.toLowerCase();
  const origen = 'áàäâéèëêíìïîóòöôúùüûñ';
  const destino = 'aaaaeeeeiiiioooouuuun';
  for (var i = 0; i < origen.length; i++) {
    t = t.replaceAll(origen[i], destino[i]);
  }
  return t;
}

Comando interpretarComando(String texto) {
  final palabras = _normalizar(texto)
      .split(RegExp(r'[^a-z0-9]+'))
      .where((p) => p.isNotEmpty)
      .toList();

  const sinonimos = <Comando, List<String>>{
    Comando.anadir: ['anadir', 'anade', 'nuevo', 'crear'],
    Comando.borrar: ['borrar', 'borra', 'eliminar', 'quitar'],
    Comando.leer: ['leer', 'lee', 'cuantos', 'lista'],
    Comando.ayuda: ['ayuda', 'comandos'],
  };

  for (final palabra in palabras) {
    for (final entrada in sinonimos.entries) {
      if (entrada.value.contains(palabra)) return entrada.key;
    }
  }
  return Comando.desconocido;
}