require_relative "test_helper"

class WritingTest < Minitest::Test
  TITLES = ["AI agents", "Base44 projects", "A small summary of 'Linux Kernel' course - day 2!",
            "About this blog!", "Welcome to Jekyll!"].freeze
  SLUGS = %w[ai-agents apps notes].freeze

  def doc
    @doc ||= page("/")
  end

  def test_section_and_tabs
    sec = doc.at_css("section#writing")
    refute_nil sec
    assert_equal "Writing", sec.at_css("h2").text.strip
    tabs = sec.css(".topic-tabs[aria-label='Filter by topic'] button.topic-tab")
    assert_equal ["All", "AI agents", "Apps", "Notes"], tabs.map { |t| t.text.strip }
    assert_equal %w[all ai-agents apps notes], tabs.map { |t| t["data-topic"] }
    assert_equal %w[true false false false], tabs.map { |t| t["aria-pressed"] }
    assert_empty doc.css("h1").select { |h| h.text.strip == "Posts" }
  end

  def test_featured
    f = doc.at_css('article.post-featured[data-topic="apps"]')
    refute_nil f
    assert_equal "Featured", f.at_css(".chip").text.strip
    assert_equal "Vibe coding apps", f.at_css("a").text.strip
    meta = f.at_css(".post-featured-meta").text
    assert_includes meta, "Ilya Paskhover"
    assert_includes meta, "Apps"
    assert_equal "1 minute", f.at_css(".reading-time").text.strip
  end

  def test_rows
    rows = doc.css("ol.post-list > li.post-row")
    assert_equal 5, rows.size
    assert_equal TITLES, rows.map { |r| r.at_css("a").text.strip }
    rows.each do |r|
      assert_includes SLUGS, r["data-topic"]
      s = r["data-search"].to_s
      refute_empty s
      assert_equal s.downcase, s
      assert_includes s, r.at_css("a").text.strip.downcase
      assert_match(/\A[A-Z][a-z]{2} \d{2}, \d{4}\z/, r.at_css("time.post-date[datetime]").text.strip)
      assert_match(/\A\d+ minutes?\z/, r.at_css(".reading-time").text.strip)
    end
    assert_equal "Jun 24, 2025", rows.first.at_css("time").text.strip
  end

  def test_load_more_and_js
    btn = doc.at_css("button.load-more")
    assert_equal "3", btn["data-page-size"]
    assert_includes doc.at_css(".load-more-hint").text, "R"
    assert_includes js, "load-more"
    assert_includes js, "topic-tab"
  end

  def test_urls_unchanged
    assert File.file?(site_file("/2025/06/24/ai-agents.html"))
    assert_equal "AI agents", page("/2025/06/24/ai-agents.html").at_css("h1").text.strip
  end
end
