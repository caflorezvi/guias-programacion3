```
Universidad del Quindío
Programa de Ingeniería de Sistemas y Computación
Programación III - Taller 4: OTP y aplicaciones distribuidas
Docente: Carlos Andrés Florez V.
```

# Taller 4. Aplicación práctica: OTP y sistemas distribuidos

| Campo | Información |
|---|---|
| **Núcleo temático** | 3 y 4. Abstracciones funcionales y aplicación práctica de la programación funcional |
| **Guías de referencia** | 12 a 16 (aplicaciones distribuidas 1 y 2, OTP y GenServer, supervisores, Mix) |
| **Modalidad** | Grupos de tres |
| **Valor** | 5.0 |
| **Entrega** | Proyecto Mix ejecutable en dos nodos, con pruebas, más el documento de análisis |

## Resultados de aprendizaje que se evalúan

| R.A. | Cómo se evalúa en este taller |
|---|---|
| **R.A.3** — Aplico los ejes conceptuales de la programación, con capacidad de toma de decisiones y pensamiento crítico, para dar respuesta a las necesidades de los clientes. | Partes C y D: elección argumentada entre `Agent` y `GenServer`, entre `call` y `cast`, entre estrategias de supervisión y entre mecanismos de comunicación remota, aplicadas a la construcción de un sistema funcional. |
| **R.A.2** — Analizo un contexto de manera crítica para la identificación de requisitos funcionales, interactuando local y globalmente mediante un uso efectivo de las tecnologías de la información. | Parte E: análisis del caso, definición de los requisitos del sistema distribuido y sustentación de la arquitectura ante el grupo. |
| **R.A.1** — Identifico los fundamentos del proceso de solución de problemas mediante la construcción de aplicaciones. | Partes A y D: seguimiento del estado de un `GenServer` y del comportamiento de un árbol de supervisión, y construcción del proyecto completo con Mix y pruebas automatizadas. |

Además, la **Parte F** aporta a lo actitudinal del sílabo, en particular al compromiso con el aprendizaje autónomo y a la realización de trabajos de calidad con responsabilidad ética, mediante el uso documentado y reflexivo de herramientas de inteligencia artificial.

---

## Parte A. Prueba de escritorio (1.0)

### A.1. Evolución del estado de un `GenServer` (0.5)

El siguiente `GenServer` gestiona una subasta. Su estado es un mapa con el precio actual, el participante ganador y si la subasta sigue abierta.

```elixir
defmodule Subasta do
  use GenServer

  def start_link(base), do: GenServer.start_link(__MODULE__, base, name: __MODULE__)
  def pujar(monto, quien), do: GenServer.call(__MODULE__, {:pujar, monto, quien})
  def cerrar, do: GenServer.call(__MODULE__, :cerrar)
  def estado, do: GenServer.call(__MODULE__, :estado)

  @impl true
  def init(base), do: {:ok, %{precio: base, ganador: nil, abierta: true}}

  @impl true
  def handle_call({:pujar, _m, _q}, _from, %{abierta: false} = e),
    do: {:reply, {:rechazada, :cerrada}, e}

  def handle_call({:pujar, monto, _q}, _from, %{precio: p} = e) when monto <= p,
    do: {:reply, {:rechazada, :monto_insuficiente}, e}

  def handle_call({:pujar, _m, quien}, _from, %{ganador: quien} = e),
    do: {:reply, {:rechazada, :ya_es_ganador}, e}

  def handle_call({:pujar, monto, quien}, _from, e),
    do: {:reply, {:ok, monto}, %{e | precio: monto, ganador: quien}}

  def handle_call(:cerrar, _from, e),
    do: {:reply, {:cerrada, e.ganador, e.precio}, %{e | abierta: false}}

  def handle_call(:estado, _from, e), do: {:reply, e, e}
end
```

Un único proceso cliente ejecuta, en este orden:

```elixir
Subasta.start_link(1000)
Subasta.pujar(1200, "Ana")
Subasta.pujar(1100, "Luis")
Subasta.pujar(1500, "Ana")
Subasta.pujar(1800, "Luis")
Subasta.cerrar()
Subasta.pujar(2000, "Ana")
```

| Llamado | Cláusula de `handle_call` que aplica | Estado después | Valor devuelto al cliente |
|---|---|---|---|
| `start_link(1000)` | `init/1` | | — |
| `pujar(1200, "Ana")` | | | |
| `pujar(1100, "Luis")` | | | |
| `pujar(1500, "Ana")` | | | |
| `pujar(1800, "Luis")` | | | |
| `cerrar()` | | | |
| `pujar(2000, "Ana")` | | | |

