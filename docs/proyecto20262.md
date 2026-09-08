```
Universidad del Quindío
Programa de Ingeniería de Sistemas y Computación
Programación III - Proyecto Final
Docente: Carlos Andrés Florez V.
```

# Proyecto Final - Trivia Multijugador Distribuida

## 1. Objetivo del Proyecto

Implementar un juego multijugador de preguntas y respuestas con interfaz por consola, en el que varios jugadores se conectan al mismo tiempo y compiten en partidas independientes, ejecutándose de forma concurrente y distribuida en al menos 2 nodos Elixir.

El sistema no es un programa que cada jugador ejecuta por su cuenta. Hay un **servidor central** que se levanta una sola vez y concentra el estado del juego y los datos persistidos. Los **clientes** son programas de consola separados, sin estado de juego, que envían al servidor las peticiones que escribe el jugador y muestran lo que reciben de vuelta. La sección 8 detalla el reparto de responsabilidades y la comunicación entre ambos.

## 2. Alcance Obligatorio

El proyecto debe incluir obligatoriamente:

1. Registro e inicio de sesión de jugadores.
2. Creación de partidas con tema, número de preguntas y tiempo por pregunta configurables.
3. Ingreso de jugadores a partidas existentes, con cupo máximo.
4. Envío simultáneo de cada pregunta a todos los jugadores de la partida.
5. Temporizador por pregunta y cierre automático de la ronda al vencer el tiempo.
6. Cálculo de puntaje por respuesta correcta, incorrecta y sin responder, con bonificación por rapidez.
7. Ranking al final de cada partida y ranking histórico global filtrable por tema.
8. Múltiples partidas concurrentes, cada una en su propio proceso.
9. Ejecución distribuida: servidor y clientes en nodos Elixir distintos, con partidas alojadas en al menos 2 nodos.
10. Persistencia de jugadores, banco de preguntas e historial de partidas.
11. Manejo de errores propios para las situaciones inválidas del juego.

---

## 3. Modelo de Datos

### 3.1 Jugador

- `usuario` (identificador único, sin espacios)
- `clave` (se almacena en texto plano; el alcance del proyecto no incluye cifrado)
- `puntaje_acumulado` (suma de los puntajes obtenidos en todas sus partidas; puede ser negativo)
- `partidas_jugadas`

El puntaje por tema no se almacena en el jugador. El ranking filtrado por tema se calcula recorriendo el historial de partidas, lo que evita duplicar información y da un uso natural a los streams sobre archivos.

### 3.2 Pregunta

- `tema` (identificador en minúscula y sin espacios, por ejemplo `ciencia`)
- `enunciado`
- `opciones` (exactamente 4, identificadas como A, B, C y D)
- `respuesta` (una de las cuatro letras)

Se pueden agregar temas y preguntas editando `data/questions.json`, sin cambiar código.

### 3.3 Partida

- `id` (identificador único asignado al crearse, por ejemplo `P-1001`)
- `creador` (usuario que la creó)
- `tema`
- `total_preguntas`
- `tiempo_pregunta` (segundos)
- `jugadores` (entre 2 y 4)
- `estado` (`esperando`, `en_curso`, `finalizada`)
- `pregunta_actual` (número de la ronda en curso)
- `puntajes` (puntaje de cada jugador dentro de la partida)
- `nodo` (nodo donde se está ejecutando)

---

## 4. Gestión de Jugadores

### 4.1 Conexión y sesión

- `connect <usuario> <clave>`: inicia sesión; si el usuario no existe, lo registra automáticamente con puntaje acumulado en 0.
- `disconnect`: cierra la sesión. Si el jugador está en una partida en curso, se aplica lo definido en la sección 6.5.

Si el usuario existe pero la clave no coincide, el sistema rechaza la conexión.

### 4.2 Consultas

- `score`: muestra el puntaje acumulado del jugador y su número de partidas jugadas.
- `ranking [tema]`: muestra el ranking histórico global. Con un tema como argumento, muestra el ranking calculado solo con las partidas de ese tema.
- `list_games`: lista las partidas que aún admiten jugadores.

Formato sugerido para `score`:

```
=== Pedro ===
Puntaje acumulado: 85
Partidas jugadas: 6
```

Formato sugerido para `ranking`:

```
=== Ranking global ===
#    Jugador     Puntaje    Partidas
1    Ana             120          8
2    Pedro            85          6
3    Carlos          -10          3
```

Formato sugerido para `list_games`:

```
=== Partidas disponibles ===
ID       Tema       Preguntas   Tiempo   Jugadores   Estado
P-1001   ciencia        5         15s       2/4       esperando
P-1002   historia      10         20s       3/4       esperando
```

---

## 5. Gestión de Partidas

- `create_game tema=<tema> preguntas=<n> tiempo=<segundos>`: crea una partida y deja al creador dentro de ella. El sistema responde con el `id` asignado y el nodo donde quedó alojada.
- `join_game <id_partida>`: ingresa a una partida en estado `esperando`.
- `start_game`: el creador inicia la partida.
- `leave_game`: abandona la partida.

Reglas:

- Una partida admite entre 2 y 4 jugadores. Con un solo jugador no puede iniciarse.
- Cuando la partida alcanza 4 jugadores o pasa a estado `en_curso`, deja de admitir ingresos.
- Solo el creador puede ejecutar `start_game`.
- Un jugador puede estar en una sola partida a la vez.
- El tema solicitado debe existir en el banco y tener al menos tantas preguntas como pida `preguntas=<n>`.
- Si el creador abandona antes de iniciar, la partida se cancela y los demás jugadores quedan libres.

---

## 6. Dinámica del Juego

### 6.1 Selección de preguntas

Al iniciar la partida, el sistema sortea del banco tantas preguntas como se hayan configurado, filtradas por el tema de la partida y sin repetir ninguna dentro de la misma partida. Todos los jugadores reciben las mismas preguntas en el mismo orden.

### 6.2 Ronda

Cada ronda sigue esta secuencia:

1. La partida envía el enunciado y las cuatro opciones a todos sus jugadores al mismo tiempo, junto con el tiempo disponible.
2. Cada jugador responde de forma independiente con `answer <numero_pregunta> <letra>`.
3. La ronda termina cuando todos los jugadores han respondido o cuando vence el temporizador, lo que ocurra primero.
4. El sistema anuncia la respuesta correcta, el puntaje obtenido por cada jugador en la ronda y el acumulado dentro de la partida.
5. Comienza la siguiente ronda.

Formato sugerido para el envío de una pregunta:

```
═══ Pregunta 1 de 5 - Ciencia ═══
¿Cuál es el planeta más grande del sistema solar?
  A) Marte      B) Júpiter      C) Saturno      D) Neptuno
Tiempo: 15 segundos

Respuesta > _
```

Formato sugerido para el cierre de la ronda:

```
Respuesta correcta: B) Júpiter

  Pedro    B  correcto (4s)    +13   = 10 + 3 por rapidez   (total 13)
  Carlos   C  incorrecto (7s)   -5                          (total -5)
  Ana      -  sin responder      0                          (total 0)
```

### 6.3 Reglas de respuesta

- Solo se valida la primera respuesta de cada jugador en cada ronda. Las siguientes se ignoran sin penalización y el sistema lo informa.
- El número de pregunta debe corresponder a la ronda en curso. Una respuesta con otro número se rechaza.
- La letra debe ser A, B, C o D. Cualquier otro valor se rechaza y no consume la respuesta del jugador.

### 6.4 Puntaje

| Situación | Puntos |
|-----------|--------|
| Respuesta correcta   | +10, más la bonificación por rapidez |
| Respuesta incorrecta | -5  |
| Sin responder        | 0   |

**Bonificación por rapidez.** Una respuesta correcta suma puntos adicionales según el tiempo que sobraba cuando llegó:

```text
bonificacion = trunc(5 * segundos_restantes / tiempo_pregunta)
puntos_ronda = 10 + bonificacion
```

`segundos_restantes` es el tiempo que faltaba para que venciera el temporizador en el momento en que la partida recibió la respuesta. La bonificación va de 0 a 5 puntos, así que una respuesta correcta vale entre 10 y 15. Al dividir sobre `tiempo_pregunta`, una partida de 30 segundos reparte la bonificación con el mismo criterio que una de 15.

Ejemplos con `tiempo_pregunta = 15`:

| Momento de la respuesta | Segundos restantes | Bonificación | Puntos si es correcta |
|-------------------------|--------------------|--------------|-----------------------|
| 1 s                     | 14                 | 4            | 14                    |
| 4 s                     | 11                 | 3            | 13                    |
| 9 s                     | 6                  | 2            | 12                    |
| 14 s                    | 1                  | 0            | 10                    |

Para calcular la bonificación, la partida debe registrar el instante en que empieza la ronda y el instante en que llega la respuesta de cada jugador.

