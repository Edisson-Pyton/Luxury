import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_service.dart';

// ── Modelo ────────────────────────────────────────────────────
class Exercise {
  final String name;
  final String imageUrl;
  final int totalSeries;
  final int restSeconds;
  final String muscles;
  final List<String> howTo;
  final List<String> benefits;
  final String tip;

  const Exercise({
    required this.name,
    required this.totalSeries,
    required this.restSeconds,
    required this.muscles,
    required this.howTo,
    required this.benefits,
    required this.tip,
    this.imageUrl = '',
  });

  String get setsLabel => '$totalSeries series';
  String get restLabel =>
      restSeconds == 0 ? 'Sin descanso' : 'Descanso: $restSeconds seg';
}

// ── Rutinas ───────────────────────────────────────────────────
const Map<String, List<Exercise>> _routinesByGoal = {
  'Perder peso': [
    Exercise(
      name: 'Saltos de tijera',
      totalSeries: 3,
      restSeconds: 30,
      muscles: 'Piernas, glúteos, hombros, cardio',
      imageUrl:
          'https://static.nike.com/a/images/f_auto,cs_srgb/w_1920,c_limit/c4c25466-266e-44e6-9c67-03a5306a183f/cinco-beneficios-que-no-te-esperabas-de-los-saltos-de-tijera.jpg',
      howTo: [
        'Párate con los pies juntos y los brazos a los lados.',
        'Salta abriendo piernas al ancho de los hombros mientras subes los brazos.',
        'Vuelve a la posición inicial saltando de nuevo.',
        'Aterriza suave con las rodillas levemente flexionadas.',
        'Mantén el ritmo constante durante toda la serie.',
      ],
      benefits: [
        'Quema calorías rápidamente.',
        'Mejora la coordinación y el equilibrio.',
        'Activa todo el cuerpo en un solo movimiento.',
        'No requiere equipamiento ni espacio grande.',
      ],
      tip: 'Respira de forma constante, no aguantes el aire.',
    ),
    Exercise(
      name: 'Sentadillas',
      totalSeries: 4,
      restSeconds: 45,
      muscles: 'Cuádriceps, glúteos, isquiotibiales, core',
      imageUrl:
          'https://image.tuasaude.com/media/article/3k/ru/6-exercicios-de-agachamento-para-gluteos_9131.jpg',
      howTo: [
        'Párate con los pies al ancho de los hombros.',
        'Mantén la espalda recta y el pecho hacia arriba.',
        'Baja como si fueras a sentarte en una silla.',
        'Las rodillas no deben pasar la punta de los pies.',
        'Sube empujando desde los talones.',
      ],
      benefits: [
        'Fortalece los músculos más grandes del cuerpo.',
        'Activa el metabolismo y quema grasa.',
        'Mejora la postura y la estabilidad.',
        'Funcional para actividades del día a día.',
      ],
      tip: 'Mantén los talones apoyados en el suelo todo el tiempo.',
    ),
    Exercise(
      name: 'Burpees',
      totalSeries: 3,
      restSeconds: 60,
      muscles: 'Cuerpo completo: pecho, core, piernas, cardio',
      imageUrl:
          'https://www.shutterstock.com/image-photo/movement-sequence-latin-sporty-woman-600nw-2204166209.jpg',
      howTo: [
        'Párate derecho con los pies juntos.',
        'Baja las manos al suelo y lleva los pies atrás en posición de plancha.',
        'Haz una flexión (opcional para principiantes).',
        'Lleva los pies hacia las manos de un salto.',
        'Salta hacia arriba con los brazos extendidos.',
      ],
      benefits: [
        'Es uno de los ejercicios más completos que existen.',
        'Quema muchas calorías en poco tiempo.',
        'Mejora la fuerza y la resistencia simultáneamente.',
        'Acelera el metabolismo incluso después de entrenar.',
      ],
      tip: 'Empieza lento y ve aumentando el ritmo con las series.',
    ),
    Exercise(
      name: 'Escaladores',
      totalSeries: 3,
      restSeconds: 30,
      muscles: 'Core, hombros, caderas, cardio',
      imageUrl:
          'https://images.unsplash.com/photo-1635031520206-2bbe2dfa4d68?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      howTo: [
        'Colócate en posición de plancha alta con los brazos extendidos.',
        'Mantén las caderas bajas, alineadas con el cuerpo.',
        'Lleva una rodilla al pecho rápidamente.',
        'Vuelve y alterna con la otra pierna.',
        'Mantén el core activado durante todo el movimiento.',
      ],
      benefits: [
        'Trabaja el abdomen de forma intensa.',
        'Mejora la coordinación y velocidad.',
        'Eleva la frecuencia cardíaca rápidamente.',
        'Fortalece los hombros y la parte alta del cuerpo.',
      ],
      tip: 'Las caderas no deben subir ni bajar, mantén la plancha firme.',
    ),
    Exercise(
      name: 'Plancha abdominal',
      totalSeries: 3,
      restSeconds: 30,
      muscles: 'Core completo, hombros, glúteos',
      imageUrl:
          'https://images.unsplash.com/photo-1566241142559-40e1dab266c6?w=800&q=80',
      howTo: [
        'Apoya los antebrazos y las puntas de los pies en el suelo.',
        'El cuerpo debe formar una línea recta de cabeza a talones.',
        'Activa el abdomen como si fueras a recibir un golpe.',
        'Mira hacia el suelo para mantener el cuello neutro.',
        'Mantén la posición el tiempo indicado sin perder la forma.',
      ],
      benefits: [
        'Fortalece el core de forma isométrica y segura.',
        'Mejora la postura y reduce el dolor de espalda.',
        'Estabiliza la columna vertebral.',
        'Activa múltiples grupos musculares al mismo tiempo.',
      ],
      tip: 'Respira de forma continua, no aguantes el aire.',
    ),
  ],

  'Ganar músculo': [
    Exercise(
      name: 'Flexiones de pecho',
      totalSeries: 4,
      restSeconds: 60,
      muscles: 'Pectoral, tríceps, hombros anteriores',
      imageUrl:
          'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?w=800&q=80',
      howTo: [
        'Colócate boca abajo con las manos al ancho de los hombros.',
        'El cuerpo debe estar recto de cabeza a talones.',
        'Baja el pecho hasta casi tocar el suelo.',
        'Mantén los codos a 45 grados del cuerpo.',
        'Empuja hacia arriba hasta extender los brazos.',
      ],
      benefits: [
        'Desarrolla el pectoral sin necesidad de pesas.',
        'Fortalece tríceps y hombros simultáneamente.',
        'Mejora la estabilidad del core.',
        'Ejercicio funcional que imita movimientos reales.',
      ],
      tip: 'No dejes caer las caderas ni subas los glúteos.',
    ),
    Exercise(
      name: 'Sentadilla profunda',
      totalSeries: 4,
      restSeconds: 90,
      muscles: 'Cuádriceps, glúteos, isquiotibiales, pantorrillas',
      imageUrl:
          'https://www.trakphysio.com/wp-content/uploads/sites/612/2023/05/15-14.jpg',
      howTo: [
        'Pies ligeramente más anchos que los hombros, puntillas hacia afuera.',
        'Baja lentamente hasta que los muslos queden paralelos o más abajo.',
        'Mantén el pecho arriba y la espalda recta.',
        'Empuja desde los talones para subir.',
        'Extiende completamente las rodillas al llegar arriba.',
      ],
      benefits: [
        'Activa más fibras musculares que la sentadilla normal.',
        'Desarrolla glúteos y cuádriceps intensamente.',
        'Mejora la movilidad de cadera y tobillos.',
        'Base de casi todos los movimientos funcionales.',
      ],
      tip: 'Si los talones se levantan, trabaja la movilidad de tobillo.',
    ),
    Exercise(
      name: 'Zancadas alternas',
      totalSeries: 3,
      restSeconds: 60,
      muscles: 'Cuádriceps, glúteos, isquiotibiales, equilibrio',
      imageUrl:
          'https://hips.hearstapps.com/hmg-prod/images/alternate-lunges-1586168385.jpg?resize=980:*',
      howTo: [
        'Párate derecho con los pies juntos.',
        'Da un paso largo hacia adelante con una pierna.',
        'Baja la rodilla trasera casi hasta tocar el suelo.',
        'El torso debe mantenerse erguido durante todo el movimiento.',
        'Empuja con el pie delantero y alterna la pierna.',
      ],
      benefits: [
        'Trabaja cada pierna de forma independiente.',
        'Mejora el equilibrio y la coordinación.',
        'Corrige desbalances musculares entre piernas.',
        'Activa los glúteos en todo el rango de movimiento.',
      ],
      tip: 'La rodilla delantera no debe pasar la punta del pie.',
    ),
    Exercise(
      name: 'Flexiones diamante',
      totalSeries: 3,
      restSeconds: 75,
      muscles: 'Tríceps, pectoral interno, hombros',
      imageUrl: 'https://i.ytimg.com/vi/jaxbEHLC4qU/maxresdefault.jpg',
      howTo: [
        'Colócate en posición de flexión estándar.',
        'Junta las manos bajo el pecho formando un diamante con los dedos.',
        'Baja el pecho hacia las manos controladamente.',
        'Mantén los codos pegados al cuerpo al bajar.',
        'Empuja hasta extender los brazos completamente.',
      ],
      benefits: [
        'Aísla el tríceps mejor que cualquier flexión normal.',
        'Desarrolla la parte interna del pectoral.',
        'Mejora la definición de los brazos.',
        'No necesita equipamiento.',
      ],
      tip: 'Es más difícil que la flexión normal, empieza despacio.',
    ),
    Exercise(
      name: 'Fondos de tríceps en silla',
      totalSeries: 3,
      restSeconds: 60,
      muscles: 'Tríceps, hombros, pectoral inferior',
      imageUrl:
          'https://hips.hearstapps.com/hmg-prod/images/cajo-n-1621951089.jpeg',
      howTo: [
        'Siéntate en el borde de una silla o superficie estable.',
        'Pon las manos en el borde con los dedos hacia adelante.',
        'Desliza el cuerpo fuera de la silla y baja doblando los codos.',
        'Baja hasta que los codos formen 90 grados.',
        'Empuja hacia arriba hasta extender los brazos.',
      ],
      benefits: [
        'Trabaja el tríceps de forma efectiva sin pesas.',
        'Fácil de hacer en casa con cualquier silla.',
        'Mejora la fuerza de empuje de los brazos.',
        'Complementa perfectamente las flexiones.',
      ],
      tip: 'Codos hacia atrás, no hacia los lados.',
    ),
  ],

  'Mejorar resistencia': [
    Exercise(
      name: 'Trote en el lugar',
      totalSeries: 5,
      restSeconds: 20,
      muscles: 'Piernas, cardio, coordinación',
      imageUrl:
          'https://images.unsplash.com/photo-1571008887538-b36bb32f4571?w=800&q=80',
      howTo: [
        'Párate con los pies juntos.',
        'Empieza a trotar levantando las rodillas al menos a la cadera.',
        'Mueve los brazos de forma natural como al correr.',
        'Mantén el torso ligeramente inclinado hacia adelante.',
        'Aterriza suavemente en la punta de los pies.',
      ],
      benefits: [
        'Mejora la resistencia cardiovascular.',
        'Se puede hacer en cualquier espacio pequeño.',
        'Calienta todo el cuerpo rápidamente.',
        'Fortalece los músculos de las piernas.',
      ],
      tip: 'Mantén un ritmo constante durante el minuto completo.',
    ),
    Exercise(
      name: 'Sentadillas + salto',
      totalSeries: 4,
      restSeconds: 45,
      muscles: 'Cuádriceps, glúteos, pantorrillas, cardio',
      imageUrl:
          'https://ce8216f185.cbaul-cdnwnd.com/a1ec1c4cc4ea5246346a698640e3008e/200000047-189f0189f2/salto%20pierna.jpg?ph=ce8216f185',
      howTo: [
        'Párate con los pies al ancho de los hombros.',
        'Baja en sentadilla hasta que los muslos queden paralelos.',
        'Explota hacia arriba saltando lo más alto posible.',
        'Extiende los brazos hacia arriba al saltar.',
        'Aterriza suave y baja de nuevo directamente a la sentadilla.',
      ],
      benefits: [
        'Combina fuerza y cardio en un solo movimiento.',
        'Quema muchas calorías en poco tiempo.',
        'Mejora la potencia explosiva de las piernas.',
        'Acelera el metabolismo.',
      ],
      tip:
          'Aterriza con las rodillas flexionadas para proteger las articulaciones.',
    ),
    Exercise(
      name: 'Escaladores rápidos',
      totalSeries: 4,
      restSeconds: 20,
      muscles: 'Core, hombros, caderas, cardio',
      imageUrl:
          'https://st4.depositphotos.com/4293685/19868/v/450/depositphotos_198689642-stock-illustration-healthy-woman-doing-mountain-climber.jpg',
      howTo: [
        'Posición de plancha alta con brazos extendidos.',
        'Alterna las rodillas hacia el pecho lo más rápido posible.',
        'Mantén las caderas bajas y el core activado.',
        'Respira de forma constante durante el ejercicio.',
        'No pierdas la posición de plancha por la velocidad.',
      ],
      benefits: [
        'Eleva la frecuencia cardíaca muy rápido.',
        'Trabaja el core de forma dinámica.',
        'Mejora la coordinación y velocidad.',
        'Quema grasa eficientemente.',
      ],
      tip: 'La velocidad no vale si pierdes la forma correcta.',
    ),
    Exercise(
      name: 'Flexiones + rodilla al pecho',
      totalSeries: 3,
      restSeconds: 40,
      muscles: 'Pectoral, tríceps, core, caderas',
      imageUrl:
          'https://hips.hearstapps.com/hmg-prod/images/flexiones-1585824600.jpg',
      howTo: [
        'Haz una flexión completa.',
        'Al subir, lleva la rodilla derecha hacia el pecho.',
        'Vuelve a posición de plancha.',
        'Haz otra flexión y lleva la rodilla izquierda.',
        'Alterna el movimiento de rodilla en cada repetición.',
      ],
      benefits: [
        'Combina fuerza de tren superior con movilidad de cadera.',
        'Activa el core en cada repetición.',
        'Mejora la coordinación entre tren superior e inferior.',
        'Mayor gasto calórico que una flexión normal.',
      ],
      tip: 'Controla la respiración: exhala al subir.',
    ),
    Exercise(
      name: 'Circuito sin pausa',
      totalSeries: 3,
      restSeconds: 60,
      muscles: 'Cuerpo completo',
      imageUrl:
          'https://thumbs.dreamstime.com/b/siluetas-de-personas-realizando-varios-ejercicios-y-posturas-yoga-431664678.jpg',
      howTo: [
        '10 sentadillas sin parar.',
        'Inmediatamente 10 flexiones.',
        'Inmediatamente 10 saltos de tijera.',
        'Eso cuenta como 1 ronda completa.',
        'Descansa solo entre rondas.',
      ],
      benefits: [
        'Entrena fuerza y resistencia simultáneamente.',
        'Simula el entrenamiento en circuito de gym.',
        'Maximiza el gasto calórico.',
        'Mejora la capacidad de recuperación.',
      ],
      tip: 'El reto es no parar dentro de la ronda.',
    ),
  ],

  'Reducir estrés': [
    Exercise(
      name: 'Respiración 4-7-8',
      totalSeries: 3,
      restSeconds: 30,
      muscles: 'Sistema nervioso, diafragma',
      imageUrl:
          'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800&q=80',
      howTo: [
        'Siéntate cómodamente con la espalda recta.',
        'Coloca una mano en el abdomen.',
        'Inhala por la nariz contando 4 segundos.',
        'Retén el aire contando 7 segundos.',
        'Exhala lentamente por la boca contando 8 segundos.',
      ],
      benefits: [
        'Activa el sistema nervioso parasimpático.',
        'Reduce la ansiedad en minutos.',
        'Mejora la concentración y el enfoque.',
        'Ayuda a conciliar el sueño.',
      ],
      tip: 'El abdomen debe expandirse al inhalar, no el pecho.',
    ),
    Exercise(
      name: 'Postura del niño',
      totalSeries: 3,
      restSeconds: 20,
      muscles: 'Espalda baja, caderas, hombros',
      imageUrl:
          'https://cdn0.uncomo.com/es/posts/0/5/3/balasana_o_postura_del_nino_en_yoga_beneficios_y_como_hacerla_para_relajarse_55350_1200.jpg',
      howTo: [
        'Arrodíllate en el suelo con los glúteos sobre los talones.',
        'Inclina el torso hacia adelante extendiendo los brazos.',
        'Apoya la frente en el suelo o en una almohada.',
        'Respira profundamente sintiendo el estiramiento en la espalda.',
        'Mantén la postura el tiempo indicado sin tensión.',
      ],
      benefits: [
        'Alivia la tensión en la espalda baja.',
        'Estira caderas, muslos y tobillos.',
        'Calma la mente y reduce el estrés.',
        'Ideal para hacer antes de dormir.',
      ],
      tip: 'No fuerces nada, deja que la gravedad haga el trabajo.',
    ),
    Exercise(
      name: 'Estiramiento de cuello',
      totalSeries: 3,
      restSeconds: 15,
      muscles: 'Cuello, trapecios, hombros',
      imageUrl:
          'https://content.healthwise.net/resources/14.7/es-us/media/medical/hw/aco6668_460x300.jpg',
      howTo: [
        'Siéntate o párate con la espalda recta.',
        'Inclina lentamente la cabeza hacia la derecha.',
        'Mantén 20 segundos sintiendo el estiramiento.',
        'Vuelve al centro lentamente.',
        'Repite hacia el lado izquierdo.',
      ],
      benefits: [
        'Libera la tensión acumulada por el estrés.',
        'Reduce los dolores de cabeza tensionales.',
        'Mejora la movilidad del cuello.',
        'Se puede hacer en cualquier momento del día.',
      ],
      tip: 'Nunca hagas rotaciones rápidas o forzadas de cuello.',
    ),
    Exercise(
      name: 'Caminata consciente',
      totalSeries: 1,
      restSeconds: 0,
      muscles: 'Mente, piernas, respiración',
      imageUrl:
          'https://images.unsplash.com/photo-1571008887538-b36bb32f4571?w=800&q=80',
      howTo: [
        'Sal a caminar sin teléfono o con él en el bolsillo.',
        'Observa conscientemente lo que te rodea.',
        'Siente cada paso: el suelo, el movimiento, el aire.',
        'Respira profundo al ritmo de tus pasos.',
        'Si la mente divaga, vuelve la atención al caminar.',
      ],
      benefits: [
        'Reduce el cortisol (hormona del estrés).',
        'Mejora el estado de ánimo rápidamente.',
        'Practica el mindfulness de forma natural.',
        'Activa el cuerpo sin generar más estrés.',
      ],
      tip: 'No se trata de llegar a ningún lado, solo de estar presente.',
    ),
    Exercise(
      name: 'Rotación de hombros',
      totalSeries: 3,
      restSeconds: 20,
      muscles: 'Hombros, trapecios, cuello',
      imageUrl:
          'https://static.vecteezy.com/system/resources/previews/017/457/662/non_2x/woman-demonstrates-how-to-do-shoulder-rotation-flat-illustration-female-exercise-isolated-on-white-background-athletic-girl-doing-exercises-vector.jpg',
      howTo: [
        'Párate o siéntate con la espalda recta.',
        'Sube los hombros hacia las orejas.',
        'Lleva los hombros hacia atrás en un círculo amplio.',
        'Bájalos y tráelos hacia adelante cerrando el círculo.',
        'Haz 10 rotaciones hacia atrás y 10 hacia adelante.',
      ],
      benefits: [
        'Libera la tensión de hombros y cuello.',
        'Mejora la circulación en la zona alta de la espalda.',
        'Previene contracturas por mala postura.',
        'Ideal para hacer después de estar sentado mucho tiempo.',
      ],
      tip: 'Haz los círculos lo más amplios posible.',
    ),
  ],

  'Mejorar autoestima': [
    Exercise(
      name: 'Postura de poder',
      totalSeries: 3,
      restSeconds: 30,
      muscles: 'Mente, postura, confianza',
      imageUrl:
          'https://us.images.westend61.de/0001077114j/vista-lateral-de-mujer-con-las-manos-en-la-cadera-estirando-contra-el-cielo-claro-en-la-playa-CAVF55016.jpg',
      howTo: [
        'Párate con los pies separados al ancho de los hombros.',
        'Pon las manos en la cadera o extiende los brazos en V.',
        'Saca el pecho, levanta el mentón y mira al frente.',
        'Respira profundo y mantén la posición 2 minutos.',
        'Piensa en algo que hayas logrado mientras la mantienes.',
      ],
      benefits: [
        'Reduce el cortisol y aumenta la testosterona.',
        'Mejora la confianza antes de situaciones importantes.',
        'Cambia el estado mental en minutos.',
        'Practicada por atletas y líderes de alto rendimiento.',
      ],
      tip: 'Dos minutos son suficientes para sentir el efecto.',
    ),
    Exercise(
      name: 'Sentadillas con afirmación',
      totalSeries: 3,
      restSeconds: 45,
      muscles: 'Cuádriceps, glúteos, mente positiva',
      imageUrl:
          'https://image.tuasaude.com/media/article/il/sk/agachamento-livre_70856.jpg?width=686&height=487',
      howTo: [
        'Párate con los pies al ancho de los hombros.',
        'Al bajar en sentadilla di mentalmente: "soy capaz".',
        'Al subir di mentalmente: "lo estoy logrando".',
        'Mantén el pecho arriba y la mirada al frente.',
        'Cada repetición es un recordatorio de tu fortaleza.',
      ],
      benefits: [
        'Combina ejercicio físico con programación mental positiva.',
        'Refuerza la conexión mente-cuerpo.',
        'Mejora la autoestima con cada repetición.',
        'Transforma el ejercicio en un acto de amor propio.',
      ],
      tip: 'No importa cuántas hagas, importa cómo te sientes al hacerlas.',
    ),
    Exercise(
      name: 'Flexiones lentas y conscientes',
      totalSeries: 3,
      restSeconds: 60,
      muscles: 'Pectoral, tríceps, hombros, autoconfianza',
      imageUrl:
          'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?w=800&q=80',
      howTo: [
        'Posición de flexión con el cuerpo recto.',
        'Baja lentamente contando 3 segundos.',
        'Sube en 1 segundo de forma explosiva.',
        'Celebra mentalmente cada repetición completada.',
        'Observa tu esfuerzo y reconócelo.',
      ],
      benefits: [
        'La lentitud aumenta la tensión muscular y los resultados.',
        'Cada rep completada refuerza la sensación de logro.',
        'Mejora la conexión entre mente y músculo.',
        'Construye disciplina y constancia.',
      ],
      tip: 'Menos repeticiones bien hechas valen más que muchas mal.',
    ),
    Exercise(
      name: 'Baile libre',
      totalSeries: 3,
      restSeconds: 0,
      muscles: 'Cuerpo completo, estado de ánimo',
      imageUrl:
          'https://images.unsplash.com/photo-1547153760-18fc86324498?w=800&q=80',
      howTo: [
        'Pon tu canción favorita.',
        'Muévete como quieras, sin reglas ni coreografía.',
        'Ocupa todo el espacio disponible.',
        'Cierra los ojos si te ayuda a soltarte.',
        'Disfruta el movimiento sin juzgarte.',
      ],
      benefits: [
        'Libera endorfinas y mejora el estado de ánimo.',
        'Reduce la vergüenza y el miedo al juicio.',
        'Expresión corporal que conecta con las emociones.',
        'Quema calorías sin que parezca ejercicio.',
      ],
      tip: 'No hay forma incorrecta de bailar cuando nadie te ve.',
    ),
    Exercise(
      name: 'Caminata con cabeza en alto',
      totalSeries: 1,
      restSeconds: 0,
      muscles: 'Postura, confianza, piernas',
      imageUrl:
          'https://images.unsplash.com/photo-1571008887538-b36bb32f4571?w=800&q=80',
      howTo: [
        'Sal a caminar por tu espacio o por la calle.',
        'Hombros hacia atrás y abajo, pecho abierto.',
        'Mirada al frente, no al suelo.',
        'Camina como si fueras a algo importante.',
        'Mantén el ritmo constante y la postura durante todo el recorrido.',
      ],
      benefits: [
        'Cambia el lenguaje corporal y la percepción de uno mismo.',
        'Mejora la postura a largo plazo.',
        'Genera una sensación de propósito y dirección.',
        'Combina actividad física con trabajo mental.',
      ],
      tip: 'La forma en que te mueves cambia cómo te sientes.',
    ),
  ],
};

