// Selbsttest für kit/js/kit.js ohne Browser (node tests/kit.test.js, läuft in bin/lint.sh).
// Prüft: Version, escapeHtml, data-kpu-question und Fehlermeldungen kommen maskiert bei Kimais alert-Plugin an.
'use strict';
const fs = require('fs');
const path = require('path');
const vm = require('vm');
const assert = require('assert');

const root = path.join(__dirname, '..');
const source = fs.readFileSync(path.join(root, 'kit/js/kit.js'), 'utf8');
const version = fs.readFileSync(path.join(root, 'VERSION'), 'utf8').trim();

const handlers = {};
const calls = { question: [], error: [] };
let answer = null;
const alertPlugin = {
    question(message, callback) { calls.question.push(message); answer = callback; },
    error(title, message) { calls.error.push([title, message]); },
};
const document = {
    readyState: 'complete',
    addEventListener(name, fn) { (handlers[name] = handlers[name] || []).push(fn); },
    querySelectorAll() { return []; },
    getElementById() { return null; },
    dispatchEvent() { return true; },
};
let fetched = null;
const window = {
    kimai: { getPlugin: (name) => (name === 'alert' ? alertPlugin : null) },
    sessionStorage: { getItem: () => null, removeItem() {}, setItem() {} },
    location: { reload() { throw new Error('unerwartetes Neuladen'); } },
    fetch(url, init) {
        fetched = { url, init };
        return Promise.resolve({
            type: 'basic', ok: false, status: 400,
            headers: { has: () => false, get: () => 'application/json' },
            text: () => Promise.resolve(JSON.stringify({ message: '<img src=x onerror=alert(2)>' })),
        });
    },
    confirm() { throw new Error('natives confirm() benutzt'); },
};
class CustomEvent { constructor(type, init) { this.type = type; Object.assign(this, init); } }
class FormData { constructor() { this.entries = []; } append(k, v) { this.entries.push([k, v]); } }

vm.runInNewContext(source, { window, document, CustomEvent, FormData, JSON, String, Object, Array, Error, Promise });

const ui = window.KimaiPluginUi;
assert.ok(ui, 'window.KimaiPluginUi fehlt');
assert.strictEqual(ui.version, version, 'kit.js VERSION passt nicht zu VERSION');
assert.strictEqual(ui.escapeHtml('<a href="x" title=\'y\'>&</a>'), '&lt;a href=&quot;x&quot; title=&#39;y&#39;&gt;&amp;&lt;/a&gt;');
assert.strictEqual(ui.escapeHtml(null), '');
assert.strictEqual(ui.escapeHtml(5), '5');

function element(attrs) {
    const el = {
        attrs: Object.assign({}, attrs),
        classList: { add() {}, remove() {}, contains: () => false },
        getAttribute(n) { return Object.prototype.hasOwnProperty.call(this.attrs, n) ? this.attrs[n] : null; },
        setAttribute(n, v) { this.attrs[n] = String(v); },
        removeAttribute(n) { delete this.attrs[n]; },
        closest(sel) { return sel === '[data-kpu-post]' ? el : null; },
        dispatchEvent() { return true; },
    };
    return el;
}

const trigger = element({
    'data-kpu-post': '/lock',
    'data-kpu-token': 't',
    'data-kpu-ids': '1,2',
    'data-kpu-question': '<img src=x onerror=alert(1)> %count% „Anna & Bob“',
});
let prevented = false;
handlers.click.forEach((fn) => fn({ target: trigger, preventDefault() { prevented = true; } }));
assert.ok(prevented, 'Klick auf [data-kpu-post] nicht abgefangen');
assert.deepStrictEqual(calls.question, ['&lt;img src=x onerror=alert(1)&gt; 2 „Anna &amp; Bob“'],
    'data-kpu-question muss maskiert an alert.question gehen');
assert.strictEqual(fetched, null, 'vor der Bestätigung darf nichts gesendet werden');

answer(true);
setTimeout(() => {
    assert.ok(fetched && fetched.url === '/lock', 'nach Bestätigung kein POST');
    assert.strictEqual(calls.error.length, 1, 'Fehler-Alert fehlt');
    assert.strictEqual(calls.error[0][1], '&lt;img src=x onerror=alert(2)&gt;', 'Server-Meldung muss maskiert an alert.error gehen');
    assert.ok(!/</.test(calls.error[0][0]), 'Fehlertitel unmaskiert');
    console.log('ok   kit.js Tests (Version, escapeHtml, Frage/Fehler maskiert)');
    testUpdates();
}, 20);

