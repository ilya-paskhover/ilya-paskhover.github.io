require_relative "test_helper"

class AboutTest < Minitest::Test
  def doc
    @doc ||= page("/about/")
  end

  def clean(node)
    node.text.sub("(opens in a new tab)", "").sub("↗", "").strip
  end

  def test_heading_and_nav
    assert_equal ["About"], doc.css("h1").map { |h| h.text.strip }
    assert_equal ["/about/"], doc.css('nav.site-nav a.nav-link[aria-current="page"]').map { |a| a["href"] }
    assert_equal "About", doc.at_css("header.post-hero span.chip").text.strip
    assert_equal "Senior software developer. AI agents, apps and engineering notes.", doc.at_css("p.post-lead").text.strip
  end

  def test_intro
    assert_includes doc.at_css(".about-intro").text, "more than 15 years of experience"
    refute_includes doc.text, "experince"
  end

  def test_meta_grid
    assert_equal %w[role experience elsewhere], doc.css("dl.post-meta-grid dt").map { |t| t.text.strip.downcase }
    links = doc.css("dl.post-meta-grid a")
    assert_equal ["LinkedIn", "GitHub"], links.map { |a| clean(a) }
    assert_includes links.map { |a| a["href"] }, "https://www.linkedin.com/in/ilyapaskhover/"
    assert_includes links.map { |a| a["href"] }, "https://github.com/ilya-paskhover"
  end

  def test_focus_rows
    rows = doc.css("section.focus-areas .focus-row")
    assert_equal ["AI agents and automation", "Web apps and prototypes", "Systems and fundamentals"], rows.map { |r| r.at_css("h3").text.strip }
    rows.each { |r| refute_empty r.css("p").text.strip }
  end

  def test_projects
    cards = doc.css("section.about-projects article.project-card")
    assert_equal 3, cards.size
    assert_equal ["Shallow Whale", "Interactive AI CV", "YouTube Videos Summarizer"], cards.map { |c| clean(c.at_css(".project-title")) }
  end

  def test_cta
    hrefs = doc.css("aside.cta a").map { |a| a["href"] }
    assert_includes hrefs, "https://www.linkedin.com/in/ilyapaskhover/"
    assert_includes hrefs, "https://github.com/ilya-paskhover"
    assert_includes doc.at_css("aside.cta").text, "Get in touch"
  end
end