Responda:

1. La tercera puja (`1500, "Ana"`) es mayor que el precio actual y aun así se rechaza. ¿Cuál cláusula la atrapa y qué regla de negocio implementa?
2. El orden de las cuatro cláusulas de `{:pujar, ...}` importa. ¿Qué pasaría si la cláusula del `monto <= p` se colocara de última? Muestre una puja que se resolvería de forma incorrecta.
3. Todas las operaciones usan `call` y no `cast`. Explique por qué `pujar/2` **no** puede ser `cast`, considerando lo que el cliente necesita saber tras pujar.
4. ¿Seguiría siendo predecible el estado final si tres participantes pujaran al mismo tiempo desde procesos distintos? ¿Qué garantía del `GenServer` lo asegura?

### A.2. Comportamiento de un árbol de supervisión (0.5)

Un supervisor arranca tres hijos en este orden: `Registro`, `Cache` y `Reportes`, con `max_restarts: 3` y `max_seconds: 5`.

Complete la tabla indicando qué procesos son reiniciados cuando `Cache` falla, según la estrategia:

| Estrategia | ¿Se reinicia `Registro`? | ¿Se reinicia `Cache`? | ¿Se reinicia `Reportes`? |
|---|---|---|---|
| `:one_for_one` | | | |
| `:one_for_all` | | | |
| `:rest_for_one` | | | |

Responda además:

1. `Cache` falla cuatro veces en tres segundos. ¿Qué le ocurre al supervisor? ¿Y a los demás hijos?
2. `Reportes` se declara con `restart: :temporary`. Falla una vez. ¿Qué sucede?
3. El estado que `Cache` tenía en memoria antes de fallar, ¿se conserva tras el reinicio? Explique qué implica esto para el diseño del sistema y qué haría si ese estado no se puede perder.
4. `Registro` solo puede funcionar si `Cache` está activo, y `Reportes` necesita a los dos. ¿Cuál estrategia y cuál orden de arranque elegiría? Justifique.

---

## Parte B. Detección y corrección de errores (1.0)

Para cada fragmento indique **(a)** qué está mal, **(b)** cómo se manifiesta, **(c)** con qué caso se evidencia, y **(d)** la corrección.

### B.1

```elixir
@impl true
def handle_call(:saldo, _from, estado) do
  {:noreply, estado}
end
```

Explique qué le ocurre al proceso que llamó `GenServer.call/2` y después de cuánto tiempo.

### B.2

```elixir
@impl true
def handle_info(_mensaje, estado), do: {:noreply, estado}

@impl true
def handle_info(:actualizar, estado) do
  {:noreply, recalcular(estado)}
end
```

### B.3

```elixir
@impl true
def handle_call(:reporte, _from, estado) do
  detalle = GenServer.call(__MODULE__, :detalle)
  {:reply, {estado, detalle}, estado}
end
```

### B.4

```elixir
@impl true
def init(config) do
  datos = cargar_desde_archivo(config.ruta)   # tarda cerca de 30 segundos
  {:ok, datos}
end
```

El proyecto arranca, pero el supervisor reporta un fallo. Explique la causa y proponga dos formas distintas de resolverlo.

### B.5

```elixir
def conectar do
  Node.connect("nodo2@localhost")
end
```

### B.6

```elixir
def registrar(pid) do
  :global.register_name(:servidor_central, pid)
  :ok
end
```

Explique qué devuelve `:global.register_name/2`, qué pasa cuando el nombre ya está tomado por otro nodo y por qué ignorar ese retorno es un error grave en un sistema distribuido.

### B.7

```elixir
defmodule MiApp.MixProject do
  use Mix.Project

  def project do
    [app: :mi_app, version: "0.1.0", elixir: "~> 1.15", deps: deps()]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps, do: []
end
```

El proyecto define `MiApp.Application` con un árbol de supervisión, pero al ejecutar `iex -S mix` ninguno de los procesos está activo. Explique por qué.

---

## Parte C. Comparación de soluciones (0.8)

### C.1. `Agent` o `GenServer` (0.3)

Para cada requerimiento, decida cuál de los dos usaría y justifique en dos líneas:

