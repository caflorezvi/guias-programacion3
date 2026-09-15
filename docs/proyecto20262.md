```
Universidad del Quindío
Programa de Ingeniería de Sistemas y Computación
Programación III - Proyecto Final
Docente: Carlos Andrés Florez V.
```

# Proyecto Final - Trivia Concurrente

## 1. Objetivo del Proyecto

Implementar un juego de preguntas y respuestas con interfaz por consola, en el que cada jugador humano compite contra al menos dos jugadores automáticos (bots). Las preguntas tienen nivel de dificultad y se ajustan a lo que el jugador ha demostrado en cada tema, así que quien acumula puntos en un tema empieza a recibir preguntas más difíciles de ese tema. Las partidas son independientes entre sí y se ejecutan de forma concurrente.

El sistema no es un programa que cada jugador ejecuta por su cuenta. Hay un **servidor central** que se levanta una sola vez, queda corriendo y concentra el estado del juego y los datos persistidos. Los **clientes** son programas de consola separados, sin estado de juego, que se abren después, se comunican con el servidor, le envían las peticiones que escribe el jugador y muestran lo que reciben de vuelta. Cada cliente juega su propia partida con sus propios bots, y varias partidas corren al mismo tiempo en el servidor. La sección 8 detalla el reparto de responsabilidades y la comunicación entre ambos.

Que varios jugadores humanos compartan una misma partida **no es un requisito del proyecto**. Queda descrito como extensión opcional en la sección 15.

## 2. Alcance Obligatorio

El proyecto debe incluir obligatoriamente:

1. Registro e inicio de sesión de jugadores.
2. Creación de partidas con tema, número de preguntas y tiempo por pregunta configurables.
3. Preguntas con nivel de dificultad, sorteadas según el nivel del jugador en el tema de la partida.
4. Jugadores automáticos que completan la partida y juegan como uno más.
5. Envío simultáneo de cada pregunta a todos los jugadores de la partida.
6. Temporizador por pregunta y cierre automático de la ronda al vencer el tiempo.
7. Cálculo de puntaje por respuesta correcta, incorrecta y sin responder, según el nivel de la pregunta y con bonificación por rapidez.
8. Ranking al final de cada partida y ranking histórico global filtrable por tema.
9. Un servidor central y clientes que se ejecutan en consolas separadas y se comunican con él.
10. Múltiples partidas concurrentes, una por cliente, cada una en su propio proceso.
11. Reinicio de una partida que falla, con aviso al creador y sin afectar a las demás ni al servidor.
12. Persistencia de jugadores, banco de preguntas e historial de partidas.
13. Manejo de errores propios para las situaciones inválidas del juego.

Cada partida la juega un humano, que es quien la crea, contra dos o tres bots. La concurrencia no depende de que varios humanos compartan partida, porque cada partida atiende al mismo tiempo el temporizador de la ronda, la respuesta del jugador y las de sus bots, y las partidas de los distintos clientes corren a la vez dentro del servidor.

---

## 3. Modelo de Datos

### 3.1 Jugador

- `usuario` (identificador único, sin espacios)
- `clave` (se almacena en texto plano; el alcance del proyecto no incluye cifrado)

El jugador no guarda estadísticas. Su puntaje acumulado, sus partidas jugadas, su puntaje por tema y su nivel en cada tema se calculan recorriendo el historial de partidas, lo que evita duplicar información y da un uso natural a los streams sobre archivos.

### 3.2 Pregunta

- `tema` (identificador en minúscula y sin espacios, por ejemplo `ciencia`)
- `nivel` (`basico`, `intermedio` o `avanzado`)
- `enunciado`
- `opciones` (exactamente 4, identificadas como A, B, C y D)
- `respuesta` (una de las cuatro letras)

Se pueden agregar temas y preguntas editando `data/questions.json`, sin cambiar código.

### 3.3 Partida

- `id` (identificador único asignado al crearse, por ejemplo `P-1001`)
- `creador` (usuario que la creó)
- `tema`
- `nivel` (nivel del creador en el tema al momento de crear la partida)
- `total_preguntas`
- `tiempo_pregunta` (segundos)
- `jugadores` (entre 3 y 4, el creador y sus bots)
- `estado` (`esperando`, `en_curso`, `finalizada`)
- `pregunta_actual` (número de la ronda en curso)
- `puntajes` (puntaje de cada jugador dentro de la partida)

---

## 4. Gestión de Jugadores

### 4.1 Conexión y sesión