Los puntajes negativos son válidos y se conservan tanto en el resultado de la partida como en el puntaje acumulado del jugador. Callar cuando no se sabe la respuesta es distinto de arriesgarse.

### 6.5 Desconexión durante la partida

- Si un jugador se desconecta o abandona con la partida en curso, sus rondas restantes se cuentan como sin responder y conserva el puntaje obtenido hasta ese momento.
- Si queda un solo jugador activo, la partida termina de inmediato y se registra como finalizada con ese jugador como ganador.

---

## 7. Resultados y Ranking

Al terminar la última ronda, la partida muestra su ranking y persiste el resultado:

```
═══ Fin de la partida P-1001 (ciencia) ═══
Nodo: arena@host2 | Preguntas: 5 | Duración: 1m 24s

#    Jugador   Correctas   Incorrectas   Sin responder   Bonificación   Puntaje
1    Pedro         4            1              0              8             43
2    Ana           3            1              1              6             31
3    Carlos        1            4              0              2             -8

Ganador: Pedro
```

Después del anuncio:

1. Se agrega una línea al historial en `data/results.log`.
2. Se suma el puntaje de la partida al puntaje acumulado de cada jugador y se incrementa su contador de partidas jugadas en `data/users.json`.
3. Los jugadores quedan libres para crear o unirse a otra partida.

En caso de empate en el puntaje más alto, la partida se registra con ganador compartido.

---

## 8. Arquitectura Cliente-Servidor, Concurrencia y Distribución

### 8.1 Servidor central

El servidor es el único punto donde vive el estado del juego. Se levanta una vez, antes de que se conecte cualquier jugador, y se encarga de:

- Cargar el banco de preguntas desde `data/questions.json` al arrancar y mantenerlo en memoria.
- Leer y escribir `data/users.json` y `data/results.log`. Es el único componente que toca el sistema de archivos.
- Crear, listar y supervisar las partidas activas, y saber en qué nodo quedó alojada cada una.
- Resolver cada ronda, calcular los puntajes y decidir el resultado de la partida.

Como consecuencia, el cliente nunca ve las respuestas correctas ni el archivo de preguntas. Si el banco viviera en el cliente, cualquier jugador podría abrirlo y hacer trampa.

### 8.2 Clientes

Cada jugador ejecuta su propio cliente en una consola aparte, en su propio nodo. El cliente no tiene lógica de juego: lee lo que el jugador escribe, lo traduce en una petición al servidor, y muestra por pantalla lo que llega de vuelta.

El intercambio tiene dos direcciones:

- **Peticiones.** Las origina el jugador y esperan respuesta, como `connect`, `list_games`, `create_game`, `join_game`, `start_game`, `answer`, `score` y `ranking`. El cliente envía la petición y espera a que el servidor conteste con el resultado o con un error de los definidos en la sección 10.
- **Notificaciones.** Las origina el servidor y llegan sin que nadie las pida, como el enunciado de una pregunta, el cierre de una ronda o el ranking final. El cliente no sabe cuándo van a llegar y debe estar listo para recibirlas en cualquier momento.

Para conectarse, el cliente enlaza su nodo con el nodo del servidor y ubica el proceso del servidor por su nombre registrado en el clúster, sin necesidad de conocer su PID.

Un cliente que se cae o se desconecta no puede dejar colgada una partida. El servidor monitorea los procesos de los jugadores conectados y, cuando uno desaparece, aplica las reglas de la sección 6.5.

### 8.3 Partidas concurrentes y distribución

- Cada partida debe vivir en un proceso `GenServer` independiente, gestionado por un `DynamicSupervisor`.
- El sistema debe ejecutarse en al menos 2 nodos conectados, y las partidas deben distribuirse entre ellos. El servidor lleva el directorio de qué partida vive en qué nodo y enruta hacia allá las peticiones de los jugadores.
- Un jugador conectado desde cualquier nodo debe poder jugar en una partida alojada en otro. El jugador no elige el nodo ni necesita saber cuál le tocó.

Resultado esperado:

- Dos partidas distintas pueden correr al mismo tiempo sin interferencia, con temas, tiempos y jugadores diferentes.
- Una falla en una partida no debe tumbar el servidor ni afectar a las demás partidas activas.

### 8.4 Comunicación en tiempo real

Para que las notificaciones lleguen mientras el jugador está en la consola:

