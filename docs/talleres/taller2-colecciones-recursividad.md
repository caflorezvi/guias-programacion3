```
Universidad del Quindío
Programa de Ingeniería de Sistemas y Computación
Programación III - Taller 2: Colecciones y recursividad
Docente: Carlos Andrés Florez V.
```

# Taller 2. Manejo de datos y estructuras funcionales

| Campo | Información |
|---|---|
| **Núcleo temático** | 2. Manejo de datos y estructuras funcionales |
| **Guías de referencia** | 7 a 9 (colecciones, recursividad, structs) |
| **Modalidad** | Parejas |
| **Valor** | 5.0 |
| **Entrega** | Archivos `.exs` por punto de código y un documento con las respuestas escritas |

## Resultados de aprendizaje que se evalúan

| R.A. | Cómo se evalúa en este taller |
|---|---|
| **R.A.1** — Identifico los fundamentos del proceso de solución de problemas mediante la construcción de aplicaciones. | Partes A y D: seguimiento de la pila de llamadas de un algoritmo recursivo y construcción de un sistema de historias clínicas completo a partir de su especificación. |
| **R.A.3** — Aplico los ejes conceptuales de la programación, con capacidad de toma de decisiones y pensamiento crítico. | Partes B y C: corrección de algoritmos defectuosos y selección justificada de la estructura de datos y de la estrategia de recorrido según el caso. |

La **Parte E** aporta a lo actitudinal del sílabo, en particular al compromiso con el aprendizaje autónomo y a la responsabilidad ética, mediante el uso documentado y reflexivo de la inteligencia artificial.

---

## Parte A. Prueba de escritorio (1.2)

Resuelva a mano. Puede verificar después en `iex`, pero entregue primero sus tablas.

### A.1. Recorrido con `reduce` (0.4)

```elixir
Enum.reduce([3, 8, 2, 9, 5], {0, 0}, fn x, {suma, max} ->
  {suma + x, if(x > max, do: x, else: max)}
end)
```

| Iteración | `x` | Acumulador que entra | Acumulador que sale |
|---|---|---|---|
| 1 | 3 | `{0, 0}` | |
| 2 | | | |
| 3 | | | |
| 4 | | | |
| 5 | | | |

1. ¿Cuál es el resultado final?
2. ¿Qué pasaría si la lista contuviera solo números negativos? Corrija el valor inicial del acumulador para que el máximo sea correcto en ese caso.
3. Reescriba el mismo cálculo usando dos recorridos separados (`Enum.sum/1` y `Enum.max/1`). ¿Qué gana y qué pierde frente a la versión con `reduce`?

### A.2. Pila de llamadas de una función recursiva (0.5)

El máximo común divisor de dos números puede calcularse por restas sucesivas; se le resta el menor al mayor hasta que ambos sean iguales, y ese valor es el resultado.

```elixir
defmodule Euclides do
  def mcd(a, b) when a == b, do: a
  def mcd(a, b) when a > b, do: mcd(a - b, b)
  def mcd(a, b), do: mcd(a, b - a)
end
```

Para `Euclides.mcd(48, 18)`:

1. Escriba la secuencia completa de llamadas, una por línea, indicando en cada paso cuál cláusula se aplica, hasta llegar al caso base.
2. ¿Cuál es el resultado?
3. Esta función es de recursión de cola. Explique por qué, y por qué eso significa que la cantidad de marcos apilados no crece con el número de restas.
4. ¿Cuántas restas se hacen para `mcd(48, 18)`? Compare con el algoritmo de Euclides por división (`mcd(a, b) = mcd(b, rem(a, b))`): ¿cuántos pasos tomaría? Escriba esa versión.
5. ¿Qué ocurre con `Euclides.mcd(6, 0)` y con `Euclides.mcd(-4, 8)`? Corrija la función para que ambos casos estén contemplados.

### A.3. Pipeline paso a paso (0.3)

```elixir
["elixir", "es", "funcional", "y", "concurrente"]
|> Enum.filter(fn p -> String.length(p) > 2 end)
|> Enum.map(&String.upcase/1)
|> Enum.reduce("", fn p, acc -> acc <> String.first(p) end)
```

Escriba el valor intermedio que sale de cada etapa del pipeline y el resultado final. Luego indique cuántas listas intermedias se construyeron en memoria para obtenerlo.

---

## Parte B. Detección y corrección de errores (0.9)

Para cada fragmento indique **(a)** qué está mal, **(b)** si falla al compilar, si falla al ejecutar o si devuelve un resultado incorrecto sin avisar, **(c)** el caso de prueba que lo evidencia, y **(d)** la corrección.

