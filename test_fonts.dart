import 'package:google_fonts/google_fonts.dart';

void main() {
  final fonts = GoogleFonts.asMap().keys.toList();
  final vend = fonts.where((f) => f.toLowerCase().contains('vend')).toList();
  final sans = fonts.where((f) => f.toLowerCase().contains('sansation')).toList();
  print('Vend matches: $vend');
  print('Sansation matches: $sans');
}