- Al unirse a una partida, cada jugador registra el PID de su proceso cliente.
- La partida usa `send` para entregar sus notificaciones a todos los PID registrados.
- El cliente separa el proceso que lee del teclado del que recibe mensajes de la partida, de modo que un mensaje entrante no quede bloqueado esperando a que el jugador escriba.

Esta es la parte más delicada del proyecto y conviene resolverla temprano.

---

## 9. Persistencia (Archivos)

| Archivo               | Contenido                                                                             |
|-----------------------|---------------------------------------------------------------------------------------|
| `data/users.json`     | usuario, clave, puntaje acumulado, partidas jugadas                                   |
| `data/questions.json` | banco de preguntas por tema: tema, enunciado, cuatro opciones y respuesta correcta     |
| `data/results.log`    | historial de partidas: fecha, id, tema, nodo, duración, ganador y puntaje de cada jugador |

Se usa JSON para los datos estructurados porque los enunciados de las preguntas contienen comas y otros signos que complicarían un CSV. La dependencia `jason` se declara en `mix.exs`. El historial `results.log` es texto plano con una línea por partida, pensado para recorrerse con streams al calcular el ranking por tema.

Requisito: el puntaje acumulado, el número de partidas jugadas y el historial deben mantenerse entre ejecuciones del programa.

> **⚠️ Archivos semilla:** El banco `questions.json` lo crea el estudiante como parte del proyecto. Debe incluir al menos **4 temas** con un mínimo de **15 preguntas cada uno**, para que una partida de 5 preguntas pueda sortear sin repetir. Los archivos `users.json` y `results.log` se generan automáticamente al registrar jugadores y al finalizar partidas.

---

## 10. Manejo de Errores

El sistema debe definir y utilizar errores propios para al menos estas situaciones:

- Comando ejecutado sin haber iniciado sesión.
- Clave incorrecta al conectarse con un usuario existente.
- Ingreso a una partida llena, ya iniciada o inexistente.
- `start_game` ejecutado por alguien distinto del creador, o con un solo jugador en la partida.
- Tema inexistente o con menos preguntas de las solicitadas al crear la partida.
- Respuesta con letra inválida o con un número de pregunta que no corresponde a la ronda en curso.

En todos los casos el sistema informa el problema y continúa operando. Un error de un jugador no puede tumbar la partida ni el servidor.

---

## 11. Arquitectura Recomendada

```text
proyecto_trivia/
|-- lib/
|   |-- trivia/
|   |   |-- servidor.ex             # SERVIDOR: recibe las peticiones y las enruta
|   |   |-- gestor_jugadores.ex     # SERVIDOR: registro, sesión, puntajes y ranking
|   |   |-- gestor_partidas.ex      # SERVIDOR: creación, listado e ingreso a partidas
|   |   |-- partida.ex              # SERVIDOR: GenServer de partida
|   |   |-- supervisor_partidas.ex  # SERVIDOR: DynamicSupervisor de partidas
|   |   |-- banco_preguntas.ex      # SERVIDOR: carga y sorteo de preguntas por tema
|   |   |-- persistencia.ex         # SERVIDOR: lectura/escritura de archivos
|   |   |-- cluster.ex              # SERVIDOR: nodos y asignación distribuida
|   |   |-- cliente.ex              # CLIENTE: consola del jugador y envío de peticiones
|   |   |-- receptor.ex             # CLIENTE: recepción de notificaciones del servidor
|-- data/                           # solo existe en el nodo del servidor
|   |-- users.json
|   |-- questions.json
|   |-- results.log
|-- test/
|-- mix.exs
```

Aunque todo el código se entregue en un mismo proyecto Mix, los módulos marcados como servidor y como cliente se ejecutan en nodos distintos, y el cliente nunca invoca directamente los del servidor.

---

## 12. Pruebas Mínimas Requeridas

Programar al menos 5 pruebas con ExUnit que cubran como mínimo:

1. Cálculo del puntaje de una ronda con respuesta correcta, incorrecta y sin responder, incluyendo la bonificación por rapidez en distintos momentos y con dos valores de `tiempo_pregunta`.
2. Sorteo de preguntas: la cantidad solicitada, todas del tema pedido y sin repetir.
3. Validación de respuestas: se acepta solo la primera de cada jugador y se rechazan letra inválida y número de pregunta fuera de la ronda.
4. Reglas de ingreso a una partida: rechazar partida llena, partida ya iniciada e inicio por alguien distinto del creador.
5. Actualización del puntaje acumulado y del historial al terminar una partida.

