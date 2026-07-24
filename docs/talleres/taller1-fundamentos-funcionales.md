```
Universidad del Quindío
Programa de Ingeniería de Sistemas y Computación
Programación III - Taller 1: Fundamentos funcionales
Docente: Carlos Andrés Florez V.
```

# Taller 1. Fundamentos de la programación funcional

| Campo | Información |
|---|---|
| **Núcleo temático** | 1. Fundamentos de la programación funcional |
| **Guías de referencia** | 1 a 5 (paradigmas, introducción a Elixir, programación funcional, conceptos básicos, expresiones y estructuras de control) |
| **Modalidad** | Parejas |
| **Valor** | 5.0 |
| **Entrega** | Un archivo `.exs` por cada punto de código y un documento con las respuestas escritas |

## Resultados de aprendizaje que se evalúan

| R.A. | Cómo se evalúa en este taller |
|---|---|
| **R.A.1** — Identifico los fundamentos del proceso de solución de problemas mediante la construcción de aplicaciones. | Partes A y D: seguimiento manual de la ejecución de un programa y construcción de módulos que resuelven un problema completo desde su enunciado. |
| **R.A.3** — Aplico los ejes conceptuales de la programación, con capacidad de toma de decisiones y pensamiento crítico. | Partes B y C: diagnóstico de código defectuoso y elección argumentada entre soluciones alternativas al mismo problema. |

La **Parte E** aporta a lo actitudinal del sílabo, en particular al compromiso con el aprendizaje autónomo y a la responsabilidad ética, mediante el uso documentado y reflexivo de la inteligencia artificial.

---

## Parte A. Prueba de escritorio (1.0)

Resuelva a mano, sin ejecutar el código. Al final puede verificar sus respuestas en `iex`, pero debe entregar la tabla diligenciada antes de hacerlo y señalar cualquier diferencia que encuentre.

### A.1. Reasignación e inmutabilidad (0.3)

```elixir
a = 4
b = a + 6
a = b * a
c = a - b
b = c
```

Complete la tabla con el valor de cada variable **después** de ejecutar cada línea. Use un guion cuando la variable todavía no exista.

| Línea | `a` | `b` | `c` |
|---|---|---|---|
| `a = 4` | | | |
| `b = a + 6` | | | |
| `a = b * a` | | | |
| `c = a - b` | | | |
| `b = c` | | | |

Responda además:

1. La tercera línea reasigna `a`. ¿Significa esto que Elixir permite mutar datos? Explique la diferencia entre *reasignar un nombre* y *modificar un valor*.
2. Si en la segunda línea existiera otra variable apuntando al valor original de `a`, ¿qué valor tendría al terminar el bloque? ¿Por qué?

### A.2. Encadenamiento con `with` (0.4)

```elixir
defmodule Calculadora do
  def evaluar(texto) do
    with {n, resto} <- Integer.parse(texto),
         true <- resto == "",
         true <- n != 0 do
      {:ok, div(100, n)}
    else
      :error -> {:error, :no_es_numero}
      false -> {:error, :entrada_invalida}
    end
  end
end
```

Para cada entrada, indique qué devuelve `Integer.parse/1`, en cuál de las tres cláusulas del `with` se detiene la ejecución (o si llega hasta el bloque `do`) y cuál es el resultado final.

| Entrada | `Integer.parse/1` devuelve | Cláusula donde se detiene | Resultado |
|---|---|---|---|
| `"4"` | | | |
| `"0"` | | | |
| `"abc"` | | | |
| `"12x"` | | | |
| `"-25"` | | | |

Luego explique por qué dos entradas distintas terminan produciendo el mismo error, y proponga una modificación al código para que cada caso devuelva un motivo diferente.

### A.3. Clausuras (0.3)

```elixir
crear_ajuste = fn base ->
  fn valor -> (valor + base) * 2 end
end

ajuste_10 = crear_ajuste.(10)
ajuste_0 = crear_ajuste.(0)

r1 = ajuste_10.(5)
r2 = ajuste_0.(5)
r3 = ajuste_10.(r2)
```

1. Calcule `r1`, `r2` y `r3` mostrando el reemplazo de cada parámetro.
2. `ajuste_10` y `ajuste_0` provienen de la misma función anónima. Explique qué guarda cada una y por qué producen resultados distintos con el mismo argumento.

