// ============================================
// Toggle de tema claro/oscuro
// ============================================
(function() {
  const toggle = document.getElementById('theme-toggle');
  if (!toggle) return;

  toggle.addEventListener('click', () => {
    const current = document.documentElement.getAttribute('data-theme');
    const next = current === 'dark' ? 'light' : 'dark';
    document.documentElement.setAttribute('data-theme', next);
    localStorage.setItem('theme', next);
  });
})();

// ============================================
// Botón de copiar en bloques de código
// ============================================
(function() {
  const copyIcon = `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>`;
  const checkIcon = `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>`;

  // Selecciona bloques de código (tanto los envueltos en .highlight como pre sueltos)
  const blocks = document.querySelectorAll('.highlight, .content pre');

  blocks.forEach(block => {
    // Evitar duplicados si el pre está dentro de .highlight
    if (block.tagName === 'PRE' && block.parentElement.classList.contains('highlight')) {
      return;
    }

    // Asegurar posición relativa para el botón absoluto
    if (getComputedStyle(block).position === 'static') {
      block.style.position = 'relative';
    }

    const button = document.createElement('button');
    button.className = 'copy-button';
    button.innerHTML = `${copyIcon}<span>Copiar</span>`;
    button.setAttribute('aria-label', 'Copiar código');

    button.addEventListener('click', async () => {
      const code = block.querySelector('code') || block;
      const text = code.innerText;

      try {
        await navigator.clipboard.writeText(text);
        button.innerHTML = `${checkIcon}<span>Copiado</span>`;
        button.classList.add('copied');
        setTimeout(() => {
          button.innerHTML = `${copyIcon}<span>Copiar</span>`;
          button.classList.remove('copied');
        }, 2000);
      } catch (err) {
        console.error('Error al copiar:', err);
      }
    });

    block.appendChild(button);
  });
})();

// ============================================
// Píldora "Reto" en los títulos que terminan en "(reto)"
// ============================================
(function() {
  document.querySelectorAll('.content h3, .content h4').forEach(h => {
    if (!/\(reto\)\s*$/i.test(h.textContent)) return;
    h.innerHTML = h.innerHTML.replace(/\s*\(reto\)\s*$/i, '');
    const marca = document.createElement('span');
    marca.className = 'marca-reto';
    marca.textContent = 'Reto';
    h.appendChild(marca);
  });
})();

// ============================================
// Palabras clave de Elixir que Rouge marca como nombres comunes
// ============================================
(function() {
  const claves = new Set(['with', 'for', 'alias']);
  document.querySelectorAll('.language-elixir .highlight .n').forEach(span => {
    if (claves.has(span.textContent)) span.className = 'k';
  });
})();

// ============================================
// Interpolación #{...} dentro de heredocs (""") de Elixir
// Rouge marca todo el heredoc como un solo token (.sd) y no resalta #{...}.
// Aquí se separan "#{" y "}" con la clase .si, igual que en las cadenas normales.
// ============================================
(function() {
  // Busca el cierre de una interpolación respetando llaves anidadas: #{inspect(%{a: 1})}
  function cierre(texto, desde) {
    let nivel = 1;
    for (let i = desde; i < texto.length; i++) {
      if (texto[i] === '{') nivel++;
      else if (texto[i] === '}' && --nivel === 0) return i;
    }
    return -1;
  }

  function span(clase, texto) {
    const s = document.createElement('span');
    if (clase) s.className = clase;
    s.textContent = texto;
    return s;
  }

  document.querySelectorAll('.language-elixir .highlight .sd').forEach(sd => {
    const texto = sd.textContent;
    if (!texto.includes('#{')) return;

    // Los sigilos en mayúscula (~S""") no interpolan
    const previo = sd.previousElementSibling;
    if (/^~[A-Z]/.test(texto) || (previo && /^~[A-Z]/.test(previo.textContent))) return;

    const partes = document.createDocumentFragment();
    let inicio = 0;
    let i = texto.indexOf('#{');

    while (i !== -1) {
      const fin = cierre(texto, i + 2);
      if (fin === -1) break;
      // \#{ es un escape: se deja como texto
      if (texto[i - 1] === '\\') { i = texto.indexOf('#{', i + 2); continue; }

      partes.appendChild(span('sd', texto.slice(inicio, i)));
      partes.appendChild(span('si', '#{'));
      partes.appendChild(span('', texto.slice(i + 2, fin)));
      partes.appendChild(span('si', '}'));
      inicio = fin + 1;
      i = texto.indexOf('#{', inicio);
    }

    if (inicio === 0) return;
    partes.appendChild(span('sd', texto.slice(inicio)));
    sd.replaceWith(partes);
  });
})();

