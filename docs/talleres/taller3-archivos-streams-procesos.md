```
Universidad del Quindío
Programa de Ingeniería de Sistemas y Computación
Programación III - Taller 3: Archivos, streams y procesos
Docente: Carlos Andrés Florez V.
```

# Taller 3. Abstracciones funcionales y manejo de efectos

| Campo | Información |
|---|---|
| **Núcleo temático** | 3. Abstracciones funcionales y manejo de efectos |
| **Guías de referencia** | 9 a 11 (streams, manejo de archivos, procesos) |
| **Modalidad** | Grupos de tres |
| **Valor** | 5.0 |
| **Entrega** | Proyecto de código, archivos de datos generados y documento de análisis |

## Resultados de aprendizaje que se evalúan

| R.A. | Cómo se evalúa en este taller |
|---|---|
| **R.A.2** — Analizo un contexto de manera crítica como punto de partida para la identificación de requisitos funcionales, aplicando principios éticos y morales. | Parte E: análisis de un caso real, formulación de los requisitos funcionales antes de escribir código y tratamiento responsable de los datos personales contenidos en los archivos. |
| **R.A.1** — Identifico los fundamentos del proceso de solución de problemas mediante la construcción de aplicaciones. | Partes A y D: seguimiento del orden de evaluación de un stream y del buzón de un proceso, y construcción del procesador de archivos. |
| **R.A.3** — Aplico los ejes conceptuales de la programación, con capacidad de toma de decisiones y pensamiento crítico. | Partes B y C: diagnóstico de fallas en el manejo de efectos y elección justificada entre estrategias de lectura y de concurrencia. |

La **Parte F** aporta a lo actitudinal del sílabo, en particular al compromiso con el aprendizaje autónomo y a la responsabilidad ética, mediante el uso documentado y reflexivo de la inteligencia artificial.

---

## Parte A. Prueba de escritorio (1.0)

### A.1. Orden de evaluación de un stream (0.5)

```elixir
1..10
|> Stream.map(fn x ->
     IO.puts("map #{x}")
     x * 2
   end)
|> Stream.filter(fn x ->
     IO.puts("  filter #{x}")
     rem(x, 3) == 0
   end)
|> Enum.take(2)
```

1. Escriba, en orden, **todas** las líneas que se imprimen en pantalla.
2. Indique el valor que devuelve la expresión.
3. ¿Cuántos de los diez números del rango llegaron a procesarse? ¿Por qué se detuvo ahí?
4. Reemplace `Stream` por `Enum` en ambas etapas y repita los puntos 1 a 3. Presente las dos salidas en columnas paralelas.
5. A partir de la comparación, explique qué significa que la evaluación sea perezosa y en qué caso concreto esa diferencia dejaría de ser irrelevante.

### A.2. El buzón de un proceso (0.5)

```elixir
pid = spawn(fn ->
  receive do
    {:b, v} -> IO.puts("B #{v}")
  end

  receive do
    {:a, v} -> IO.puts("A #{v}")
  end
end)

send(pid, {:a, 1})
send(pid, {:b, 2})
send(pid, {:a, 3})
```

Complete la tabla siguiendo el estado del buzón paso a paso:

| Momento | Contenido del buzón | Mensaje consumido | Se imprime |
|---|---|---|---|
| Después de los tres `send` | | — | — |
| Durante el primer `receive` | | | |
| Durante el segundo `receive` | | | |
| Al terminar el proceso | | — | — |

Responda además:

1. El primer mensaje enviado fue `{:a, 1}`, pero no fue el primero en consumirse. Explique por qué.
2. ¿Qué mensaje queda sin consumir y qué le ocurre?
3. Si se agregara un tercer `receive` con la cláusula `{:a, v}`, ¿el proceso terminaría? ¿Qué pasaría si además se agregara un cuarto?
4. Modifique el código con `after` para que ningún `receive` pueda dejar el proceso bloqueado indefinidamente.

---

## Parte B. Detección y corrección de errores (0.7)

Para cada fragmento indique **(a)** qué está mal, **(b)** cómo se manifiesta, **(c)** con qué caso de prueba se evidencia, y **(d)** la corrección.

### B.1

```elixir
def cargar(ruta) do
  {:ok, contenido} = File.read!(ruta)
  String.split(contenido, "\n")
end
```

### B.2

```elixir
def guardar(datos) do
  File.write("C:\\Users\\estudiante\\Documentos\\proyecto\\salida.txt", datos)
  IO.puts("Guardado correctamente")
end
```

Este fragmento tiene dos problemas independientes. Encuentre ambos.

### B.3

```elixir
def procesar_log(ruta) do
  ruta
  |> File.read!()
  |> String.split("\n")
  |> Enum.filter(&String.contains?(&1, "ERROR"))
  |> Enum.count()
end
```