---

## Parte B. Detección y corrección de errores (0.9)

Los cinco fragmentos siguientes tienen fallas. Para cada uno indique: **(a)** qué está mal, **(b)** si el problema aparece al compilar o al ejecutar, **(c)** con qué entrada se manifiesta, y **(d)** el código corregido.

### B.1

```elixir
defmodule calculadora_impuestos do
  def calcular(valor) do
    valor * 0.19
  end
end
```

### B.2

```elixir
defmodule Descuentos do
  def total(precio) do
    if precio > 100 do
      total = precio * 0.9
    end
    total
  end
end
```

### B.3

```elixir
defmodule Clasificador do
  def categoria(edad) do
    cond do
      edad < 12 -> :nino
      edad < 18 -> :adolescente
      edad < 65 -> :adulto
    end
  end
end
```

Pruebe con `Clasificador.categoria(70)`.

### B.4

```elixir
defmodule Acceso do
  def permitir(usuario) do
    if usuario = "admin" do
      :acceso_total
    else
      :acceso_limitado
    end
  end
end
```

Este es el más peligroso de los cinco, porque no interrumpe el programa. Explique por qué `Acceso.permitir("invitado")` devuelve `:acceso_total` y qué consecuencia tendría un error de este tipo en un sistema real.

### B.5

```elixir
"  reporte mensual  "
|> String.trim()
|> String.replace(" ", "-")
|> String.length()
|> String.upcase()
```

---

## Parte C. Comparación de soluciones (1.3)

### C.1. Tres versiones del mismo cálculo (0.7)

Un programa debe calcular el índice de masa corporal a partir del peso en kilogramos y la estatura en metros, y clasificar el resultado.

**Versión 1**

```elixir
defmodule Imc1 do
  def calcular(peso, estatura) do
    imc = peso / (estatura * estatura)
    IO.puts("El IMC es #{Float.round(imc, 2)}")

    if imc < 18.5 do
      IO.puts("Bajo peso")
    else
      if imc < 25 do
        IO.puts("Normal")
      else
        IO.puts("Sobrepeso")
      end
    end
  end
end
```

**Versión 2**

```elixir
defmodule Imc2 do
  def calcular(peso, estatura) do
    imc = peso / (estatura * estatura)
    {Float.round(imc, 2), clasificar(imc)}
  end

  defp clasificar(imc) when imc < 18.5, do: :bajo_peso
  defp clasificar(imc) when imc < 25, do: :normal
  defp clasificar(_imc), do: :sobrepeso
end
```

**Versión 3**

```elixir
defmodule Imc3 do
  def calcular(peso, estatura) do
    imc = peso / (estatura * estatura)

    categoria =
      cond do
        imc < 18.5 -> :bajo_peso
        imc < 25 -> :normal
        true -> :sobrepeso
      end

    {Float.round(imc, 2), categoria}
  end
end
```

Compare las tres versiones respondiendo:

1. ¿Cuáles funciones son puras y cuáles no? Justifique señalando el efecto secundario concreto.
2. Si necesita escribir una prueba automática que verifique que un peso de 80 kg y una estatura de 1.70 m clasifican como sobrepeso, ¿con cuál versión puede hacerlo directamente? ¿Qué le impide hacerlo con las otras?
3. Suponga que el mismo cálculo debe usarse ahora en una aplicación web, donde el resultado se envía como respuesta HTTP en lugar de imprimirse. ¿Cuáles versiones puede reutilizar sin modificar y cuáles no?
4. Entre la versión 2 y la versión 3, ¿cuál prefiere y por qué? No hay una única respuesta correcta; se evalúa el argumento, no la elección.

### C.2. ¿`if`, `cond`, `case` o cláusulas con guards? (0.6)

Para cada situación, escriba la estructura que considere más apropiada, impleméntela y justifique la elección en dos o tres líneas.

