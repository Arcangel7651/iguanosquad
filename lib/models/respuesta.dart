class Respuesta {
  final int idRespuesta;
  final String respuesta;
  final int? idPregunta;
  final String idUsuario;

  Respuesta({
    required this.idRespuesta,
    required this.respuesta,
    required this.idUsuario,
    this.idPregunta,
  });

  factory Respuesta.fromJson(Map<String, dynamic> json) {
    return Respuesta(
      idRespuesta: json['id_respuesta'],
      respuesta: json['respuesta'],
      idPregunta: json['id_pregunta'],
      idUsuario: json['id_usuario'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_respuesta': idRespuesta,
      'respuesta': respuesta,
      'id_pregunta': idPregunta,
      'id_usuario': idUsuario,
    };
  }
}
