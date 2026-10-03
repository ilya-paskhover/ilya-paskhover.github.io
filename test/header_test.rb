require_relative "test_helper"

class HeaderTest < Minitest::Test
  PAGES = ["/", "/about/", "/2025/06/24/ai-agents.html"].freeze
  GITHUB = "https://github.com/ilya-paskhover".freeze

  def test_header_structure
    PAGES.each do |path|
      doc = page(path)
      refute_empty doc.css("header.site-header"), "#{path} header"
      brand = doc.at_css("a.site-brand[href='/']")
      refute_nil brand, "#{path} brand"
      assert_equal "Ilya Paskhover", brand.text.strip
      assert_empty brand.css("svg, img")

      links = doc.css('nav.site-nav[aria-label="Primary"] a.nav-link')
      assert_equal 4, links.size, "#{path} nav links"
      assert_equal %w[h p a g], links.map { |a| a["aria-keyshortcuts"] }
      assert_equal ["/", "/projects/", "/about/", GITHUB], links.map { |a| a["href"] }
      assert_equal %w[[H] [P] [A] [G]], links.map { |a| a.at_css('span.kbd-hint[aria-hidden="true"]')&.text }

      cta = doc.at_css("a.nav-cta")
      refute_nil cta
      assert_includes cta.text, "Get in touch"
      assert_includes cta["href"], "linkedin.com"

      refute_empty doc.css('button.nav-toggle[aria-controls="site-nav-menu"][aria-expanded="false"]')
      refute_empty doc.css("#site-nav-menu")
      refute_empty doc.css("button#theme-toggle[aria-label]")
      refute_empty doc.css('script[src="/assets/js/site.js"][defer]')
      assert_empty doc.css(".menu-icon")
    end
  end

  def test_aria_current
    current = ->(path) { page(path).css('nav.site-nav a.nav-link[aria-current="page"]').map { |a| a["href"] } }
    assert_equal ["/"], current.("/")
    assert_equal ["/about/"], current.("/about/")
    assert_empty current.("/2025/06/24/ai-agents.html")
  end

  def test_js_behaviour_hooks
    %w[keydown localStorage aria-expanded].each { |s| assert_includes js, s }
  end

  def test_projects_stub_lists_projects
    text = page("/projects/").text
    ["Shallow Whale", "Interactive AI CV", "YouTube Videos Summarizer", "Epoch Converter", "Math Bubbles"].each do |t|
      assert_includes text, t
    end
  end
end