---

## 13. Criterios de Aceptación

Se considera cumplido si:

1. Dos o más jugadores se conectan y juegan una partida completa de principio a fin.
2. Las preguntas llegan a todos los jugadores al mismo tiempo y el temporizador cierra la ronda cuando vence.
3. El puntaje se calcula según las reglas definidas y el ranking final de la partida es correcto.
4. El puntaje acumulado y el historial persisten al reiniciar la aplicación.
5. Se ejecutan dos partidas simultáneas con temas y tiempos distintos, sin interferencia entre ellas.
6. Los clientes funcionan sin acceso a los archivos de datos, obteniendo del servidor todo lo que muestran.
7. Se demuestra ejecución distribuida en al menos 2 nodos, con un jugador conectado a un nodo jugando en una partida alojada en el otro.
8. El ranking histórico global y el filtrado por tema muestran resultados coherentes con el historial.
9. Las situaciones de error de la sección 10 se manejan sin tumbar el servidor.
10. Las pruebas unitarias pasan.

---

## 14. Flujo de Ejemplo

### 14.1 Preparación

1. **Servidor:** se levanta el nodo `trivia@host1`, que carga el banco de preguntas y los jugadores registrados, y el nodo `arena@host2`, que queda disponible para alojar partidas.
2. **Sesión:** Pedro y Carlos abren cada uno su cliente en su propio nodo y ejecutan `connect pedro 1234` y `connect carlos 1234`. Ninguno existía, así que el servidor los registra con puntaje 0.
3. **Creación:** Pedro ejecuta `create_game tema=ciencia preguntas=5 tiempo=15`. El servidor crea la partida `P-1001` en `arena@host2` y le responde con el identificador.
4. **Ingreso:** Carlos ejecuta `list_games`, ve `P-1001` y ejecuta `join_game P-1001`. Su cliente queda registrado en la partida aunque esté conectado a otro nodo.
5. **Inicio:** Pedro ejecuta `start_game`. El servidor sortea 5 preguntas de ciencia y la partida envía la primera a los clientes de ambos.

### 14.2 Rondas representativas

**Ronda 1 - Respuestas dentro del tiempo:**

- Ambos reciben la pregunta sobre el planeta más grande del sistema solar.
- Pedro responde `answer 1 B` a los 4 segundos → correcto, 10 + 3 de bonificación = +13 (total 13).
- Carlos responde `answer 1 C` a los 7 segundos → incorrecto, -5 sin bonificación (total -5).
- Como ya respondieron los dos, la ronda cierra antes de que venza el temporizador.

**Ronda 2 - Vence el temporizador:**

- Carlos responde `answer 2 A` a los 9 segundos → correcto, 10 + 2 de bonificación = +12 (total 7).
- Pedro no alcanza a responder. Al vencer los 15 segundos la ronda cierra y su respuesta cuenta como sin responder, 0 puntos (total 13).

**Ronda 3 - Respuesta rechazada:**

- Pedro escribe `answer 2 D`. El número no corresponde a la ronda en curso, así que el sistema rechaza la respuesta e informa el error sin penalizarlo.
- Pedro corrige con `answer 3 A` a los 6 segundos → correcto, 10 + 3 de bonificación = +13 (total 26). El tiempo perdido en el intento rechazado le costó bonificación, no puntos.

### 14.3 Cierre de la partida

1. Después de la ronda 5, el sistema muestra el ranking con correctas, incorrectas, sin responder, bonificación acumulada y puntaje de cada jugador.
2. Se persiste el resultado como indica la sección 7.
3. Verificación sugerida: ejecutar `score` y `ranking ciencia` para confirmar los cambios.

---

## 15. Entrega y Evaluación

### 15.1 Entregables

1. **Repositorio Git** con el proyecto Mix completo, siguiendo la arquitectura recomendada e incluyendo el archivo semilla `data/questions.json`.
2. **Archivo `README.md`** con: integrantes, instrucciones de compilación, cómo levantar el nodo del servidor y los nodos de los clientes, cómo conectarlos (mínimo 2 nodos) y la lista de comandos disponibles.
3. **Documentación del uso de inteligencia artificial** indicando herramientas y propósito.
4. **Pruebas ExUnit** (mínimo las 5 de la sección 12) que pasen con `mix test`.
5. **Sustentación** en vivo demostrando los criterios de aceptación, con el servidor y al menos tres clientes en consolas separadas, dos partidas simultáneas y los dos nodos en ejecución.