### B.1

```elixir
defmodule Suma do
  def total(lista) when is_list(lista), do: hd(lista) + total(tl(lista))
  def total([]), do: 0
end
```

Al compilar aparece una advertencia. Léala, explíquela con sus palabras y corrija la causa.

### B.2

```elixir
defmodule Utilidades do
  def invertir(lista), do: invertir(lista, [])

  defp invertir([], acc), do: acc
  defp invertir([cabeza | cola], acc), do: invertir(cola, acc ++ [cabeza])
end
```

`Utilidades.invertir([1, 2, 3])` devuelve `[1, 2, 3]`. Este es el caso más difícil de detectar del taller, porque el código compila sin advertencias y la función parece razonable. Explique por qué el acumulador no invierte nada y corríjalo cambiando una sola expresión.

### B.3

```elixir
defmodule Precios do
  def aplicar_iva(productos) do
    Enum.map(productos, fn p -> %{p | precio: p.precio * 1.19} end)
    productos
  end
end
```

### B.4

```elixir
defmodule Usuario do
  defstruct [:nombre, :edad]
end

defmodule Registro do
  def agregar_telefono(usuario, telefono) do
    %{usuario | telefono: telefono}
  end
end
```

Además de corregirlo, responda: si en lugar de la sintaxis de actualización se usara `Map.put(usuario, :telefono, telefono)`, el código no falla. Ejecútelo, observe el resultado con `IO.inspect/1` y explique por qué esa alternativa es peor que el error original.

### B.5

```elixir
defmodule Estadisticas do
  def promedio([cabeza | cola]) do
    (cabeza + suma(cola)) / (1 + length(cola))
  end

  defp suma([]), do: 0
  defp suma([cabeza | cola]), do: cabeza + suma(cola)
end
```

---

## Parte C. Comparación de soluciones (1.3)

### C.1. Tres formas de recorrer una lista (0.6)

El problema es sumar los cuadrados de los números pares de una lista.

**Versión A — recursión no optimizada**

```elixir
def sumar([]), do: 0
def sumar([h | t]) when rem(h, 2) == 0, do: h * h + sumar(t)
def sumar([_h | t]), do: sumar(t)
```

**Versión B — recursión de cola**

```elixir
def sumar(lista), do: sumar(lista, 0)

defp sumar([], acc), do: acc
defp sumar([h | t], acc) when rem(h, 2) == 0, do: sumar(t, acc + h * h)
defp sumar([_h | t], acc), do: sumar(t, acc)
```

**Versión C — pipeline con `Enum`**

```elixir
def sumar(lista) do
  lista
  |> Enum.filter(&(rem(&1, 2) == 0))
  |> Enum.map(&(&1 * &1))
  |> Enum.sum()
end
```

1. Ejecute las tres con `Enum.to_list(1..1_000_000)` y mida el tiempo con `:timer.tc/1`. Reporte los resultados.
2. ¿Cuál usa más memoria de pila y por qué? ¿Cuál construye más estructuras intermedias?
3. Reescriba la versión C con `Enum.reduce/3` en un solo recorrido. ¿Mejora el tiempo? ¿Empeora la legibilidad?
4. Si usted fuera el líder técnico del proyecto, ¿cuál versión aceptaría en una revisión de código? Justifique considerando legibilidad, rendimiento y quién va a mantener ese código.

### C.2. El costo de un operador (0.4)

Estas dos implementaciones de `map` son correctas y producen el mismo resultado:

```elixir
# Implementación 1
defp map([], _f, acc), do: acc
defp map([h | t], f, acc), do: map(t, f, acc ++ [f.(h)])

# Implementación 2
defp map([], _f, acc), do: Enum.reverse(acc)
defp map([h | t], f, acc), do: map(t, f, [f.(h) | acc])
```

1. Mida ambas con listas de 1.000, 10.000 y 50.000 elementos. Presente los tiempos en una tabla.
2. Los tiempos no crecen igual. Explique por qué, apoyándose en cómo está construida una lista enlazada en Elixir y en qué debe hacer `++` para agregar al final.
3. La implementación 2 recorre la lista una segunda vez al invertirla. Aun así es más rápida. Explique esta aparente contradicción.

### C.3. Elegir la estructura adecuada (0.3)

Para cada escenario indique qué colección usaría (lista, tupla, mapa, *keyword list* o struct) y justifique en dos líneas.

