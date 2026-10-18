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
    assert_equal "Principal software architect. AI agent infrastructure, industrial IoT and small apps.", doc.at_css("p.post-lead").text.strip
  end

  def test_intro
    assert_includes doc.at_css(".about-intro").text, "more than 16 years of experience"
    refute_includes doc.text, "experince"
  end

  def test_meta_grid
    assert_equal %w[role experience elsewhere], doc.css("dl.post-meta-grid dt").map { |t| t.text.strip.downcase }
    dds = doc.css("dl.post-meta-grid dd").map { |d| d.text.sub("└", "").strip }
    assert_equal "Principal software architect", dds[0]
    assert_equal "16+ years", dds[1]
    links = doc.css("dl.post-meta-grid a")
    assert_equal ["LinkedIn", "GitHub"], links.map { |a| clean(a) }
    assert_includes links.map { |a| a["href"] }, "https://www.linkedin.com/in/ilyapaskhover/"
    assert_includes links.map { |a| a["href"] }, "https://github.com/ilya-paskhover"
  end

  def test_focus_rows
    rows = doc.css("section.focus-areas .focus-row")
    assert_equal ["AI agent infrastructure", "Industrial IoT and edge Linux", "Proofs of concept and small apps", "Systems and fundamentals"], rows.map { |r| r.at_css("h3").text.strip }
    rows.each { |r| refute_empty r.css("p").text.strip }
  end

  def test_projects
    cards = doc.css("section.about-projects article.project-card")
    assert_equal 3, cards.size
    assert_equal ["Shallow Whale", "Claude Code mods", "YouTube Videos Summarizer"], cards.map { |c| clean(c.at_css(".project-title")) }
    assert_equal ["/2026/10/02/shallow-whale.html", "/2025/05/23/base44-projects.html", "/2025/06/24/ai-agents.html"],
                 cards.map { |c| c.at_css(".project-post a")["href"] }
  end

  def test_cta
    hrefs = doc.css("aside.cta a").map { |a| a["href"] }
    assert_includes hrefs, "https://www.linkedin.com/in/ilyapaskhover/"
    assert_includes hrefs, "https://github.com/ilya-paskhover"
    assert_includes doc.at_css("aside.cta").text, "Get in touch"
  end
end
