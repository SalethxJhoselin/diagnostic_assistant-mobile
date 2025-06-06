import 'package:flutter/material.dart';

class EnfermedadesService {
  // Simulación de las enfermedades de la piel, descripciones y recomendaciones
  static List<Map<String, String>> obtenerEnfermedades() {
    return [
      {
        'nombre': 'Acné',
        'descripcion':
            'El acné es una afección de la piel que ocurre cuando los folículos pilosos se obstruyen con aceite y células muertas de la piel.',
        'recomendaciones':
            'Se recomienda mantener la piel limpia, evitar tocarse la cara, usar productos no comedogénicos y, en casos severos, consultar a un dermatólogo.',
      },
      {
        'nombre': 'Eczema',
        'descripcion':
            'El eczema es una condición que hace que la piel se inflame, se enrojecida, irritada y con picazón.',
        'recomendaciones':
            'Se recomienda usar cremas hidratantes, evitar el contacto con alérgenos y usar cremas recetadas para reducir la inflamación.',
      },
      {
        'nombre': 'Psoriasis',
        'descripcion':
            'La psoriasis es una enfermedad autoinmune que acelera el ciclo de crecimiento celular, causando manchas gruesas y escamosas en la piel.',
        'recomendaciones':
            'Es importante evitar el estrés, usar cremas hidratantes y medicamentos tópicos que ayuden a controlar los brotes.',
      },
      {
        'nombre': 'Rosácea',
        'descripcion':
            'La rosácea es una afección cutánea que provoca enrojecimiento y visibilidad de vasos sanguíneos en el rostro, especialmente en las mejillas y la nariz.',
        'recomendaciones':
            'Evitar el alcohol, el sol directo y el uso de productos irritantes. Usar bloqueador solar y consultar al dermatólogo para el tratamiento adecuado.',
      },
    ];
  }
}