- `connect <usuario> <clave>`: inicia sesión; si el usuario no existe, lo registra automáticamente.
- `disconnect`: cierra la sesión. Si el jugador está en una partida en curso, se aplica lo definido en la sección 6.5.

Si el usuario existe pero la clave no coincide, el sistema rechaza la conexión.

Un mismo usuario no puede tener dos sesiones abiertas al mismo tiempo desde clientes distintos.

El prefijo `bot_` está reservado para los jugadores automáticos de la sección 6.6, así que un usuario que empiece por `bot_` se rechaza al conectarse.

### 4.2 Consultas

- `score`: muestra el puntaje acumulado del jugador, su número de partidas jugadas y, por cada tema que ha jugado, su puntaje y su nivel.
- `ranking [tema]`: muestra el ranking histórico global. Con un tema como argumento, muestra el ranking calculado solo con las partidas de ese tema.

Formato sugerido para `score`:

```
=== Pedro ===
Puntaje acumulado: 85
Partidas jugadas: 6

Tema        Puntaje   Nivel
ciencia          72   intermedio
historia         13   basico
```

Formato sugerido para `ranking`:

```
=== Ranking global ===
#    Jugador     Puntaje    Partidas
1    Ana             120          8
2    Pedro            85          6
3    Carlos          -10          3
```

---

## 5. Gestión de Partidas

- `create_game tema=<tema> preguntas=<n> tiempo=<segundos>`: crea una partida y deja al creador dentro de ella. El sistema responde con el `id` asignado y el nivel del creador en ese tema.
- `add_bot <facil|dificil>`: agrega un jugador automático a la partida.
- `start_game`: inicia la partida.
- `leave_game`: abandona la partida.

Reglas:

- Una partida tiene entre 3 y 4 jugadores. Uno es el creador y los demás son bots, así que antes de `start_game` deben haberse agregado al menos dos.
- Cuando la partida alcanza 4 jugadores, `add_bot` se rechaza. Tampoco se pueden agregar bots a una partida en curso.
- Un jugador puede estar en una sola partida a la vez.
- El tema solicitado debe existir en el banco y tener suficientes preguntas de cada nivel para el reparto de la sección 6.1.
- Si el creador abandona antes de iniciar, la partida se cancela.

---

## 6. Dinámica del Juego

### 6.1 Nivel del jugador y selección de preguntas

**Nivel del jugador.** Al crear una partida, el servidor recorre el historial y suma los puntajes que el creador ha obtenido en las partidas de ese tema. Con esa suma decide su nivel:

| Puntaje acumulado en el tema | Nivel        |
|------------------------------|--------------|
| menos de 60                  | `basico`     |
| de 60 a 179                  | `intermedio` |
| 180 o más                    | `avanzado`   |

Un jugador que nunca ha jugado un tema empieza en `basico`. El nivel también puede bajar, porque los puntajes negativos restan del acumulado del tema. El nivel queda fijo en la partida desde que se crea, aunque el resultado de esa misma partida lo cambie para la siguiente.

**Reparto por nivel.** Una partida no trae solo preguntas del nivel del jugador. Mezcla niveles según esta tabla:

| Nivel del jugador | Básico | Intermedio | Avanzado |
|-------------------|--------|------------|----------|
| `basico`          | 70 %   | 30 %       | 0 %      |
| `intermedio`      | 20 %   | 60 %       | 20 %     |
| `avanzado`        | 0 %    | 30 %       | 70 %     |

Para los dos niveles distintos al del jugador, la cantidad de preguntas es `trunc(total_preguntas * porcentaje / 100)`. Las que sobran son del nivel del jugador. Por ejemplo, con 5 preguntas un jugador `basico` recibe 1 intermedia (`trunc(1.5)`) y 4 básicas, y con 10 preguntas un jugador `avanzado` recibe 3 intermedias y 7 avanzadas.

**Sorteo.** Al iniciar la partida, el sistema sortea del banco las preguntas de cada nivel, filtradas por el tema de la partida y sin repetir ninguna dentro de la misma partida. Las ordena de menor a mayor nivel, y dentro de un mismo nivel quedan en el orden del sorteo, así que la partida se pone más difícil a medida que avanza. Todos los jugadores de la partida reciben las mismas preguntas en el mismo orden. Cada partida hace su propio sorteo, así que dos partidas del mismo tema pueden tener preguntas distintas.

### 6.2 Ronda

Cada ronda sigue esta secuencia:

1. La partida envía el enunciado y las cuatro opciones a todos sus jugadores al mismo tiempo, junto con el tiempo disponible.
2. Cada jugador responde de forma independiente. El humano lo hace con `answer <letra>`.
3. La ronda termina cuando todos los jugadores han respondido o cuando vence el temporizador, lo que ocurra primero.
4. El sistema anuncia la respuesta correcta, el puntaje obtenido por cada jugador en la ronda y el acumulado dentro de la partida.
5. Después de una pausa de 3 segundos comienza la siguiente ronda. Durante la pausa no hay ronda abierta, así que una respuesta que llegue tarde se rechaza en lugar de contar para la pregunta siguiente.

Formato sugerido para el envío de una pregunta:

```
═══ Pregunta 1 de 5 - Ciencia - Nivel básico ═══
¿Cuál es el planeta más grande del sistema solar?
  A) Marte      B) Júpiter      C) Saturno      D) Neptuno
Tiempo: 15 segundos

Respuesta > _
```

Formato sugerido para el cierre de la ronda:

```
Respuesta correcta: B) Júpiter

  bot_1    +14   (total 14)
  bot_2     -5   (total -5)
  Pedro      0   (total 0)
```

### 6.3 Reglas de respuesta

- Solo se valida la primera respuesta de cada jugador en cada ronda. Las siguientes se ignoran sin penalización y el sistema lo informa.
- Una respuesta que llega cuando no hay ronda abierta, sea en la pausa entre rondas o con la partida sin iniciar o ya terminada, se rechaza.
- La letra debe ser A, B, C o D. Cualquier otro valor se rechaza y no consume la respuesta del jugador.

### 6.4 Puntaje

Los puntos dependen del nivel de la pregunta:

| Situación            | Básico | Intermedio | Avanzado |
|----------------------|--------|------------|----------|
| Respuesta correcta   | +10    | +15        | +20      |
| Respuesta incorrecta | -5     | -8         | -10      |
| Sin responder        | 0      | 0          | 0        |

A una respuesta correcta se le suma además la bonificación por rapidez.

**Bonificación por rapidez.** Una respuesta correcta suma puntos adicionales según el tiempo que sobraba cuando llegó:

```text
bonificacion = trunc(5 * segundos_restantes / tiempo_pregunta)
puntos_ronda = puntos_nivel + bonificacion
```

`segundos_restantes` es el tiempo que faltaba para que venciera el temporizador en el momento en que la partida recibió la respuesta. La bonificación va de 0 a 5 puntos sin importar el nivel, así que una respuesta correcta básica vale entre 10 y 15, una intermedia entre 15 y 20 y una avanzada entre 20 y 25. Al dividir sobre `tiempo_pregunta`, una partida de 30 segundos reparte la bonificación con el mismo criterio que una de 15.

Ejemplos con `tiempo_pregunta = 15`:

| Momento de la respuesta | Segundos restantes | Bonificación | Correcta básica | Correcta avanzada |
|-------------------------|--------------------|--------------|-----------------|-------------------|
| 1 s                     | 14                 | 4            | 14              | 24                |
| 4 s                     | 11                 | 3            | 13              | 23                |
| 9 s                     | 6                  | 2            | 12              | 22                |
| 14 s                    | 1                  | 0            | 10              | 20                |

Para calcular la bonificación, la partida debe registrar el instante en que empieza la ronda y el instante en que llega la respuesta de cada jugador.

Los puntajes negativos son válidos y se conservan tanto en el resultado de la partida como en el puntaje acumulado del jugador. Callar cuando no se sabe la respuesta es distinto de arriesgarse. La penalización crece con el nivel para que responder al azar siga sin convenir. Quien adivina entre cuatro opciones acierta una de cada cuatro veces, y sin contar la bonificación pierde en promedio más de lo que gana en los tres niveles.

### 6.5 Abandono durante la partida

Si el jugador humano ejecuta `leave_game` o `disconnect` con la partida en curso, o si su cliente se cierra, la partida termina de inmediato. Las rondas que faltaban no se juegan y el resultado se registra con los puntajes obtenidos hasta ese momento, como indica la sección 7. Así, abandonar una partida que va mal no borra el resultado.

### 6.6 Jugadores automáticos

Un bot es un jugador que responde solo. Se agrega con `add_bot`, ocupa un cupo de la partida y recibe un nombre único dentro de ella (`bot_1`, `bot_2`, ...).

Los bots viven en el servidor, no en el cliente. Cada bot vive en su **propio proceso**, registra su PID en la partida igual que el cliente del jugador humano y recibe las mismas notificaciones. Cuando le llega una pregunta, decide qué contestar y programa su respuesta para más adelante con `Process.send_after`, de modo que la partida la recibe como cualquier otra. Si un bot necesita un camino especial dentro de la partida para poder jugar, el diseño está mal.

