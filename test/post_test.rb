require_relative "test_helper"

class PostTest < Minitest::Test
  def doc
    @doc ||= page("/2025/06/24/ai-agents.html")
  end

  def test_hero
    assert_equal "All writing", doc.at_css('a.back-link[href="/"]').text.strip
    assert_equal 1, doc.css("h1.post-title").size
    assert_equal "AI agents", doc.at_css("h1.post-title").text.strip
    assert_equal "AI agents", doc.at_css(".post-topic").text.strip
    refute_empty doc.at_css("p.post-lead").text.strip
    assert_nil doc.at_css(".post-archived-note")
  end

  def test_meta_grid
    grid = doc.at_css("dl.post-meta-grid")
    assert_equal ["Author", "Published"], grid.css("dt").map { |d| d.text.strip }
    assert_includes grid["class"], "post-meta-grid--pair"
    dds = grid.css("dd")
    assert_equal 2, dds.size
    dds.each { |dd| refute_nil dd.at_css(".tree-glyph"), "dd needs .tree-glyph" }
    assert_includes dds[0].text, "Ilya Paskhover"
    refute_nil dds[1].at_css("time[datetime]")
  end

  def test_tree_and_body
    links = doc.css('nav.post-tree[aria-label="Table of contents"] ul#markdown-toc a')
    assert_equal ["#youtube-videos-summarizer"], links.map { |a| a["href"] }
    assert_empty doc.css("#post-body #markdown-toc")
    assert_equal 1, doc.css("#markdown-toc").size
    refute_nil doc.at_css("#post-body h2#youtube-videos-summarizer")
  end

  def test_progress_and_hint
    bar = doc.at_css('.read-progress[role="progressbar"][aria-valuenow="0"]')
    refute_nil bar
    assert_equal "00%", bar.at_css(".progress-value").text.strip
    assert_includes doc.at_css(".scroll-hint").text, "to scroll"
    assert_includes js, "aria-valuenow"
  end

  def test_post_nav_and_cta
    assert_equal "/2025/05/23/base44-projects.html", doc.at_css("a.post-nav-older")["href"]
    assert_equal "/2025/11/22/vibe-coding-apps.html", doc.at_css("a.post-nav-newer")["href"]
    assert doc.css("aside.cta a").any? { |a| a["href"].include?("linkedin.com") }
  end

  def test_base44_tree
    d = page("/2025/05/23/base44-projects.html")
    assert_equal ["#interactive-ai-cv", "#epoch-converter"], d.css("nav.post-tree ul#markdown-toc a").map { |a| a["href"] }
  end

  def test_archived_fallback
    d = page("/jekyll/update/2016/03/17/welcome-to-jekyll.html")
    refute_nil d.at_css(".post-archived-note")
    links = d.css("nav.post-tree ul.post-tree-fallback a")
    assert_equal ["Overview"], links.map { |a| a.text.strip }
    assert_equal "#post-body", links.first["href"]
  end
end
