require_relative "test_helper"

class FoundationTest < Minitest::Test
  def test_css_tokens_and_rules
    c = css_compact.downcase
    ["--color-bg:#141414", "--color-accent:", "--font-mono:", "--font-sans:",
     "prefers-reduced-motion:reduce", ":focus-visible"].each do |needle|
      assert_includes c, needle
    end
    assert(c.include?('[data-theme="light"]') || c.include?("[data-theme=light]"),
           "light theme override missing")
  end

  def test_page_shell
    ["/", "/about/"].each do |path|
      doc = page(path)
      refute_empty doc.css('html[lang="en"][data-theme="dark"]'), "#{path} html lang/theme"
      first = doc.at_css("body a")
      refute_nil first
      assert first.matches?('a.skip-link[href="#main"]'), "#{path} first link is not the skip link"
      assert_equal 1, doc.css("main#main").size, "#{path} main#main count"
    end
  end

  def test_head_has_theme_script_before_stylesheet
    html = File.read(site_file("/"), encoding: "UTF-8")
    assert_operator html.index("localStorage"), :<, html.index("/css/main.css")
  end

  def test_no_web_font_requests
    own_pages.each do |f|
      refute_includes File.read(f, encoding: "UTF-8"), "fonts.googleapis.com", f
    end
  end
end
