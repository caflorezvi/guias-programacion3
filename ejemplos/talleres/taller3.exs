# ============================================================================
# Módulo Vocales
# ============================================================================
# Cuenta las vocales de una cadena usando dos estrategias recursivas.
#
# --- contar_vocales_grap("carlos andres") ---
# Primero convierte la cadena en grafemas (lista de caracteres):
#   ["c","a","r","l","o","s"," ","a","n","d","r","e","s"]
# Luego llama a contar/2 que recorre la lista con un acumulador:
#   contar(["c","a","r","l","o","s"," ","a","n","d","r","e","s"], 0)
#   contar(["a","r","l","o","s"," ","a","n","d","r","e","s"], 0)  -> "c" no es vocal
#   contar(["r","l","o","s"," ","a","n","d","r","e","s"], 1)      -> "a" es vocal
#   contar(["l","o","s"," ","a","n","d","r","e","s"], 1)          -> "r" no es vocal
#   contar(["o","s"," ","a","n","d","r","e","s"], 1)              -> "l" no es vocal
#   contar(["s"," ","a","n","d","r","e","s"], 2)                  -> "o" es vocal
#   contar([" ","a","n","d","r","e","s"], 2)                      -> "s" no es vocal
#   contar(["a","n","d","r","e","s"], 2)                          -> " " no es vocal
#   contar(["n","d","r","e","s"], 3)                              -> "a" es vocal
#   contar(["d","r","e","s"], 3)                                  -> "n" no es vocal
#   contar(["r","e","s"], 3)                                      -> "d" no es vocal
#   contar(["e","s"], 3)                                          -> "r" no es vocal
#   contar(["s"], 4)                                              -> "e" es vocal
#   contar([], 4)                                                 -> "s" no es vocal
#   -> Retorna 4 (recursión de cola, acumulador lleva el resultado)
#
# --- contar_vocales("carlos andres") ---
# Recorre la cadena extrayendo el primer carácter en cada llamado:
#   contar_vocales("carlos andres")
#     "c" no es vocal -> 0 + contar_vocales("arlos andres")
#       "a" es vocal  -> 1 + contar_vocales("rlos andres")
#         "r" no es vocal -> 0 + contar_vocales("los andres")
#           "l" no es vocal -> 0 + contar_vocales("os andres")
#             "o" es vocal  -> 1 + contar_vocales("s andres")
#               "s" no es vocal -> 0 + contar_vocales(" andres")
#                 " " no es vocal -> 0 + contar_vocales("andres")
#                   "a" es vocal  -> 1 + contar_vocales("ndres")
#                     "n" no es vocal -> 0 + contar_vocales("dres")
#                       "d" no es vocal -> 0 + contar_vocales("res")
#                         "r" no es vocal -> 0 + contar_vocales("es")
#                           "e" es vocal  -> 1 + contar_vocales("s")
#                             "s" no es vocal -> 0 + contar_vocales("")
#                               contar_vocales("") -> 0
#   Se resuelve de adentro hacia afuera: 0+0+1+0+0+0+1+0+0+1+0+1+0 = 4
#   (NO es recursión de cola: cada llamado espera el resultado del siguiente)
# ============================================================================
defmodule Vocales do
  def main do
    cadena = "carlos andres"
    IO.puts(contar_vocales_grap(cadena))
    IO.puts(contar_vocales(cadena))
  end

  def contar_vocales_grap(cadena) do
    cadena
    |> String.graphemes()
    |> contar(0)
  end

  defp contar([], contador), do: contador

  defp contar([head | tail], contador) do
    case es_vocal?(head) do
      true -> contar(tail, contador + 1)
      _ -> contar(tail, contador)
    end
  end

  def contar_vocales(""), do: 0

  def contar_vocales(cadena) do
    inicio = String.first(cadena)
    resto = String.slice(cadena, 1..-1//1)

    case es_vocal?(inicio) do
      true -> 1 + contar_vocales(resto)
      _ -> contar_vocales(resto)
    end
  end

  defp es_vocal?(letra) when letra in ["a", "e", "i", "o", "u"], do: true
  defp es_vocal?(_letra), do: false
end

# ============================================================================
# Módulo Potencia
# ============================================================================
# Determina si un número n es potencia de una base b.
# Divide n entre b repetidamente hasta llegar a 1 (es potencia) o hasta que
# la división no sea exacta (no es potencia).
#
# --- es_potencia?(64, 4) ---
#   es_potencia?(64, 4)  -> rem(64, 4) == 0, entonces: es_potencia?(div(64,4), 4)
#   es_potencia?(16, 4)  -> rem(16, 4) == 0, entonces: es_potencia?(div(16,4), 4)
#   es_potencia?(4, 4)   -> rem(4, 4) == 0,  entonces: es_potencia?(div(4,4), 4)
#   es_potencia?(1, 4)   -> coincide con cláusula es_potencia?(1, _b) -> true
#   Retorna true (recursión de cola: 64 = 4^3)
# ============================================================================
defmodule Potencia do
  def main do
    IO.puts(es_potencia?(64, 4))
  end

  def es_potencia?(1, _b), do: true
  def es_potencia?(n, 1), do: n == 1
  def es_potencia?(n, b) when rem(n, b) != 0, do: false
  def es_potencia?(n, b), do: es_potencia?(div(n, b), b)
end

# ============================================================================
# Módulo Perfecto
# ============================================================================
# Un número perfecto es aquel cuya suma de divisores propios es igual a sí mismo.
# Usa sumar_divisores/3 con un acumulador para recorrer los posibles divisores
# desde 1 hasta n/2.
#
# --- es_perfecto?(26) ---
#   es_perfecto?(26) -> 26 > 1, entonces: sumar_divisores(26, 1, 0) == 26 ?
#
#   sumar_divisores(26, 1, 0)   -> rem(26,1)==0  -> sumar_divisores(26, 2, 0+1)
#   sumar_divisores(26, 2, 1)   -> rem(26,2)==0  -> sumar_divisores(26, 3, 1+2)
#   sumar_divisores(26, 3, 3)   -> rem(26,3)!=0  -> sumar_divisores(26, 4, 3)
#   sumar_divisores(26, 4, 3)   -> rem(26,4)!=0  -> sumar_divisores(26, 5, 3)
#   sumar_divisores(26, 5, 3)   -> rem(26,5)!=0  -> sumar_divisores(26, 6, 3)
#   sumar_divisores(26, 6, 3)   -> rem(26,6)!=0  -> sumar_divisores(26, 7, 3)
#   sumar_divisores(26, 7, 3)   -> rem(26,7)!=0  -> sumar_divisores(26, 8, 3)
#   sumar_divisores(26, 8, 3)   -> rem(26,8)!=0  -> sumar_divisores(26, 9, 3)
#   sumar_divisores(26, 9, 3)   -> rem(26,9)!=0  -> sumar_divisores(26, 10, 3)
#   sumar_divisores(26, 10, 3)  -> rem(26,10)!=0 -> sumar_divisores(26, 11, 3)
#   sumar_divisores(26, 11, 3)  -> rem(26,11)!=0 -> sumar_divisores(26, 12, 3)
#   sumar_divisores(26, 12, 3)  -> rem(26,12)!=0 -> sumar_divisores(26, 13, 3)
#   sumar_divisores(26, 13, 3)  -> rem(26,13)==0 -> sumar_divisores(26, 14, 3+13)
#   sumar_divisores(26, 14, 16) -> 14 > div(26,2)=13 -> retorna acc = 16
#
#   16 != 26, entonces retorna false (26 no es perfecto)
#   (Ejemplo de número perfecto: 6 -> divisores: 1+2+3 = 6)
#   (Recursión de cola gracias al acumulador acc)
# ============================================================================
defmodule Perfecto do
  def main do
    IO.puts(es_perfecto?(26))
  end

  def es_perfecto?(n) when n <= 1, do: false
  def es_perfecto?(n), do: sumar_divisores(n, 1, 0) == n

  defp sumar_divisores(n, d, acc) when d > div(n, 2), do: acc
  defp sumar_divisores(n, d, acc) when rem(n, d) == 0, do: sumar_divisores(n, d + 1, acc + d)
  defp sumar_divisores(n, d, acc), do: sumar_divisores(n, d + 1, acc)
end

# ============================================================================
# Módulo CadenaMasLarga
# ============================================================================
# Encuentra la cadena más larga de una lista recorriéndola recursivamente
# con un acumulador que guarda la cadena más larga encontrada hasta el momento.
#
# --- obtener_cadena_larga(["carlos", "televisor", "telefono", "bicicletas"]) ---
#   obtener_cadena_larga(["carlos", "televisor", "telefono", "bicicletas"])
#     -> head="carlos", tail=["televisor","telefono","bicicletas"]
#     -> obtener_cadena_larga(["televisor","telefono","bicicletas"], "carlos")
#
#   obtener_cadena_larga(["televisor","telefono","bicicletas"], "carlos")
#     -> "televisor"(9) > "carlos"(6)? Sí
#     -> obtener_cadena_larga(["telefono","bicicletas"], "televisor")
#
#   obtener_cadena_larga(["telefono","bicicletas"], "televisor")
#     -> "telefono"(8) > "televisor"(9)? No
#     -> obtener_cadena_larga(["bicicletas"], "televisor")
#
#   obtener_cadena_larga(["bicicletas"], "televisor")
#     -> "bicicletas"(10) > "televisor"(9)? Sí
#     -> obtener_cadena_larga([], "bicicletas")
#
#   obtener_cadena_larga([], "bicicletas") -> retorna "bicicletas"
#   (Recursión de cola: el acumulador mas_larga lleva el resultado)
# ============================================================================
defmodule CadenaMasLarga do
  def main do
    IO.puts(obtener_cadena_larga(["carlos", "televisor", "telefono", "bicicletas"]))
  end

  def obtener_cadena_larga([]), do: ""
  def obtener_cadena_larga([head | tail]), do: obtener_cadena_larga(tail, head)

  defp obtener_cadena_larga([], mas_larga), do: mas_larga

  defp obtener_cadena_larga([head | tail], mas_larga) do
    if String.length(head) > String.length(mas_larga) do
      obtener_cadena_larga(tail, head)
    else
      obtener_cadena_larga(tail, mas_larga)
    end
  end
end

# ============================================================================
# Módulo NumeroReversible
# ============================================================================
# Un número es reversible si al sumarlo con su reverso, todos los dígitos
# del resultado son impares. Usa dos funciones recursivas: invertir/2 y
# validar_impar/1.
#
# --- es_reversible?(10) ---
#   es_reversible?(10)
#     -> rem(10, 10) == 0 (termina en 0) -> retorna false
#   (El guard detecta que un número terminado en 0 no puede ser reversible,
#    ya que su reverso empezaría con 0 y no sería un número válido)
#
# --- Ejemplo adicional con es_reversible?(36) para ver la recursión completa ---
#   es_reversible?(36) -> no cae en el guard, entonces:
#
#   Paso 1: invertir(36, 0)  — invierte los dígitos de 36
#     invertir(36, 0)  -> invertir(div(36,10), 0*10 + rem(36,10))
#     invertir(3, 6)   -> invertir(div(3,10), 6*10 + rem(3,10))
#     invertir(0, 63)  -> retorna 63
#
#   Paso 2: suma = 36 + 63 = 99
#
#   Paso 3: validar_impar(99) — verifica que todos los dígitos sean impares
#     validar_impar(99) -> rem(99,10)=9, 9 es impar -> validar_impar(div(99,10))
#     validar_impar(9)  -> rem(9,10)=9, 9 es impar  -> validar_impar(div(9,10))
#     validar_impar(0)  -> retorna true
#   Retorna true (36 es reversible)
#   (Ambas funciones internas usan recursión de cola con acumulador)
# ============================================================================
defmodule NumeroReversible do
  def main do
    IO.puts(es_reversible?(10))
  end

  def es_reversible?(num) when num < 0 or rem(num, 10) == 0, do: false

  def es_reversible?(num) do
    suma = num + invertir(num, 0)
    validar_impar(suma)
  end

  defp invertir(0, acc), do: acc
  defp invertir(num, acc), do: invertir(div(num, 10), acc * 10 + rem(num, 10))

  defp validar_impar(0), do: true

  defp validar_impar(num) do
    digito = rem(num, 10)

    if rem(digito, 2) != 0 do
      validar_impar(div(num, 10))
    else
      false
    end
  end
end

Potencia.main()
