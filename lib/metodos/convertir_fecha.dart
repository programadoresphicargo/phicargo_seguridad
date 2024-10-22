import 'package:intl/intl.dart';

String formatFecha(String? fecha) {
  if (fecha == null || fecha.isEmpty) {
    return 'N/A'; // Retorna 'N/A' si la fecha es nula o está vacía
  }

  try {
    // Asume que la fecha está en formato ISO 8601 "YYYY-MM-DDTHH:MM:SS"
    DateTime dateTime = DateTime.parse(fecha);
    // Formato deseado "YYYY/MM/DD h:mm a"
    return DateFormat('yyyy/MM/dd h:mm a').format(dateTime);
  } catch (e) {
    // Manejo de error si el formato de fecha es incorrecto
    return 'Fecha inválida';
  }
}

String formatDateTime(dynamic dateTime) {
  try {
    // Comprobar si el valor es nulo o vacío
    if (dateTime == null || dateTime.toString().isEmpty) {
      return "Fecha no disponible";
    }

    // Intentar convertir el valor a DateTime
    DateTime parsedDate = DateTime.parse(dateTime.toString());

    // Restar 6 horas
    DateTime adjustedDate = parsedDate.subtract(Duration(hours: 6));

    // Formatear la fecha al formato 'yyyy/MM/dd hh:mm a'
    DateFormat formatter = DateFormat('yyyy/MM/dd hh:mm a');
    return formatter.format(adjustedDate);
  } catch (e) {
    // Si hay algún error de conversión, manejar el error
    return "Fecha inválida";
  }
}