La dificultad define qué tan bien y qué tan rápido responde:

| Dificultad | Acierta en básica | Acierta en intermedia | Acierta en avanzada | Momento de la respuesta            |
|------------|-------------------|-----------------------|---------------------|------------------------------------|
| `facil`    | 40 %              | 30 %                  | 20 %                | entre el 40 % y el 90 % del tiempo |
| `dificil`  | 80 %              | 70 %                  | 60 %                | entre el 10 % y el 40 % del tiempo |

Con `tiempo_pregunta = 15`, un bot fácil responde entre los segundos 6 y 13.5, y uno difícil entre los segundos 1.5 y 6. Cuando el bot falla, escoge al azar una de las tres opciones incorrectas. Para decidir, el bot solo necesita el nivel de la pregunta y la respuesta correcta, que recibe de la partida porque vive en el servidor. Esos datos nunca se envían a los clientes.

Los bots puntúan con las mismas reglas de la sección 6.4 y aparecen en el ranking final de la partida, pero no se registran en `data/users.json` ni se cuentan en el ranking histórico. Al calcular el ranking, el puntaje y el nivel de un jugador, las entradas del historial que corresponden a bots se ignoran.

Un bot no se desconecta ni abandona la partida.

---

## 7. Resultados y Ranking

Al terminar la última ronda, la partida muestra su ranking y persiste el resultado:

```
═══ Fin de la partida P-1001 (ciencia, nivel básico) ═══
#    Jugador   Puntaje
1    Pedro         48
2    bot_1         22
3    bot_2        -11

Ganador: Pedro
```

Después del anuncio:

1. Se agrega una línea al historial en `data/results.log`. Con esa línea quedan actualizados el puntaje acumulado, las partidas jugadas y el nivel del jugador, porque todos se calculan desde el historial.
2. El jugador queda libre para crear otra partida.

En caso de empate en el puntaje más alto, la partida se registra con ganador compartido. Si el ganador es un bot, el historial lo registra como tal.

Como varias partidas pueden terminar al mismo tiempo y varios jugadores pueden registrarse a la vez, las escrituras sobre `users.json` y `results.log` deben pasar por un único proceso del servidor, para que una escritura no se mezcle con otra.

---

## 8. Arquitectura Cliente-Servidor y Concurrencia

### 8.1 Servidor central

El servidor es el único punto donde vive el estado del juego. Se levanta una vez en su propia consola, antes de que se conecte cualquier jugador, queda corriendo y se encarga de:

- Cargar el banco de preguntas desde `data/questions.json` al arrancar y mantenerlo en memoria.
- Leer y escribir `data/users.json` y `data/results.log`. Es el único componente que toca el sistema de archivos.
- Llevar las sesiones de los jugadores conectados.
- Crear y supervisar las partidas activas y sus bots.
- Resolver cada ronda, calcular los puntajes y decidir el resultado de la partida.

Como consecuencia, el cliente nunca ve las respuestas correctas ni el archivo de preguntas. Si el banco viviera en el cliente, cualquier jugador podría abrirlo y hacer trampa.

### 8.2 Clientes

Cada jugador abre su propio cliente en una consola aparte. Como cada consola ejecuta su propia máquina virtual de Erlang, cada cliente es un nodo Elixir distinto del servidor, y para comunicarse los dos nodos deben estar conectados.

Ejemplo de arranque en tres consolas:

```bash
# Consola 1: servidor
iex --sname servidor -S mix

# Consola 2: cliente de Pedro
iex --sname pedro -S mix

# Consola 3: cliente de Carlos
iex --sname carlos -S mix
```

El proyecto debe definir cómo arranca cada nodo en su papel. El nodo de un cliente no puede levantar su propio servidor, porque entonces tendría su propia copia del juego en lugar de usar la central.

El cliente no tiene lógica de juego. Lee lo que el jugador escribe, lo traduce en una petición al servidor y muestra por pantalla lo que llega de vuelta. Para conectarse, enlaza su nodo con el del servidor y ubica el proceso del servidor por su nombre, sin necesidad de conocer su PID.

Un cliente que se cae o se cierra no puede dejar colgada una partida. El servidor monitorea los procesos de los clientes conectados y, cuando uno desaparece, cierra su sesión y aplica las reglas de la sección 6.5.

### 8.3 Peticiones y notificaciones

El intercambio entre cliente y servidor tiene dos direcciones:

- **Peticiones.** Las origina el jugador y esperan respuesta, como `connect`, `create_game`, `add_bot`, `start_game`, `answer`, `score` y `ranking`. El cliente envía la petición y espera a que el servidor conteste con el resultado o con un error de los definidos en la sección 10.
- **Notificaciones.** Las origina la partida y llegan sin que nadie las pida, como el enunciado de una pregunta, el cierre de una ronda o el ranking final. El cliente no sabe cuándo van a llegar y debe estar listo para recibirlas en cualquier momento.

Para que las notificaciones lleguen mientras el jugador está en la consola:

- Al crear la partida, el cliente registra en ella el PID del proceso que recibe sus mensajes.
- La partida usa `send` para entregar sus notificaciones a todos los PID registrados, sin distinguir si son de un cliente en otro nodo o de un bot en el servidor.
- El cliente separa el proceso que lee del teclado del que recibe mensajes de la partida, de modo que un mensaje entrante no quede bloqueado esperando a que el jugador escriba.

### 8.4 Partidas concurrentes

- Cada partida debe vivir en un proceso `GenServer` independiente, gestionado por un `DynamicSupervisor`.
- Todas las partidas corren dentro del nodo del servidor, con temas, tiempos y jugadores distintos, sin interferencia entre ellas.
- El jugador no necesita saber en qué proceso vive su partida. El servidor la ubica a partir de su sesión.

Resultado esperado:

- Dos clientes conectados con usuarios distintos, cada uno con su propia partida y sus bots, juegan al mismo tiempo sin que el temporizador de una partida afecte a la otra.
- Las notificaciones de una partida llegan solo a sus jugadores.
- Una falla en una partida no debe tumbar el servidor ni afectar a las demás partidas activas.

### 8.5 Reinicio de partidas

Una partida que falla no puede tumbar el servidor ni dejar a su jugador esperando una pregunta que no va a llegar. El sistema no guarda el progreso de las partidas, así que la partida que falla se reinicia desde cero y le avisa al creador.

- Las partidas se registran en el `DynamicSupervisor` con `restart: :transient`, de modo que se reinician cuando terminan de forma anormal y no cuando terminan bien.
- El supervisor reinicia la partida con los mismos argumentos con los que se creó, que son el `id`, el creador, el tema, el número de preguntas, el tiempo por pregunta y el PID del cliente. La partida vuelve al estado `esperando`, solo con el creador, sin bots y sin puntajes.
- Las rondas jugadas antes de la falla se pierden y no se registra nada en el historial.
- Los bots se lanzan enlazados a la partida, así que mueren con ella. Para volver a jugar, el creador agrega de nuevo los bots y ejecuta `start_game`.
- El PID de la partida cambia al reiniciarse, así que el servidor no puede seguir usando el que obtuvo al crearla. El PID del cliente sí sigue siendo válido, porque vive en otro nodo.

`init` recibe los mismos argumentos al crearse que al reiniciarse, de modo que la partida no sabe por sí sola si viene de una falla. Una forma de resolverlo es que, al arrancar, la partida le reporte al gestor de partidas su `id` y su PID. Si el gestor ya tenía ese `id` con otro PID, se trata de un reinicio, así que guarda el PID nuevo y le envía el aviso al creador. El reporte debe hacerse con `cast`, porque mientras crea la partida el gestor está esperando a que el supervisor termine de arrancarla, y un `call` desde `init` lo dejaría bloqueado.

Formato sugerido para el aviso:

```
La partida P-1001 falló y se reinició sin su progreso. Agrega los bots y ejecuta start_game para jugar de nuevo.
```

---

## 9. Persistencia (Archivos)

| Archivo               | Contenido                                                                       |
|-----------------------|---------------------------------------------------------------------------------|
| `data/users.json`     | usuario y clave                                                                 |
| `data/questions.json` | banco de preguntas: tema, nivel, enunciado, cuatro opciones y respuesta correcta |
| `data/results.log`    | historial de partidas: fecha, id, tema, nivel, ganador y puntaje de cada jugador |

Se usa JSON para los datos estructurados porque los enunciados de las preguntas contienen comas y otros signos que complicarían un CSV. La dependencia `jason` se declara en `mix.exs`. El historial `results.log` es texto plano con una línea por partida, pensado para recorrerse con streams al calcular el puntaje, las partidas jugadas, el ranking y el nivel de un jugador en un tema.

Requisito: los usuarios registrados y el historial deben mantenerse entre ejecuciones del servidor. Todas las estadísticas se reconstruyen a partir del historial.

