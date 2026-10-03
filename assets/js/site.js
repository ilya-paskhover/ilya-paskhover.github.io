(function () {
  var doc = document.documentElement;

  function store(key, val) { try { localStorage.setItem(key, val); } catch (e) {} }
  function read(key) { try { return localStorage.getItem(key); } catch (e) { return null; } }

  // Theme toggle
  var themeBtn = document.getElementById("theme-toggle");
  function syncTheme() {
    var light = doc.getAttribute("data-theme") === "light";
    if (themeBtn) themeBtn.setAttribute("aria-label", light ? "Switch to dark theme" : "Switch to light theme");
  }
  if (themeBtn) {
    syncTheme();
    themeBtn.addEventListener("click", function () {
      var next = doc.getAttribute("data-theme") === "light" ? "dark" : "light";
      doc.setAttribute("data-theme", next);
      store("theme", next);
      syncTheme();
    });
  }

  // Mobile menu
  var toggle = document.querySelector(".nav-toggle");
  var menu = document.getElementById("site-nav-menu");
  function setMenu(open) {
    toggle.setAttribute("aria-expanded", open ? "true" : "false");
    menu.classList.toggle("is-open", open);
  }
  if (toggle && menu) {
    toggle.addEventListener("click", function () {
      setMenu(toggle.getAttribute("aria-expanded") !== "true");
    });
    menu.addEventListener("click", function (e) {
      if (e.target.closest("a")) setMenu(false);
    });
    document.addEventListener("keydown", function (e) {
      if (e.key === "Escape" && toggle.getAttribute("aria-expanded") === "true") {
        setMenu(false);
        toggle.focus();
      }
    });
  }

  // Keyboard shortcuts
  document.addEventListener("keydown", function (e) {
    if (e.ctrlKey || e.metaKey || e.altKey || e.defaultPrevented) return;
    if (read("shortcuts") === "off") return;
    var t = e.target;
    if (t && t.closest && t.closest("input, textarea, select, [contenteditable]")) return;
    var key = (e.key || "").toLowerCase();
    var link = document.querySelector('.nav-link[aria-keyshortcuts="' + key + '"]');
    if (link) {
      e.preventDefault();
      link.click();
    } else if (key === "s" && location.pathname !== "/") {
      e.preventDefault();
      location.href = "/#search";
    }
  });
})();
