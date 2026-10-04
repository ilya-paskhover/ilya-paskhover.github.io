require_relative "test_helper"

class FooterTest < Minitest::Test
  def footer
    page("/").at_css("footer.site-footer")
  end

  def test_footer_links_and_no_art
    f = footer
    refute_nil f
    hrefs = f.css("a").map { |a| a["href"] }
    ["/", "/projects/", "/about/", "/feed.xml", "https://github.com/ilya-paskhover",
     "https://www.linkedin.com/in/ilyapaskhover/"].each { |h| assert_includes hrefs, h }
    assert_empty f.css("svg, img")
    assert_includes f.text, "Ilya Paskhover"
    texts = f.css("a").map { |a| a.text.strip }
    %w[Home Projects About RSS].each { |t| assert_includes texts, t }
    assert(texts.any? { |t| t.start_with?("GitHub") })
    assert(texts.any? { |t| t.start_with?("LinkedIn") })
    refute_includes f.text.downcase, "twitter"
  end

  def test_external_links_open_safely
    footer.css("a[href^='http']").each do |a|
      assert_equal "_blank", a["target"]
      assert_includes a["rel"].to_s, "noopener"
      assert_includes a.text, "(opens in a new tab)"
    end
  end

  def test_copyright
    p = footer.at_css("p.footer-copyright")
    refute_nil p
    assert_includes p.text, "© #{Time.now.year} Ilya Paskhover"
  end

  def test_footer_css
    c = css_compact
    assert_includes c, ".site-footer{"
    assert_includes c, "border-top:1pxsolidvar(--color-border)"
    assert_includes c, ".footer-grid{"
    assert_includes c, "grid-template-columns:1fr;"
    assert_includes c, "font-family:var(--font-mono)"
  end
end
