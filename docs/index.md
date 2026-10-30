---
inicio: true
---

<div class="portada">
  <p class="portada-curso">Ingeniería de Sistemas y Computación · Universidad del Quindío</p>
  <h1>Programación III</h1>
  <p class="portada-resumen">Programación funcional, concurrente y distribuida con Elixir.</p>
</div>

Este espacio académico aborda la programación funcional usando Elixir, un lenguaje diseñado para construir aplicaciones concurrentes, escalables y fáciles de mantener a partir de los principios del paradigma funcional. Se estudian las funciones puras, la inmutabilidad, la recursión, la composición de funciones y las colecciones de datos funcionales, junto con las herramientas y prácticas con las que se desarrolla software bajo este enfoque.

{% assign bloques = site.data.guias | group_by: "bloque" %}
{% for bloque in bloques %}
<section class="bloque">
  <h2>{{ bloque.name }}</h2>
  <div class="tarjetas">
  {% for g in bloque.items %}
    {% assign p = site.pages | where: "path", g.archivo | first %}
    <a class="tarjeta" href="{{ p.url | relative_url }}">
      <span class="tarjeta-numero">{{ g.archivo | slice: 0, 2 }}</span>
      <span class="tarjeta-titulo">{{ g.titulo }}</span>
    </a>
  {% endfor %}
  </div>
</section>
{% endfor %}

{% assign proyecto = site.pages | where: "path", "0.proyecto-final.md" | first %}
<section class="bloque">
  <h2>Proyecto final</h2>
  <a class="tarjeta tarjeta-proyecto" href="{{ proyecto.url | relative_url }}">
    <span class="tarjeta-numero">PF</span>
    <span class="tarjeta-titulo">Batallas Pokémon</span>
    <span class="tarjeta-detalle">Concurrencia, distribución y persistencia en un mismo sistema</span>
  </a>
</section>
