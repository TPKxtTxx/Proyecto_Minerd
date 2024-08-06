class Incidencia {
  final String titulo;
  final String centroEducativo;
  final String regional;
  final String distrito;
  final DateTime fecha;
  final String descripcion;
  final String fotoPath;
  final String audioPath;

  Incidencia({
    required this.titulo,
    required this.centroEducativo,
    required this.regional,
    required this.distrito,
    required this.fecha,
    required this.descripcion,
    required this.fotoPath,
    required this.audioPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'centroEducativo': centroEducativo,
      'regional': regional,
      'distrito': distrito,
      'fecha': fecha.toIso8601String(),
      'descripcion': descripcion,
      'fotoPath': fotoPath,
      'audioPath': audioPath,
    };
  }

  static Incidencia fromMap(Map<String, dynamic> map) {
    return Incidencia(
      titulo: map['titulo'],
      centroEducativo: map['centroEducativo'],
      regional: map['regional'],
      distrito: map['distrito'],
      fecha: DateTime.parse(map['fecha']),
      descripcion: map['descripcion'],
      fotoPath: map['fotoPath'],
      audioPath: map['audioPath'],
    );
  }
}