| # | Requerimiento |
|---|---|
| 1 | Guardar la configuración de la aplicación, leída al arrancar y consultada por otros procesos. |
| 2 | Un contador de visitas que se incrementa y se consulta. |
| 3 | Una sala de subasta que debe cerrar automáticamente a los cinco minutos, avisar a los participantes y persistir el resultado. |
| 4 | Una cola de trabajos que reintenta las tareas fallidas y registra el motivo del fallo. |

### C.2. `call` o `cast` (0.2)

Clasifique cada operación y justifique. Señale además cuáles serían peligrosas si se implementaran con la opción contraria:

registrar una puja · consultar el precio actual · registrar un evento en la bitácora · cerrar la subasta · obtener la lista de participantes · notificar el fin del remate a los clientes

### C.3. Tres formas de comunicar dos nodos (0.3)

El nodo `cliente@host` necesita consultar el estado de una subasta que vive en `servidor@host`.

**Opción 1:** proceso registrado localmente en el servidor y `send({:subastas, :"servidor@host"}, mensaje)` desde el cliente.
**Opción 2:** `:rpc.call(:"servidor@host", Subastas, :estado, [id])`.
**Opción 3:** `GenServer` registrado con `:global` y `GenServer.call({:global, :subastas}, {:estado, id})`.

Implemente las tres y responda:

1. ¿Cuál obliga al cliente a conocer el nombre exacto del nodo servidor? ¿Por qué eso es un problema cuando el servidor puede moverse de máquina?
2. ¿Cuál maneja por sí misma la espera de la respuesta y el vencimiento del tiempo de espera, y cuál obliga a programarlo?
3. Desconecte el nodo servidor y ejecute las tres. Describa qué error produce cada una y cuál da el diagnóstico más claro.
4. Levante dos servidores que intenten registrarse con el mismo nombre global. ¿Qué ocurre? ¿Qué pasaría con la opción 1 en el mismo escenario?
5. Elija una para la parte D y justifique la decisión frente a las otras dos.

---

## Parte D. Construcción de código (1.5)

Construya, como proyecto Mix, un **sistema de subastas en línea distribuido**.

### D.1. Estructura y estado (0.5)

- Proyecto creado con `mix new` y con supervisión declarada en `mix.exs` mediante `mod:`.
- Un `GenServer` por subasta, con estado: identificador, artículo, precio base, puja más alta, participante que la hizo, historial de pujas y estado (`:abierta` o `:cerrada`).
- Un `DynamicSupervisor` que permita crear y cerrar subastas mientras el sistema está en ejecución.
- Un `Registro` que mantenga la relación entre el identificador de la subasta y el proceso correspondiente.
- Reglas de negocio: una puja solo se acepta si supera la puja actual y si la subasta está abierta; una subasta cerrada rechaza toda puja; un participante no puede superar su propia puja.

### D.2. Distribución (0.5)

- El sistema debe ejecutarse en **al menos dos nodos**: uno que aloja las subastas y otro desde el cual se conectan los participantes.
- Los clientes deben poder listar subastas, unirse a una, pujar y consultar el estado sin conocer el nodo en el que vive cada subasta.
- Debe funcionar en dos terminales de la misma máquina y, con la configuración documentada, en dos máquinas distintas de la misma red.
- Documente en el `README.md` los comandos de arranque, la cookie utilizada y los problemas que encontró al probar entre máquinas.

### D.3. Tolerancia a fallos (0.3)

- Si el proceso de una subasta falla, el supervisor debe reiniciarlo y la subasta debe recuperar su estado previo. Decida dónde persistir ese estado y justifique la decisión en el `README.md`.
- La caída de una subasta no puede afectar a las demás ni tumbar el sistema.
- Demuestre el comportamiento: en la sustentación deberá matar un proceso con `Process.exit(pid, :kill)` y mostrar que el sistema se recupera.

### D.4. Pruebas automatizadas (0.2)

Escriba pruebas con ExUnit que cubran, como mínimo:

- Una puja válida actualiza el precio y el participante ganador.
- Una puja menor o igual a la actual es rechazada.
- Una puja sobre una subasta cerrada es rechazada.
- El historial conserva el orden cronológico de las pujas.
- Tras el reinicio de un proceso, el estado se restaura.

Use `describe` para agrupar por escenario y `setup` para preparar los datos comunes. Todas las pruebas deben pasar con `mix test`.

---

## Parte E. Análisis y sustentación (0.3)

Entregue por escrito, antes de la implementación:

