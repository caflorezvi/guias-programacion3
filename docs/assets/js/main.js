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