| # | Situación |
|---|---|
| 1 | Determinar si un pedido tiene envío gratis: aplica cuando el total supera $150.000. |
| 2 | Convertir un código de estado (`:pendiente`, `:enviado`, `:entregado`, `:cancelado`) en un mensaje para el usuario. |
| 3 | Calcular la tarifa de un parqueadero según los minutos: hasta 15 minutos es gratis; hasta 60 minutos cuesta $3.000; después, $3.000 más $50 por cada minuto adicional. |
| 4 | Procesar el resultado de una función que devuelve `{:ok, valor}` o `{:error, motivo}`. |

---

## Parte D. Construcción de código (1.5)

### D.1. Validador de matrícula vehicular (0.7)

Una secretaría de tránsito registra matrículas con el formato `LLLDDD`: tres letras mayúsculas seguidas de tres dígitos (por ejemplo, `ABC134`). El último dígito funciona como **dígito de verificación**: debe ser igual a la suma de los dos primeros dígitos, módulo 10.

Construya el módulo `Matricula` con la función `validar/1`, que recibe una cadena y devuelve `{:ok, :valida}` cuando la matrícula cumple **todas** las reglas, o `{:error, motivo}` con la **primera** regla incumplida en el orden en que aparecen listadas:

1. Longitud exacta de 6 caracteres → `:longitud_invalida`
2. Los tres primeros caracteres son letras mayúsculas (A–Z) → `:prefijo_invalido`
3. Los tres últimos caracteres son dígitos → `:numero_invalido`
4. El tercer dígito coincide con el dígito de verificación → `:digito_verificacion_invalido`

Requisitos:

- Cada regla debe implementarse en una función privada independiente que devuelva un valor booleano.
- La función `validar/1` debe usar `with` o `cond` para encadenar las verificaciones, sin `if` anidados.
- Documente el módulo con `@moduledoc` y la función pública con `@doc`.
- Todas las funciones deben ser puras; ninguna imprime en pantalla.
- Agregue una función `reporte/1` que reciba una lista de matrículas y las imprima con su resultado. Esta es la única función del módulo con efectos secundarios.

Verifique con: `"ABC"`, `"abc123"`, `"ABCX23"`, `"ABC135"` y `"ABC134"`. Indique en un comentario qué motivo devuelve cada una y por qué.

### D.2. Liquidación de horas extra (0.8)

Una empresa liquida el pago semanal de sus operarios con estas reglas:

- Las primeras 40 horas se pagan a la tarifa base por hora.
- Entre la hora 41 y la 48 se paga la tarifa base con un recargo del 25 %.
- A partir de la hora 49 el recargo es del 75 %.
- Si el operario trabajó más de 60 horas en la semana, la liquidación no se procesa y se devuelve un error, porque supera el máximo legal.
- Sobre el total se descuenta un 8 % de aportes.

Construya el módulo `Nomina` con:

- `liquidar/2`, que recibe las horas trabajadas y la tarifa base, y devuelve `{:ok, detalle}` o `{:error, :excede_maximo_legal}`. El detalle debe ser una tupla o un mapa con el valor de las horas ordinarias, el de cada tipo de hora extra, el subtotal, el descuento y el neto a pagar.
- Al menos una función auxiliar privada por cada tipo de hora.
- Un pipeline con `|>` en alguna parte de la solución.
- Una función `imprimir/2` que muestre el desprendible de pago con formato legible.

Pruebe con: `(38, 7000)`, `(45, 7000)`, `(55, 7000)` y `(62, 7000)`. Incluya en la entrega la salida obtenida en cada caso.

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

- Los archivos `.exs` de las partes B (versiones corregidas) y D.
- Un documento en PDF con las tablas de la parte A, las respuestas escritas de B y C, las justificaciones de D y la bitácora y reflexión de la parte E.
- El nombre completo de los dos integrantes en el encabezado del documento y en un comentario al inicio de cada archivo de código.

## Criterios de evaluación

| Criterio | Peso |
|---|---|
| Corrección de las pruebas de escritorio y calidad de la explicación | 20 % |
| Diagnóstico acertado de los errores, con distinción entre fallas de compilación y de ejecución | 18 % |
| Argumentación técnica en la comparación de soluciones, más allá de la preferencia personal | 24 % |
| Funcionamiento del código construido frente a los casos de prueba indicados | 20 % |
| Nomenclatura, documentación y organización del código según las convenciones de la guía 4 | 10 % |
| Uso documentado de IA: bitácora y reflexión honestas | 8 % |