El código funciona correctamente con el archivo de prueba de 200 líneas. Explique por qué deja de funcionar con el archivo real de 4 GB y corríjalo.

### B.4

```elixir
def calcular_en_paralelo(lista) do
  resultado = spawn(fn -> Enum.sum(lista) end)
  IO.puts("La suma es #{resultado}")
end
```

### B.5

```elixir
def consultar(pid) do
  send(pid, {:consultar, self()})

  receive do
    {:respuesta, valor} -> valor
  end
end
```

Explique qué ocurre si `pid` corresponde a un proceso que ya terminó, y por qué `send/2` no avisa del problema.

### B.6

```elixir
def procesar_archivos(rutas) do
  Enum.map(rutas, fn ruta ->
    Task.async(fn -> analizar(ruta) end)
  end)
end
```

---

## Parte C. Comparación de soluciones (1.0)

### C.1. Dos estrategias de lectura (0.4)

Genere un archivo `temperaturas.txt` con un millón de líneas, donde cada línea es un valor numérico (la temperatura registrada por un sensor). Compare estas dos implementaciones que calculan la temperatura promedio:

```elixir
# Estrategia 1
def promedio_a(ruta) do
  valores =
    ruta
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_float/1)

  Enum.sum(valores) / length(valores)
end

# Estrategia 2
def promedio_b(ruta) do
  {suma, conteo} =
    ruta
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_float/1)
    |> Enum.reduce({0.0, 0}, fn v, {s, n} -> {s + v, n + 1} end)

  suma / conteo
end
```

1. Mida tiempo y memoria de cada una (`:timer.tc/1` y `:erlang.memory(:total)` antes y después).
2. Explique la diferencia en consumo de memoria a partir de lo que hace cada estrategia. Preste atención a que la estrategia 1 mantiene en memoria dos estructuras completas a la vez.
3. Construya ahora un archivo de 20 líneas y repita la medición. ¿Sigue ganando la misma estrategia? ¿Qué conclusión saca sobre el uso indiscriminado de streams?

### C.2. Tres formas de resolver lo concurrente (0.4)

Se necesita procesar 8 archivos de forma concurrente y obtener la lista de resultados.

**Opción 1:** `spawn` con `send`/`receive` y un contador de respuestas recibidas.
**Opción 2:** `Task.async/1` sobre la lista de archivos y luego `Task.await/1` sobre cada tarea.
**Opción 3:** `Task.async_stream/3` con `max_concurrency: 4`.

Implemente las tres y responda:

1. ¿Cuál de las tres garantiza que los resultados llegan en el mismo orden de la lista de entrada? ¿Qué debe hacer en las otras para lograrlo?
2. ¿Qué ocurre en cada opción si uno de los archivos no existe y la función de procesamiento falla?
3. ¿Por qué `max_concurrency` puede ser preferible a lanzar los ocho procesos a la vez? Piense en el caso de 10.000 archivos.
4. Elija una opción para el punto D.2 y justifique la elección en función del problema, no de la comodidad.

### C.3. Dónde manejar el error (0.2)

Dos versiones de la misma función de lectura:

```elixir
# Versión con tuplas de resultado
def leer(ruta) do
  case File.read(ruta) do
    {:ok, contenido} -> {:ok, String.split(contenido, "\n")}
    {:error, motivo} -> {:error, motivo}
  end
end

# Versión que deja fallar
def leer!(ruta) do
  ruta
  |> File.read!()
  |> String.split("\n")
end
```

Indique en qué situación usaría cada una, teniendo en cuenta la filosofía de dejar fallar que se estudiará con los supervisores. Dé un ejemplo concreto de uso apropiado para cada versión.

---

## Parte D. Construcción de código (1.0)

Trabajará con un archivo `comparendos.csv` con la siguiente estructura, del cual se le entrega una muestra de 500 registros y se le pide generar uno de al menos 200.000 líneas para las pruebas:

```
id,cedula,nombre,placa,municipio,infraccion,valor,fecha,estado
```

### D.1. Procesamiento con streams (0.5)

Construya el módulo `Comparendos` con:

| Función | Comportamiento |
|---|---|
| `total_por_municipio/1` | Mapa con la suma de los valores agrupada por municipio. |
| `top_infracciones/2` | Las `n` infracciones más frecuentes, con su conteo. |
| `pendientes_de_pago/1` | Stream de los registros con estado `pendiente`. |
| `recaudo_esperado/1` | Suma de los valores pendientes. |
| `exportar_resumen/2` | Escribe un archivo de texto con el informe consolidado. |

Requisitos:

- Todo el archivo debe procesarse con `File.stream!/1`; en ningún punto puede cargarse completo en memoria.
- Las líneas mal formadas (con menos columnas de las esperadas o con valor no numérico) deben descartarse y contabilizarse aparte, sin interrumpir el procesamiento.
- Las rutas deben construirse con `Path.join/2` a partir de `__DIR__`.
- Toda operación sobre archivos debe manejar el caso de error de forma explícita.

### D.2. Procesamiento concurrente (0.5)

El archivo llega ahora particionado en varios archivos, uno por municipio. Construya `Comparendos.Concurrente` con:

- `procesar_todos/1`, que recibe la ruta de una carpeta, procesa cada archivo en un proceso independiente y consolida los resultados.
- Un mecanismo que informe el avance a medida que cada archivo termina.
- Manejo de fallos: si un archivo no puede procesarse, el consolidado debe completarse con los demás y reportar cuáles fallaron y por qué.
- Un tiempo máximo de espera por archivo, vencido el cual se reporta el archivo como no procesado.

Compare el tiempo total contra una versión secuencial y reporte la diferencia.

---

## Parte E. Análisis del contexto y manejo responsable de los datos (1.0)

Esta parte se responde por escrito y debe entregarse **antes** de escribir el código de la parte D. Se evalúa el razonamiento, no la extensión.

**Contexto.** La secretaría de tránsito de un municipio necesita un informe mensual de comparendos. Hoy el proceso es manual; un funcionario abre el archivo en una hoja de cálculo y aplica filtros. El archivo creció hasta el punto en que la hoja de cálculo ya no lo abre. El archivo contiene cédula y nombre de cada infractor. El informe se publica en la página web de la entidad.

1. **Requisitos funcionales.** Formule al menos seis requisitos funcionales del sistema, redactados de forma verificable. Señale cuáles se desprenden directamente del enunciado y cuáles son supuestos suyos que habría que confirmar con la entidad.
2. **Requisitos no funcionales.** Identifique al menos tres, con su criterio de aceptación. Al menos uno debe referirse al volumen de datos.
3. **Preguntas al cliente.** Redacte cinco preguntas que le haría a la secretaría antes de empezar a construir. Una buena pregunta es la que cambia el diseño según la respuesta.
4. **Tratamiento de datos personales.** El informe se publica en internet, pero el archivo contiene cédulas y nombres. Decida qué campos deben aparecer en el informe publicado y qué debe hacerse con los demás. Justifique su decisión e impleméntela en `exportar_resumen/2`: el archivo generado no puede permitir identificar a una persona.
5. **Efectos secundarios.** Señale en su diseño exactamente en qué funciones ocurren efectos secundarios y cómo las mantuvo separadas de la lógica de cálculo. Explique qué gana su solución con esa separación.

---

## Parte F. Uso documentado de inteligencia artificial (0.3)

Si se apoyan en alguno de los asistentes del curso (el cuaderno de NotebookLM o la Gema de Google Gemini, alimentados con las guías) o en otra herramienta de IA para resolver, revisar o corregir cualquier punto del taller, documéntenlo. Esta es una versión breve de lo que se pedirá, con más detalle, en el taller siguiente.

### F.1. Bitácora

Una tabla con una fila por cada consulta relevante que le hayan hecho a la IA:

| Punto del taller | Herramienta | Qué le pidieron | Qué hicieron con la respuesta (la usaron, la corrigieron, la descartaron) |
|---|---|---|---|

### F.2. Reflexión breve

Dos o tres frases que respondan: ¿qué les aportó la IA (algo que aprendieron, corrigieron o mejoraron) y en qué se equivocó o tuvieron que ajustar?

**No usar IA es una decisión válida:** en ese caso, escriban una sola línea indicándolo. Se evalúa la honestidad, no la cantidad de uso. Deben poder explicar cualquier línea de código que entreguen, hayan usado IA o no.

---

## Entrega

Suba al aula virtual un archivo comprimido con:

- El código de las partes B, C y D, organizado en carpetas.
- El generador del archivo de prueba y una muestra de 500 líneas del archivo generado (no suba el archivo completo).
- El informe exportado por `exportar_resumen/2`.
- Un documento en PDF con las tablas de la parte A, las respuestas de B y C, las mediciones solicitadas, el análisis completo de la parte E y la bitácora y reflexión de la parte F.

## Criterios de evaluación

| Criterio | Peso |
|---|---|
| Análisis del contexto: requisitos formulados, preguntas pertinentes y decisión sobre los datos personales | 26 % |
| Pruebas de escritorio del stream y del buzón de mensajes | 18 % |
| Detección de errores en el manejo de archivos y de procesos | 12 % |
| Mediciones y argumentación en la comparación de estrategias | 14 % |
| Funcionamiento del procesador: no carga el archivo en memoria, tolera líneas inválidas y consolida correctamente | 22 % |
| Uso documentado de IA: bitácora y reflexión honestas | 8 % |
