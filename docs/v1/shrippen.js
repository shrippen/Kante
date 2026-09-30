/* Kante v1 — language switch, nav brand reveal, copy button, motion.
 * Load synchronously in <head> so the stored language applies before first paint.
 * Motion (entrances, counters, typing, sliding tabs, scroll meter) only runs when
 * the reader has not asked for reduced motion; html.motion marks that. */
(function () {
  var d = document, h = d.documentElement, KEY = 'shrippen-lang';
  h.classList.add('js');
  var still = window.matchMedia && matchMedia('(prefers-reduced-motion: reduce)').matches;
  if (!still && 'IntersectionObserver' in window) h.classList.add('motion');

  var lang = 'en'; // English is the default, whatever the browser language is
  try { var s = localStorage.getItem(KEY); if (s === 'de' || s === 'en') lang = s; } catch (e) {}
  h.lang = lang;

  function mark() {
    [].forEach.call(d.querySelectorAll('.lang button'), function (b) {
      b.setAttribute('aria-pressed', String(b.getAttribute('data-lang') === h.lang));
    });
  }

  d.addEventListener('DOMContentLoaded', function () {
    mark();

    d.addEventListener('click', function (e) {
      var lb = e.target.closest && e.target.closest('.lang button');
      if (lb) {
        h.lang = lb.getAttribute('data-lang');
        try { localStorage.setItem(KEY, h.lang); } catch (x) {}
        mark();
        return;
      }
      var cb = e.target.closest && e.target.closest('.copy-btn');
      if (cb) {
        var box = cb.closest('.cmd-row').querySelector('.cmd-box');
        navigator.clipboard.writeText(box.textContent.trim()).then(function () {
          cb.classList.add('copied');
          setTimeout(function () { cb.classList.remove('copied'); }, 1500);
        });
      }
    });

    // Project name in the nav appears once the hero is out of view.
    var nav = d.querySelector('.nav'), hero = d.querySelector('.hero');
    if (nav && hero && 'IntersectionObserver' in window) {
      new IntersectionObserver(function (en) {
        nav.classList.toggle('brand-on', !en[0].isIntersecting);
      }, { rootMargin: '-56px 0px 0px 0px' }).observe(hero);
    } else if (nav) {
      nav.classList.add('brand-on');
    }

    // Scroll meter under the nav (A20).
    if (nav) {
      var meter = d.createElement('span');
      meter.className = 'nav-meter';
      meter.setAttribute('aria-hidden', 'true');
      nav.appendChild(meter);
      var onScroll = function () {
        var max = d.documentElement.scrollHeight - innerHeight;
        nav.style.setProperty('--scroll', max > 0 ? Math.min(1, scrollY / max) : 0);
      };
      addEventListener('scroll', onScroll, { passive: true });
      onScroll();
    }

    // Tabs: the yellow tab slides to the selected one (A11).
    [].forEach.call(d.querySelectorAll('.tabs'), function (tabs) {
      var ind = d.createElement('span');
      ind.className = 'tabs-ind';
      ind.setAttribute('aria-hidden', 'true');
      tabs.insertBefore(ind, tabs.firstChild);
      tabs.classList.add('has-ind');
      var place = function () {
        var cur = tabs.querySelector('[aria-selected="true"],[aria-current="page"]');
        ind.style.width = cur ? cur.offsetWidth + 'px' : '0';
        ind.style.left = cur ? cur.offsetLeft + 'px' : '0';
      };
      tabs.addEventListener('click', function (e) {
        var t = e.target.closest('[role="tab"]');
        if (!t) return;
        [].forEach.call(tabs.querySelectorAll('[role="tab"]'), function (x) { x.setAttribute('aria-selected', String(x === t)); });
        place();
      });
      place();
      addEventListener('resize', place);
      if (d.fonts) d.fonts.ready.then(place);
    });

    if (!h.classList.contains('motion')) return;

    // Counter (A06): figures in the facts strip roll up digit by digit.
    [].forEach.call(d.querySelectorAll('.fact b'), function (b) {
      var m = /^(\D*)(\d+)(\D*)$/.exec(b.textContent.trim());
      if (!m) return;
      b.setAttribute('aria-label', b.textContent.trim());
      b.textContent = m[1];
      m[2].split('').forEach(function (ch) {
        var col = d.createElement('i'), roll = d.createElement('i');
        col.className = 'odo-d';
        roll.className = 'odo-r';
        col.setAttribute('aria-hidden', 'true');
        for (var i = 0; i <= 9; i++) { var x = d.createElement('i'); x.textContent = i; roll.appendChild(x); }
        col.appendChild(roll);
        col.dataset.v = ch;
        b.appendChild(col);
      });
      if (m[3]) b.appendChild(d.createTextNode(m[3]));
      b.classList.add('odo');
    });

    // Teleprinter (A07): [data-type] labels type in with a block cursor.
    [].forEach.call(d.querySelectorAll('[data-type]'), function (el) {
      el.dataset.text = el.textContent;
      el.style.minHeight = el.offsetHeight + 'px';
      el.textContent = '';
    });

    // Entrances (A04 scan, A05 bar, A17 cascade) and the two above, once in view.
    var targets = d.querySelectorAll('.feat,.tiles>.tile,.hero-shot,.showcase figure,.shots figure,.fact b.odo,[data-type]');
    [].forEach.call(d.querySelectorAll('.features,.tiles'), function (g) {
      [].forEach.call(g.children, function (c, i) { c.style.setProperty('--i', i % 12); });
    });
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (en) {
        if (!en.isIntersecting) return;
        var el = en.target;
        io.unobserve(el);
        el.classList.add('is-in');
        if (el.classList.contains('odo')) {
          [].forEach.call(el.querySelectorAll('.odo-d'), function (col, i) {
            var roll = col.firstChild;
            roll.style.transitionDelay = (i * 120) + 'ms';
            requestAnimationFrame(function () { roll.style.transform = 'translateY(-' + col.dataset.v + 'em)'; });
          });
        }
        if (el.dataset.text !== undefined) {
          var text = el.dataset.text, n = 0;
          el.classList.add('is-typing');
          var t = setInterval(function () {
            el.textContent = text.slice(0, ++n);
            if (n >= text.length) { clearInterval(t); setTimeout(function () { el.classList.remove('is-typing'); }, 2000); }
          }, 55);
        }
      });
    }, { rootMargin: '0px 0px -8% 0px' });
    [].forEach.call(targets, function (el) { io.observe(el); });
  });
})();
