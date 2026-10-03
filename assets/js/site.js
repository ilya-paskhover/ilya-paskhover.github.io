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

  // Home feed: topic tabs and load more
  var feed = document.getElementById("writing");
  var moreBtn = feed && feed.querySelector(".load-more");
  if (feed && moreBtn) {
    var tabs = feed.querySelectorAll(".topic-tab");
    var rows = feed.querySelectorAll(".post-row");
    var featured = feed.querySelector(".post-featured");
    var moreRow = moreBtn.closest(".load-more-row");
    var size = parseInt(moreBtn.getAttribute("data-page-size"), 10) || 3;
    var topic = "all";
    var shown = size;

    var render = function () {
      var all = topic === "all";
      if (featured) featured.hidden = !(all || featured.getAttribute("data-topic") === topic);
      var count = 0, hiddenLeft = 0;
      rows.forEach(function (row) {
        var match = all || row.getAttribute("data-topic") === topic;
        var show = match && (!all || count < shown);
        if (match) count++;
        row.hidden = !show;
        row.classList.toggle("is-shown", show);
        if (match && !show) hiddenLeft++;
      });
      moreRow.hidden = hiddenLeft === 0;
    };
    var loadMore = function () { shown = rows.length; render(); };

    tabs.forEach(function (tab) {
      tab.addEventListener("click", function () {
        topic = tab.getAttribute("data-topic");
        shown = size;
        tabs.forEach(function (t) { t.setAttribute("aria-pressed", t === tab ? "true" : "false"); });
        render();
      });
    });
    moreBtn.addEventListener("click", loadMore);
    feed.loadMore = loadMore;
    render();
  }

  // Post page: reading progress and active TREE entry
  var progress = document.querySelector(".read-progress");
  var postBody = document.getElementById("post-body");
  if (progress && postBody) {
    var glyphs = progress.querySelector(".progress-glyphs");
    var valueEl = progress.querySelector(".progress-value");
    var treeLinks = Array.prototype.slice.call(document.querySelectorAll(".post-tree a"));
    var targets = treeLinks.map(function (a) {
      var id = decodeURIComponent((a.getAttribute("href") || "").slice(1));
      return id && id !== "post-body" ? document.getElementById(id) : null;
    });
    var setActive = function (idx) {
      treeLinks.forEach(function (a, i) {
        var on = i === idx;
        a.classList.toggle("is-active", on);
        if (on) a.setAttribute("aria-current", "location"); else a.removeAttribute("aria-current");
      });
    };
    var update = function () {
      var rect = postBody.getBoundingClientRect();
      var vh = window.innerHeight || doc.clientHeight;
      var top = rect.top + window.pageYOffset;
      var span = rect.height - vh;
      var pct = span <= 0 ? 100 : Math.round(((window.pageYOffset - top) / span) * 100);
      pct = Math.max(0, Math.min(100, pct));
      var filled = Math.floor(pct / 5);
      glyphs.textContent = new Array(filled + 1).join("█") + new Array(21 - filled).join("░");
      valueEl.textContent = (pct < 10 ? "0" : "") + pct + "%";
      progress.setAttribute("aria-valuenow", String(pct));

      var active = -1;
      var atEnd = window.pageYOffset + vh >= doc.scrollHeight - 2 && doc.scrollHeight > vh;
      targets.forEach(function (el, i) {
        if (el && el.getBoundingClientRect().top <= vh * 0.3) active = i;
      });
      if (atEnd) {
        for (var i = targets.length - 1; i >= 0; i--) { if (targets[i]) { active = i; break; } }
      }
      setActive(active);
    };
    treeLinks.forEach(function (a, i) {
      a.addEventListener("click", function () { setActive(i); });
    });
    window.addEventListener("scroll", update, { passive: true });
    window.addEventListener("resize", update);
    update();
  }

  function moreRow_hidden() {
    var r = document.querySelector("#writing .load-more-row");
    return !r || r.hidden;
  }

  // Keyboard shortcuts
  document.addEventListener("keydown", function (e) {
    if (e.ctrlKey || e.metaKey || e.altKey || e.defaultPrevented) return;
    if (read("shortcuts") === "off") return;
    var t = e.target;
    if (t && t.closest && t.closest("input, textarea, select, [contenteditable]")) return;
    var key = (e.key || "").toLowerCase();
    var link = document.querySelector('.nav-link[aria-keyshortcuts="' + key + '"]');
    if (key === "r" && feed && feed.loadMore && !moreRow_hidden()) {
      e.preventDefault();
      feed.loadMore();
    } else if (link) {
      e.preventDefault();
      link.click();
    } else if (key === "s" && location.pathname !== "/") {
      e.preventDefault();
      location.href = "/#search";
    }
  });
})();