1. **Requisitos.** Al menos ocho requisitos funcionales verificables y tres no funcionales con su criterio de aceptación. Uno de los no funcionales debe referirse a qué ocurre cuando se cae un nodo.
2. **Arquitectura.** Diagrama del árbol de supervisión y diagrama de la comunicación entre nodos, con la ruta completa de un mensaje de puja desde el cliente hasta el `GenServer` de la subasta y de vuelta.
3. **Decisiones de diseño.** Una tabla con las decisiones tomadas (estrategia de supervisión, mecanismo de comunicación, `call` frente a `cast` en cada operación, forma de persistir el estado), la alternativa descartada y el motivo.
4. **Límites conocidos.** Enumere al menos tres situaciones que su sistema no maneja bien y explique qué haría para resolverlas si dispusiera de más tiempo. Reconocer un límite se evalúa positivamente; ocultarlo, no.

La sustentación es grupal, dura quince minutos e incluye la demostración en dos nodos y la prueba de recuperación ante fallos. Cualquier integrante puede ser preguntado sobre cualquier parte del código.

---

## Parte F. Uso documentado de inteligencia artificial (0.4)

Pueden apoyarse en alguno de los asistentes del curso (el cuaderno de NotebookLM o la Gema de Google Gemini, alimentados con las guías) o en otra herramienta de inteligencia artificial para **construir, evaluar o revisar** cualquier parte de este taller. La condición es que documenten ese uso y reflexionen sobre él. Este es el último taller del semestre, así que la reflexión debe abarcar también cómo cambió su forma de usar estas herramientas a lo largo del curso.

### F.1. Bitácora de uso

Entregue una tabla con una fila por cada consulta relevante a la IA:

| Parte del taller | Herramienta | Qué le pidieron (consulta o *prompt*) | Qué respondió (en resumen) | Qué hicieron con esa respuesta |
|---|---|---|---|---|

En la última columna sea específico: la usaron tal cual, la corrigieron, la adaptaron o la descartaron. Si adaptaron o descartaron algo, indiquen por qué.

### F.2. Conclusiones

Escriba entre media y una página respondiendo, con ejemplos concretos tomados de su propia bitácora:

1. ¿Qué **aprendieron** gracias a la IA que no sabían o no tenían claro? (por ejemplo, un callback de OTP, el manejo de cookies entre nodos, una función de `:global`).
2. ¿Qué **error propio** les ayudó a detectar y **corregir**?
3. ¿Qué **ajustaron o mejoraron** en su solución a partir de sus sugerencias (diseño, nombres, pruebas, estructura del proyecto)?
4. ¿En qué se **equivocó la IA** o los llevó por un camino incorrecto que ustedes tuvieron que enderezar? ¿Cómo se dieron cuenta?

### F.3. Consideraciones

- **No usar IA es una decisión válida.** En ese caso, entreguen un párrafo explicando por qué decidieron no usarla y cómo resolvieron las dudas (guías, documentación oficial, consulta al docente).
- Lo que se evalúa es la **honestidad y la profundidad de la reflexión**, no la cantidad de uso. Una bitácora corta con conclusiones sinceras vale más que una extensa y vacía.
- El uso de IA **no exime de entender el código**. Cualquier integrante puede ser preguntado en la sustentación sobre cualquier línea, incluidas las que se apoyaron en la IA. Entregar código que no se sabe explicar afecta la nota de todo el grupo.

---

## Entrega

Suba al aula virtual un archivo comprimido con:

- El proyecto Mix completo, sin la carpeta `_build` ni `deps`.
- El `README.md` con instrucciones de ejecución en uno y en dos nodos.
- Un documento en PDF con las tablas de la parte A, las respuestas de B y C, el análisis de la parte E y la bitácora y conclusiones de la parte F.
- La salida de `mix test`.

## Criterios de evaluación

| Criterio | Peso |
|---|---|
| Pruebas de escritorio del `GenServer` y del árbol de supervisión | 16 % |
| Detección de errores en callbacks, supervisión, distribución y configuración de Mix | 16 % |
| Argumentación en las comparaciones, en especial la de mecanismos de comunicación remota | 14 % |
| Funcionamiento del sistema: reglas de negocio, ejecución en dos nodos y recuperación ante fallos | 28 % |
| Pruebas automatizadas: cobertura de los casos exigidos y uso de `describe` y `setup` | 8 % |
| Análisis, arquitectura documentada y sustentación | 8 % |
| Uso documentado de IA: bitácora completa y conclusiones con reflexión genuina | 10 % |