> **⚠️ Archivos semilla:** El banco `questions.json` lo crea el estudiante como parte del proyecto. Debe incluir al menos **4 temas** con un mínimo de **8 preguntas por nivel en cada tema** (24 por tema), para que una partida de hasta 10 preguntas pueda sortearse sin repetir en cualquiera de los tres niveles. Los archivos `users.json` y `results.log` se generan automáticamente al registrar jugadores y al finalizar partidas.

---

## 10. Manejo de Errores

El sistema debe definir y utilizar errores propios para al menos estas situaciones:

- Comando ejecutado sin haber iniciado sesión.
- Clave incorrecta al conectarse con un usuario existente.
- Usuario que ya tiene una sesión abierta en otro cliente.
- Usuario que empieza por el prefijo reservado `bot_`.
- Servidor no disponible cuando el cliente intenta conectarse.
- `create_game` ejecutado por un jugador que ya está en una partida.
- Tema inexistente, o sin suficientes preguntas de algún nivel para el reparto que corresponde al crear la partida.
- `add_bot` o `start_game` ejecutados sin estar en una partida.
- `add_bot` con la partida llena o ya iniciada.
- `start_game` con menos de dos bots en la partida.
- Respuesta con letra inválida o enviada cuando no hay una ronda abierta.

En todos los casos el sistema informa el problema y continúa operando. Un error de un jugador no puede tumbar la partida, el servidor ni los demás clientes.

---

## 11. Arquitectura Recomendada

```text
proyecto_trivia/
|-- lib/
|   |-- trivia/
|   |   |-- servidor.ex             # SERVIDOR: recibe las peticiones y las enruta
|   |   |-- gestor_jugadores.ex     # SERVIDOR: registro, sesiones, puntajes y ranking
|   |   |-- gestor_partidas.ex      # SERVIDOR: creación, ubicación y aviso de reinicio
|   |   |-- partida.ex              # SERVIDOR: GenServer de partida
|   |   |-- supervisor_partidas.ex  # SERVIDOR: DynamicSupervisor de partidas
|   |   |-- bot.ex                  # SERVIDOR: jugador automático
|   |   |-- banco_preguntas.ex      # SERVIDOR: carga y sorteo de preguntas por tema y nivel
|   |   |-- nivel.ex                # SERVIDOR: nivel del jugador y reparto por nivel
|   |   |-- persistencia.ex         # SERVIDOR: lectura/escritura de archivos
|   |   |-- cliente.ex              # CLIENTE: consola del jugador y envío de peticiones
|   |   |-- receptor.ex             # CLIENTE: recepción de notificaciones de la partida
|-- data/                           # solo lo usa el nodo del servidor
|   |-- users.json
|   |-- questions.json
|   |-- results.log
|-- test/
|-- mix.exs
```

Aunque todo el código se entregue en un mismo proyecto Mix, los módulos marcados como servidor y como cliente se ejecutan en nodos distintos, y el cliente nunca invoca directamente los del servidor. Solo le envía peticiones al proceso del servidor y recibe mensajes de la partida.

---

## 12. Pruebas Mínimas Requeridas

Programar al menos 5 pruebas con ExUnit, elegidas de esta lista de 7:

1. Cálculo del puntaje de una ronda con respuesta correcta, incorrecta y sin responder en los tres niveles, incluyendo la bonificación por rapidez en distintos momentos y con dos valores de `tiempo_pregunta`.
2. Sorteo de preguntas: la cantidad solicitada, todas del tema pedido, sin repetir, con la cantidad de cada nivel que indica el reparto y ordenadas de menor a mayor nivel.
3. Validación de respuestas: se acepta solo la primera de cada jugador y se rechazan la letra inválida y la respuesta que llega sin ronda abierta.
4. Reglas de armado de una partida: rechazar `add_bot` con la partida llena o ya iniciada, y `start_game` con menos de dos bots.
5. Estadísticas desde el historial: a partir de líneas de historial se calculan el puntaje acumulado y las partidas jugadas de un jugador, y las entradas de bots se ignoran.
6. Decisión de un bot: devuelve una de las cuatro letras y un retardo dentro del rango de su dificultad.
7. Nivel del jugador: a partir de líneas de historial se calcula el puntaje por tema y el nivel, incluyendo los valores justo en los umbrales (59, 60, 179 y 180), un puntaje negativo y un tema nunca jugado.

La prueba 6 solo es posible si la decisión del bot está separada del proceso que la ejecuta, y la 7 si el cálculo del nivel recibe las líneas del historial en lugar de abrir el archivo por su cuenta.