| # | Escenario |
|---|---|
| 1 | Consultar los datos de un paciente a partir de su número de cédula, en un conjunto de 50.000 registros. |
| 2 | Devolver el resultado de una operación que puede tener éxito o fallar. |
| 3 | Representar las coordenadas de un punto en un plano. |
| 4 | Pasar opciones de configuración a una función, permitiendo claves repetidas y orden definido. |
| 5 | Representar un vehículo con placa, modelo, color y kilometraje, garantizando que ningún registro quede sin placa. |
| 6 | Acumular los eventos de un log a medida que llegan, agregando siempre al inicio. |

---

## Parte D. Construcción de código (1.3)

### D.1. Historias clínicas de una veterinaria con structs y `Enum` (0.7)

Construya el módulo `Consulta` con un struct que tenga `id`, `mascota`, `especie`, `motivo`, `costo` y `pagada` (booleano). `id` y `mascota` deben ser obligatorios mediante `@enforce_keys`.

Construya el módulo `Historial` con las siguientes funciones, todas puras y todas implementadas con el módulo `Enum`:

| Función | Comportamiento |
|---|---|
| `ingresos_totales/1` | Suma de los costos de todas las consultas. |
| `pendientes_de_pago/1` | Lista de consultas cuyo campo `pagada` es `false`. |
| `por_especie/1` | Mapa donde la clave es la especie y el valor la lista de consultas de esa especie. |
| `mas_costosa/1` | Consulta de mayor costo, o `nil` si no hay consultas. |
| `aplicar_recargo/3` | Recibe el historial, una especie y un porcentaje; devuelve un historial nuevo con el costo ajustado solo en esa especie. |
| `resumen/1` | Tupla o mapa con el número de consultas, los ingresos totales y la cantidad de consultas pendientes de pago. |

Incluya al menos un pipeline y una función que use `Enum.reduce/3`. Demuestre con `IO.inspect/1` que el historial original no cambia después de llamar `aplicar_recargo/3`.

### D.2. Las mismas operaciones, sin `Enum` (0.6)

Reimplemente, usando exclusivamente recursividad y coincidencia de patrones, estas cuatro funciones sobre la lista de consultas del punto anterior:

- `contar/1`
- `ingresos_totales/1`
- `filtrar_por_especie/2`
- `mas_costosa/1`

Reglas:

- Ninguna función del módulo `Enum` ni `length/1`.
- Al menos dos de las cuatro deben ser de recursión de cola. Indique cuáles y por qué eligió esas.
- Cada función debe manejar la lista vacía de forma explícita.

Al final escriba un párrafo comparando esta implementación con la del punto D.1: qué se entiende mejor, qué se escribe más rápido y en qué situaciones tendría sentido escribir la versión recursiva a mano.

---

## Parte E. Uso documentado de inteligencia artificial (0.3)

Si se apoyan en alguno de los asistentes del curso (el cuaderno de NotebookLM o la Gema de Google Gemini, alimentados con las guías) o en otra herramienta de IA para resolver, revisar o corregir cualquier punto del taller, documéntenlo. Esta es una versión breve de lo que se pedirá, con más detalle, en los talleres siguientes.

### E.1. Bitácora

Una tabla con una fila por cada consulta relevante que le hayan hecho a la IA:

| Punto del taller | Herramienta | Qué le pidieron | Qué hicieron con la respuesta (la usaron, la corrigieron, la descartaron) |
|---|---|---|---|

### E.2. Reflexión breve

Dos o tres frases que respondan: ¿qué les aportó la IA (algo que aprendieron, corrigieron o mejoraron) y en qué se equivocó o tuvieron que ajustar?

**No usar IA es una decisión válida:** en ese caso, escriban una sola línea indicándolo. Se evalúa la honestidad, no la cantidad de uso. Deben poder explicar cualquier línea de código que entreguen, hayan usado IA o no.

---

## Entrega

Suba al aula virtual un archivo comprimido con:

- Los archivos `.exs` de las partes B, C y D.
- Un documento en PDF con las tablas de la parte A, las respuestas de B, las mediciones y argumentos de C, el párrafo final de D.2 y la bitácora y reflexión de la parte E.
- Nombre de los integrantes en el documento y en un comentario al inicio de cada archivo.

## Criterios de evaluación

| Criterio | Peso |
|---|---|
| Exactitud de las pruebas de escritorio, en especial el manejo de la pila de llamadas | 24 % |
| Detección de los errores, incluyendo los que no interrumpen la ejecución | 18 % |
| Mediciones reportadas y explicación del comportamiento observado | 18 % |
| Funcionamiento correcto del historial y respeto de las restricciones de D.2 | 22 % |
| Documentación, nombres y organización del código | 10 % |
| Uso documentado de IA: bitácora y reflexión honestas | 8 % |