// ============================================
// Bloques especiales de las guías
// Se reconocen por su texto, así las guías .md no cambian.
// ============================================
(function() {
  const contenido = document.querySelector('.content');
  if (!contenido) return;

  // Texto de la etiqueta en negrita o cursiva con que abre un párrafo
  function etiqueta(p) {
    const primero = p.firstElementChild;
    if (!primero || !/^(STRONG|EM)$/.test(primero.tagName)) return '';
    if (p.firstChild !== primero && p.firstChild.textContent.trim() !== '') return '';
    return primero.textContent.trim();
  }

  // 1. Citas (>): las de "Nota", "Sugerencia" y "Buena práctica" pasan a azul
  contenido.querySelectorAll('blockquote').forEach(cita => {
    const p = cita.querySelector('p');
    if (!p) return;
    if (/^(⚠️|💡)?\s*(Nota|Sugerencia|Buena práctica)\b/.test(p.textContent.trim())) {
      cita.classList.add('aviso-nota');
      // Quita el ⚠️ inicial, que en una nota no corresponde
      const walker = document.createTreeWalker(p, NodeFilter.SHOW_TEXT);
      let nodo;
      while ((nodo = walker.nextNode())) {
        if (nodo.textContent.trim() === '') continue;
        nodo.textContent = nodo.textContent.replace(/^\s*⚠️\s*/, '');
        break;
      }
    }
  });

  // 2. "Nuevo requerimiento:" y 3. "El problema de esta versión."
  contenido.querySelectorAll('p').forEach(p => {
    const texto = etiqueta(p);
    let clase = '';
    if (/^Nuevo requerimiento:?$/i.test(texto)) clase = 'requerimiento';
    else if (/^El problema de esta versión\.?$/i.test(texto)) clase = 'problema';
    if (!clase) return;
    p.classList.add(clase);
    const marca = p.firstElementChild;
    marca.classList.add('bloque-marca');
    marca.textContent = texto.replace(/[:.]$/, '');
    // La etiqueta queda en su propia línea: el texto que sigue empieza en mayúscula
    const resto = marca.nextSibling;
    if (resto && resto.nodeType === Node.TEXT_NODE) {
      resto.textContent = resto.textContent.replace(/^\s*(\S)/, (_, c) => c.toUpperCase());
    }
  });

  // 4. Pistas plegables: "*Pista:* texto" o "**Pistas:**" seguido de una lista
  contenido.querySelectorAll('p').forEach(p => {
    let texto = etiqueta(p);
    const plano = !texto && p.firstChild && p.firstChild.nodeType === Node.TEXT_NODE &&
                  /^\s*Pistas?:/.test(p.firstChild.textContent);
    if (plano) {
      texto = p.firstChild.textContent.match(/Pistas?:/)[0];
      p.firstChild.textContent = p.firstChild.textContent.replace(/^\s*Pistas?:/, '');
    } else if (!/^Pistas?:?$/i.test(texto)) return;

    const detalles = document.createElement('details');
    detalles.className = 'pista';
    const resumen = document.createElement('summary');
    resumen.textContent = texto.replace(/:$/, '');
    detalles.appendChild(resumen);
    const cuerpo = document.createElement('div');
    detalles.appendChild(cuerpo);

    if (!plano) p.firstElementChild.remove();
    const resto = p.innerHTML.replace(/^\s+/, '');
    p.before(detalles);
    if (resto.trim() !== '') {
      p.innerHTML = resto.charAt(0).toUpperCase() + resto.slice(1);
      cuerpo.appendChild(p);
    } else {
      p.remove();
    }
    const siguiente = detalles.nextElementSibling;
    if (siguiente && /^(UL|OL)$/.test(siguiente.tagName)) cuerpo.appendChild(siguiente);
  });

  // 5. Bloques de código sin lenguaje: salida de consola o traza
  // GitHub Pages los envuelve en div.language-plaintext; sin envoltorio quedan como <pre> suelto
  contenido.querySelectorAll('pre').forEach(pre => {
    const envoltorio = pre.closest('div.language-plaintext, div.language-text');
    const enCodigo = pre.closest('.highlighter-rouge, .highlight');
    if (!envoltorio && enCodigo) return; // tiene lenguaje (elixir, bash...)
    const bloque = envoltorio || pre;
    const previo = bloque.previousElementSibling;
    if (!previo) return;
    const texto = previo.textContent.trim();
    if (/^Traza/i.test(texto)) {
      pre.classList.add('bloque-traza');
    } else if (previo.matches('.bloque-consola') || previo.querySelector('pre.bloque-consola') ||
               /(salida|ejecut|debería ver|resultado|con datos|con una|con notas|con cuatro|si la|una división|y una|y con|ahora pruebe)[^.]*:$/i.test(texto)) {
      pre.classList.add('bloque-consola');
    }
  });
})();