---

## 13. Criterios de Aceptación

Se considera cumplido si:

1. El servidor se levanta en su propia consola y queda esperando clientes.
2. Un jugador abre un cliente en otra consola, se conecta, agrega dos bots y juega una partida completa de principio a fin.
3. Dos clientes en consolas separadas, con usuarios distintos, juegan al mismo tiempo cada uno su propia partida con sus bots, con temas y tiempos distintos, sin interferencia entre ellas.
4. Las preguntas llegan a todos los jugadores de la partida al mismo tiempo y el temporizador cierra la ronda cuando vence.
5. El puntaje se calcula según las reglas definidas, con los puntos del nivel de cada pregunta, y el ranking final de la partida es correcto.
6. Las preguntas de una partida respetan el reparto por nivel del creador en el tema, y un jugador que supera un umbral recibe en su siguiente partida de ese tema el reparto del nuevo nivel.
7. Los bots responden dentro del tiempo, aciertan según su dificultad y el nivel de la pregunta, puntúan y aparecen en el ranking final, sin llegar a `users.json` ni al ranking histórico.
8. Los clientes funcionan sin acceso a los archivos de datos, obteniendo del servidor todo lo que muestran.
9. Al cerrar un cliente con su partida en curso, la partida termina según la sección 6.5 y el servidor sigue atendiendo a los demás clientes.
10. Los usuarios y el historial persisten al reiniciar el servidor, y con ellos el puntaje acumulado, las partidas jugadas y el nivel de cada jugador en cada tema.
11. El ranking histórico global y el filtrado por tema muestran resultados coherentes con el historial.
12. Las situaciones de error de la sección 10 se manejan sin tumbar el servidor.
13. Las pruebas unitarias pasan.

---

## 14. Flujo de Ejemplo

### 14.1 Preparación

1. **Servidor:** en la primera consola se levanta el nodo del servidor, que carga el banco de preguntas y los jugadores registrados y queda esperando clientes.
2. **Sesión de Pedro:** Pedro abre su cliente en una segunda consola y ejecuta `connect pedro 1234`. No existía, así que el servidor lo registra.
3. **Partida de Pedro:** Pedro ejecuta `create_game tema=ciencia preguntas=5 tiempo=15`. Como nunca ha jugado ciencia, su nivel en el tema es `basico`. El servidor crea la partida `P-1001` y le responde con el identificador y el nivel.
4. **Bots de Pedro:** Pedro ejecuta `add_bot dificil` y `add_bot facil`. El servidor agrega a `bot_1` y `bot_2`, y la partida queda con tres jugadores.
5. **Partida de Carlos:** Carlos abre su cliente en una tercera consola, ejecuta `connect carlos 1234` y crea `P-1002` con tema historia, 10 preguntas y 20 segundos por pregunta. Carlos ya acumula 195 puntos en historia, así que su nivel es `avanzado` y su partida trae 3 preguntas intermedias y 7 avanzadas. Agrega tres bots y ejecuta `start_game`.
6. **Inicio:** Pedro ejecuta `start_game`. Con nivel `basico` y 5 preguntas, al servidor le corresponde sortear 4 preguntas básicas y 1 intermedia de ciencia, que quedan de últimas. La partida envía la primera a los tres. Desde este momento las dos partidas corren al mismo tiempo.

### 14.2 Rondas representativas de la partida de Pedro

**Ronda 1 - Respuestas dentro del tiempo:**

- Los tres reciben la pregunta sobre el planeta más grande del sistema solar.
- `bot_1` decide responder a los 3 segundos y acierta → 10 + 4 de bonificación = +14 (total 14).
- Pedro responde `answer B` a los 4 segundos → correcto, 10 + 3 de bonificación = +13 (total 13).
- `bot_2` responde a los 9 segundos y falla → -5 sin bonificación (total -5).
- Como ya respondieron los tres, la ronda cierra antes de que venza el temporizador.

**Ronda 2 - Vence el temporizador:**

- `bot_1` responde a los 2 segundos y acierta → 10 + 4 de bonificación = +14 (total 28).
- `bot_2` responde a los 8 segundos y acierta → 10 + 2 de bonificación = +12 (total 7).
- Pedro no alcanza a responder. Al vencer los 15 segundos la ronda cierra y su respuesta cuenta como sin responder, 0 puntos (total 13).
- Un segundo después, Pedro envía `answer C`. Llega durante la pausa entre rondas, así que el sistema la rechaza y no cuenta para la pregunta 3.