function testUpdates() {
    assert.strictEqual(ui.compareVersions('0.10.0', '0.9.3'), 1);
    assert.strictEqual(ui.compareVersions('v1.2', '1.2.0'), 0);
    assert.strictEqual(ui.compareVersions('1.2.0-beta1', '1.2.0'), 0);
    assert.strictEqual(ui.compareVersions('2.5.2', '2.5.10'), -1);

    const store = {};
    window.localStorage = { getItem: (k) => (k in store ? store[k] : null), setItem(k, v) { store[k] = String(v); } };
    const requests = [];
    let file = { format: 1, projects: { 'kimai-anfahrten': { version: '0.10.0', date: '2026-10-05', url: 'https://github.com/shrippen/kimai-anfahrten/releases/tag/v0.10.0' } } };
    window.fetch = (url, init) => {
        requests.push({ url, init });
        return Promise.resolve({ ok: true, json: () => Promise.resolve(file) });
    };
    function updateBox(version) {
        const parts = { link: { href: '#' }, latest: { textContent: '' }, dismiss: { click: null, addEventListener(n, fn) { this.click = fn; } } };
        const box = element({ 'data-kpu-update': 'kimai-anfahrten', 'data-kpu-version': version });
        box.hidden = true;
        box.parts = parts;
        box.querySelector = (sel) => ({ '[data-kpu-update-link]': parts.link, '[data-kpu-update-latest]': parts.latest, '[data-kpu-update-dismiss]': parts.dismiss })[sel];
        return box;
    }
    function run(box) {
        document.querySelectorAll = (sel) => (sel.indexOf('data-kpu-update') !== -1 && box.getAttribute('data-kpu-update-done') === null ? [box] : []);
        ui.checkUpdates();
        return new Promise((resolve) => setTimeout(resolve, 20));
    }

    const old = updateBox('0.9.3');
    run(old).then(() => {
        assert.strictEqual(requests.length, 1);
        assert.strictEqual(requests[0].url, 'https://shrippen.github.io/versions.json', 'Anfrage ohne Parameter');
        assert.strictEqual(requests[0].init.credentials, 'omit', 'Anfrage ohne Cookies');
        assert.strictEqual(old.hidden, false, 'Hinweis bei neuerer Version nicht sichtbar');
        assert.strictEqual(old.parts.link.href, file.projects['kimai-anfahrten'].url);
        assert.strictEqual(old.parts.latest.textContent, '0.10.0 · 2026-10-05');
        old.parts.dismiss.click();
        assert.strictEqual(old.hidden, true, 'Ausblenden wirkt nicht');
        return run(updateBox('0.9.3'));
    }).then(() => {
        assert.strictEqual(requests.length, 1, 'zweite Anfrage am selben Tag');
        const again = updateBox('0.9.3');
        return run(again).then(() => assert.strictEqual(again.hidden, true, 'ausgeblendete Version erscheint wieder'));
    }).then(() => {
        const current = updateBox('0.10.0');
        return run(current).then(() => {
            assert.strictEqual(requests.length, 2, 'neue installierte Version fragt neu');
            assert.strictEqual(current.hidden, true, 'Hinweis ohne neuere Version');
        });
    }).then(() => {
        file = { format: 1, projects: { 'kimai-anfahrten': { version: '9.0.0', url: 'javascript:alert(1)' } } };
        delete store['kpu.update.kimai-anfahrten'];
        const bad = updateBox('0.9.3');
        return run(bad).then(() => assert.strictEqual(bad.hidden, true, 'Link ohne https darf nicht erscheinen'));
    }).then(() => {
        file = { format: 2, projects: {} };
        delete store['kpu.update.kimai-anfahrten'];
        const unknown = updateBox('0.9.3');
        return run(unknown).then(() => assert.strictEqual(unknown.hidden, true, 'unbekanntes Format'));
    }).then(() => {
        window.fetch = () => Promise.reject(new Error('offline'));
        delete store['kpu.update.kimai-anfahrten'];
        const offline = updateBox('0.9.3');
        return run(offline).then(() => assert.strictEqual(offline.hidden, true));
    }).then(() => {
        console.log('ok   kit.js Tests (Update-Hinweis: Vergleich, Anfrage, einmal am Tag, Ausblenden, nur https, still bei Fehlern)');
    }).catch((err) => { console.error(err); process.exitCode = 1; });
}
