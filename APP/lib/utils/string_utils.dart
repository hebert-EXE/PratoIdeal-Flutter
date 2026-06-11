/// Normaliza texto para comparação: minúsculas + remoção de acentos.
/// Equivalente ao `normalize` do web (`src/lib/utils.ts`).
String normalize(String input) {
  const withAccents = 'àáâãäçèéêëìíîïñòóôõöùúûüýÿ';
  const without = 'aaaaaceeeeiiiinooooouuuuyy';

  final lower = input.toLowerCase().trim();
  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final ch = String.fromCharCode(rune);
    final idx = withAccents.indexOf(ch);
    buffer.write(idx >= 0 ? without[idx] : ch);
  }
  return buffer.toString();
}
