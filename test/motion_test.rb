require_relative "test_helper"

class MotionTest < Minitest::Test
  def block(css, header)
    start = css.index(header)
    return nil unless start
    i = css.index("{", start)
    depth = 0
    j = i
    while j < css.length
      depth += 1 if css[j] == "{"
      depth -= 1 if css[j] == "}"
      break if depth.zero?
      j += 1
    end
    css[i..j]
  end

  def test_keyframes_and_hover_states
    c = css_compact
    assert_includes c, "@keyframes"
    assert(c.include?(".post-row:hover") || c.include?(".post-row:focus-within"))
    assert(c.include?(".project-card:hover") || c.include?(".project-row:hover"))
    assert_includes c, "scroll-margin-top"
  end

  def test_smooth_scroll_only_when_no_preference
    b = block(css_compact, "@media(prefers-reduced-motion:no-preference)")
    refute_nil b, "missing no-preference block"
    assert_includes b, "scroll-behavior:smooth"
    assert_equal 1, css_compact.scan("scroll-behavior:smooth").size, "smooth scroll must only appear in the no-preference block"
  end

  def test_reduced_motion_block
    b = block(css_compact, "@media(prefers-reduced-motion:reduce)")
    refute_nil b
    assert_match(/animation:none/, b)
    assert_match(/transition:none/, b)
  end

  def test_no_infinite_animation
    refute_match(/animation[^;}]*infinite/, css_compact)
  end

  def test_sticky_tree_padding_kept
    c = css_compact
    assert_match(/@media[^{]*min-width:1024px\)\{[^@]*\.post-layout>\.post-content\{padding-bottom:60vh/, c)
  end

  # Reading progress formula, taken straight from assets/js/site.js and evaluated
  # with Node when it is available (the container may not have it).
  def test_progress_formula_in_js
    assert_match(/function readingProgress\(scrollY, docHeight, viewportHeight\)/, js)
    assert_includes js, "if (span <= 0) return 100"
    assert_includes js, "Math.max(0, Math.min(100"
    assert_includes js, "readingProgress(window.pageYOffset, doc.scrollHeight, vh)"
  end

  EXPECTED = [0, 25, 50, 100, 100, 100].freeze

  def test_progress_formula_values
    src = js[/function readingProgress\(.*?\r?\n  \}\r?\n/m]
    refute_nil src
    # doc 2000, viewport 800: span 1200. Last case: document does not scroll.
    if system("node --version > /dev/null 2>&1")
      script = "#{src}
console.log([readingProgress(0,2000,800),readingProgress(300,2000,800),readingProgress(600,2000,800),readingProgress(1200,2000,800),readingProgress(5000,2000,800),readingProgress(0,700,800)].join(','))"
      assert_equal EXPECTED.join(","), IO.popen(["node", "-e", script], &:read).strip
    else
      f = ->(y, d, vh) { span = d - vh; span <= 0 ? 100 : [[(y.to_f / span * 100).round, 0].max, 100].min }
      assert_equal EXPECTED, [f[0, 2000, 800], f[300, 2000, 800], f[600, 2000, 800], f[1200, 2000, 800], f[5000, 2000, 800], f[0, 700, 800]]
    end
  end
end
