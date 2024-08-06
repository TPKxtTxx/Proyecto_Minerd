class Director {
  final String cedula;
  final String nombre;
  final String apellido;
  final String fechaNacimiento;
  final String direccion;
  final String telefono;
  final String photoUrl;

  Director({
    required this.cedula,
    required this.nombre,
    required this.apellido,
    required this.fechaNacimiento,
    required this.direccion,
    required this.telefono,
    required this.photoUrl,
  });

  factory Director.fromJson(Map<String, dynamic> json) {
    return Director(
      cedula: json['cedula'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      fechaNacimiento: json['fechaNacimiento'],
      direccion: json['direccion'],
      telefono: json['telefono'],
      photoUrl: json['photoUrl'],
    );
  }
}
