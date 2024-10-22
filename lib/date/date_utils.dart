DateTime quitarSegundos(String fechaConSegundos) {
  // Convertir la cadena a un objeto DateTime
  DateTime fechaOriginal = DateTime.parse(fechaConSegundos);

  // Crear un nuevo objeto DateTime sin los segundos
  DateTime fechaSinSegundos = DateTime(
    fechaOriginal.year,
    fechaOriginal.month,
    fechaOriginal.day,
    fechaOriginal.hour,
    fechaOriginal.minute,
  );

  return fechaSinSegundos;
}