// ── Pantalla principal ────────────────────────────────────────
class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});
  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  String _goal = '';
  String _name = '';
  bool _loading = true;
  int _streak = 0;
  bool _doneToday = false;
  bool _showSummary = false;
  List<bool> _completed = [];
  List<Exercise> _exercises = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name') ?? 'Usuario';
    final goal = prefs.getString('goal') ?? 'Perder peso';
    final streakData = await ApiService.getWorkoutStreak();
    final todayDone = await ApiService.getWorkoutProgress(goal);

    if (!mounted) return;

    final exercises = _routinesByGoal[goal]!;
    final completed = List.generate(
      exercises.length,
      (i) => todayDone.contains(i),
    );
    final allDone = completed.isNotEmpty && completed.every((c) => c);

    setState(() {
      _goal = goal;
      _name = name;
      _streak = streakData['streak'] ?? 0;
      _doneToday = streakData['worked_today'] ?? false;
      _loading = false;
      _exercises = exercises;
      _completed = completed;
      _showSummary = allDone && (streakData['worked_today'] ?? false);
    });
  }

  Future<void> _onExerciseDone(int index) async {
    // Guarda en el servidor
    await ApiService.saveWorkoutProgress(index, _goal);
    setState(() => _completed[index] = true);

    if (_completed.every((c) => c)) {
      final streak = await ApiService.registerWorkoutDone();
      if (!mounted) return;
      setState(() {
        _streak = streak;
        _doneToday = true;
        _showSummary = true;
      });
    }
  }

  void _openExercise(int index, Exercise ex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExerciseDetailModal(
        index: index,
        exercise: ex,
        isDone: _completed[index],
        onDone: () {
          Navigator.pop(context);
          _onExerciseDone(index);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final doneCount = _completed.where((c) => c).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Mi rutina'),
        backgroundColor: const Color(0xFF43A047),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 4),
                Text(
                  '$_streak días',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _showSummary
          ? _buildSummary(_exercises.length)
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hola $_name 💪',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rutina para: $_goal',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _exercises.isEmpty
                              ? 0
                              : doneCount / _exercises.length,
                          minHeight: 8,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation(
                            Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$doneCount / ${_exercises.length} completados',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              _streak == 0
                                  ? 'Sin racha aún'
                                  : '$_streak día${_streak == 1 ? '' : 's'} de racha',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (_doneToday) ...[
                              const SizedBox(width: 8),
                              const Text('✅', style: TextStyle(fontSize: 12)),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                if (_doneToday && !_showSummary) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: const Row(
                      children: [
                        Text('😴', style: TextStyle(fontSize: 20)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Ya completaste tu rutina hoy. Descansa y vuelve mañana.',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),
                const Text(
                  'Toca un ejercicio para ver los detalles',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),

                ..._exercises.asMap().entries.map((e) {
                  final done = _completed[e.key];
                  return GestureDetector(
                    onTap: () => _openExercise(e.key, e.value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: done ? const Color(0xFFE8F5E9) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: done
                              ? const Color(0xFF43A047).withOpacity(0.4)
                              : Colors.grey.shade200,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: e.value.imageUrl.isNotEmpty
                              ? Image.network(
                                  e.value.imageUrl,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _placeholder(),
                                )
                              : _placeholder(),
                        ),
                        title: Text(
                          e.value.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: done ? Colors.grey : Colors.black87,
                            decoration: done
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        subtitle: Text(
                          '${e.value.setsLabel} · ${e.value.muscles}',
                          style: TextStyle(
                            fontSize: 12,
                            color: done ? Colors.grey.shade400 : Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: done
                            ? const Icon(
                                Icons.check_circle,
                                color: Color(0xFF43A047),
                                size: 28,
                              )
                            : const Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: Colors.grey,
                              ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 20),
              ],
            ),
    );
  }

  Widget _placeholder() => Container(
    width: 56,
    height: 56,
    color: Colors.grey.shade100,
    child: const Icon(Icons.fitness_center, color: Colors.grey, size: 28),
  );

  Widget _buildSummary(int total) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 16),
            const Text(
              '¡Rutina completada!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Completaste $total ejercicios',
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 8),
                  Text(
                    '$_streak día${_streak == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'de racha',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: const Text(
                '😴 El descanso también es progreso.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF43A047),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Volver al inicio',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Modal de detalle ──────────────────────────────────────────
class _ExerciseDetailModal extends StatefulWidget {
  final int index;
  final Exercise exercise;
  final VoidCallback onDone;
  final bool isDone;

  const _ExerciseDetailModal({
    required this.index,
    required this.exercise,
    required this.onDone,
    required this.isDone,
  });

  @override
  State<_ExerciseDetailModal> createState() => _ExerciseDetailModalState();
}

class _ExerciseDetailModalState extends State<_ExerciseDetailModal> {
  bool _started = false;
  int _currentSerie = 0;
  bool _resting = false;
  int _secondsLeft = 0;
  Timer? _timer;

  void _startWorkout() => setState(() {
    _started = true;
    _currentSerie = 1;
  });

  void _completeSerie() {
    final ex = widget.exercise;
    if (_currentSerie >= ex.totalSeries) {
      widget.onDone();
      return;
    }
    if (ex.restSeconds == 0) {
      setState(() => _currentSerie++);
      return;
    }
    setState(() {
      _resting = true;
      _secondsLeft = ex.restSeconds;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() {
          _resting = false;
          _currentSerie++;
        });
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _skipRest() {
    _timer?.cancel();
    setState(() {
      _resting = false;
      _currentSerie++;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    final progress = ex.totalSeries == 0
        ? 0.0
        : (_currentSerie - 1) / ex.totalSeries;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: controller,
          padding: EdgeInsets.zero,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            // Imagen
            if (ex.imageUrl.isNotEmpty)
              AspectRatio(
                aspectRatio: 16 / 7,
                child: Image.network(
                  ex.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: Icon(
                        Icons.fitness_center,
                        color: Colors.grey,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ex.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.fitness_center,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          ex.muscles,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _badge(
                        Icons.repeat,
                        '${ex.totalSeries} series',
                        const Color(0xFF6C63FF),
                      ),
                      _badge(
                        Icons.timer_outlined,
                        ex.restLabel,
                        const Color(0xFF00897B),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Cómo hacerlo
                  _section('📋 Cómo hacerlo'),
                  const SizedBox(height: 10),
                  ...ex.howTo.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Color(0xFF43A047),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${e.key + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              e.value,
                              style: const TextStyle(fontSize: 14, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Ventajas
                  _section('✅ Ventajas'),
                  const SizedBox(height: 10),
                  ...ex.benefits.map(
                    (b) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF43A047),
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              b,
                              style: const TextStyle(fontSize: 14, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tip
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💡 ', style: TextStyle(fontSize: 16)),
                        Expanded(
                          child: Text(
                            ex.tip,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Zona de entrenamiento ──────────────
                  // ── Zona de entrenamiento ──────────────────────────────
                  // Si ya está completado desde la lista
                  if (widget.isDone)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 10),
                          Text(
                            '¡Ejercicio completado hoy!',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (!_started)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _startWorkout,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text(
                          'Iniciar ejercicio',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF43A047),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F6FA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF43A047).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _resting
                                ? 'Descansando...'
                                : 'Serie $_currentSerie de ${ex.totalSeries}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 10,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF43A047),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(
                              ex.totalSeries,
                              (i) => Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: i < _currentSerie - 1
                                      ? const Color(0xFF43A047)
                                      : i == _currentSerie - 1 && !_resting
                                      ? const Color(0xFF43A047).withOpacity(0.3)
                                      : Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: i < _currentSerie - 1
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16,
                                        )
                                      : Text(
                                          '${i + 1}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: i == _currentSerie - 1
                                                ? const Color(0xFF43A047)
                                                : Colors.grey,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_resting) ...[
                            Text(
                              _fmt(_secondsLeft),
                              style: TextStyle(
                                fontSize: 52,
                                fontWeight: FontWeight.bold,
                                color: _secondsLeft <= 5
                                    ? Colors.red
                                    : const Color(0xFF43A047),
                              ),
                            ),
                            const Text(
                              'Descansa y prepárate',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: _skipRest,
                              child: const Text(
                                'Saltar descanso',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ] else ...[
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _completeSerie,
                                icon: Icon(
                                  _currentSerie >= ex.totalSeries
                                      ? Icons.check
                                      : Icons.done,
                                ),
                                label: Text(
                                  _currentSerie >= ex.totalSeries
                                      ? '¡Listo! Completado'
                                      : 'Serie hecha · descansar',
                                  style: const TextStyle(fontSize: 15),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      _currentSerie >= ex.totalSeries
                                      ? Colors.green.shade700
                                      : const Color(0xFF43A047),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String text) => Text(
    text,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  );

  Widget _badge(IconData icon, String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