**Ronda 3 - Respuesta rechazada:**

- Pedro escribe `answer E`. La letra no es válida, así que el sistema rechaza la respuesta e informa el error sin consumir su respuesta.
- Pedro corrige con `answer A` a los 6 segundos → correcto, 10 + 3 de bonificación = +13 (total 26). El tiempo perdido en el intento rechazado le costó bonificación, no puntos.

Mientras tanto, Carlos recibe en su consola solo las preguntas de historia de `P-1002`, cada una con sus 20 segundos.

### 14.3 Cierre de la partida

1. La ronda 5 es la pregunta intermedia. Pedro la responde bien a los 5 segundos → 15 + 3 de bonificación = +18.
2. El sistema muestra en la consola de Pedro el ranking con el puntaje de cada jugador y el ganador.
3. Se persiste el resultado como indica la sección 7.
4. Verificación sugerida: ejecutar `score` y `ranking ciencia` para confirmar los cambios y comprobar que los bots no aparecen. Si con esta partida Pedro llega a 60 puntos en ciencia, `score` ya lo muestra en nivel `intermedio` y su siguiente partida de ciencia trae el reparto de ese nivel.

---

## 15. Extensión Opcional - Varios Humanos en la Misma Partida

> **Esta sección no es un requisito.** Un proyecto que cumple las secciones 1 a 14 está completo. Implementar esta extensión suma como trabajo adicional, pero no hacerla no resta nada de la nota.

En el alcance obligatorio cada cliente juega solo contra sus bots. La extensión permite que un jugador conectado desde otro cliente entre a una partida ya creada y compita en ella junto con los bots.

### 15.1 Comandos adicionales

- `list_games`: lista las partidas que aún admiten jugadores.
- `join_game <id_partida>`: ingresa a una partida en estado `esperando`.

Formato sugerido para `list_games`:

```
=== Partidas disponibles ===
ID       Tema       Nivel        Preguntas   Tiempo   Jugadores   Estado
P-1001   ciencia    basico           5         15s       2/4       esperando
P-1002   historia   avanzado        10         20s       3/4       esperando
```

### 15.2 Cambios en las reglas

- Un humano que entra con `join_game` ocupa un cupo igual que un bot. La partida sigue teniendo entre 3 y 4 jugadores, y la condición para iniciarla pasa a ser que el creador tenga al menos dos rivales, sean humanos o bots.
- Solo el creador puede ejecutar `add_bot` y `start_game`.
- El nivel de la partida es el del creador en el tema. Los humanos que entran con `join_game` juegan ese mismo reparto, sin importar su propio nivel, y `list_games` muestra el nivel de cada partida para que cada quien decida a cuál unirse.
- Cuando la partida alcanza 4 jugadores o pasa a estado `en_curso`, deja de admitir ingresos.
- Si el creador abandona antes de iniciar, la partida se cancela y los demás jugadores quedan libres.
- Si un humano abandona o se desconecta con la partida en curso y queda al menos otro humano, la partida continúa. Sus rondas restantes se cuentan como sin responder y conserva el puntaje obtenido hasta ese momento.
- Cuando ya no queda ningún humano en la partida, esta termina y se registra como indica la sección 6.5.
- La línea del historial incluye el puntaje de todos los humanos de la partida, así que el resultado cuenta en las estadísticas de cada uno.

### 15.3 Errores adicionales

- Ingreso a una partida llena, ya iniciada o inexistente.
- `add_bot` o `start_game` ejecutados por alguien distinto del creador.

### 15.4 Demostración

Si el grupo implementa la extensión, la muestra en la sustentación con dos clientes que entran a la misma partida y la juegan completa junto con al menos un bot.

---

## 16. Entrega y Evaluación

### 16.1 Entregables

1. **Repositorio Git** con el proyecto Mix completo, siguiendo la arquitectura recomendada e incluyendo el archivo semilla `data/questions.json`.
2. **Archivo `README.md`** con: integrantes, instrucciones de compilación, cómo levantar el nodo del servidor y los nodos de los clientes, cómo conectarlos y la lista de comandos disponibles.
3. **Documentación del uso de inteligencia artificial** indicando herramientas y propósito.
4. **Pruebas ExUnit** (mínimo 5 de las 7 de la sección 12) que pasen con `mix test`.
5. **Sustentación** en vivo demostrando los criterios de aceptación, con el servidor y al menos dos clientes en consolas separadas, cada uno con su propia partida y sus bots jugando al mismo tiempo. La extensión opcional se demuestra solo si se implementó.
