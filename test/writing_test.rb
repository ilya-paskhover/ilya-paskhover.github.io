require_relative "test_helper"

class WritingTest < Minitest::Test
  FEATURED = [["Vibe coding apps", "apps"], ["AI agents", "ai-agents"], ["Base44 projects", "apps"]].freeze
  TITLES = ["A small summary of 'Linux Kernel' course - day 2!", "About this blog!", "Welcome to Jekyll!"].freeze
  SLUGS = %w[notes].freeze

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
    fs = doc.css("article.post-featured")
    assert_equal FEATURED.map(&:first), fs.map { |f| f.at_css("a").text.strip }
    assert_equal FEATURED.map(&:last), fs.map { |f| f["data-topic"] }
    fs.each do |f|
      assert_equal "Featured", f.at_css(".chip").text.strip
      refute_empty f["data-search"].to_s
      meta = f.at_css(".post-featured-meta").text
      assert_includes meta, "Ilya Paskhover"
      assert_nil f.at_css(".reading-time"), "1 minute or less: no reading time element"
    end
    assert_includes fs[0].at_css(".post-featured-meta").text, "Apps"
  end

  def test_featured_not_in_list
    list = doc.css("ol.post-list a").map { |a| a.text.strip }
    FEATURED.each { |t, _| refute_includes list, t }
  end

  def test_load_more_hidden_when_three_or_fewer_rows
    assert_equal 3, doc.css("ol.post-list > li.post-row").size
    refute_nil doc.at_css(".load-more-row[hidden]")
  end

  def test_reading_time_include_rule
    src = File.read(File.expand_path("../_includes/reading-time.html", __dir__))
    assert_includes src, "rt_min > 1"
    refute_includes src, "1 minute"
    require "jekyll"
    tpl = Liquid::Template.parse(src)
    render = lambda do |words, fmt|
      tpl.render({ "include" => { "content" => (["w"] * words).join(" "), "format" => fmt } },
                 filters: [Jekyll::Filters]).strip
    end
    assert_equal "", render.call(200, "long")
    assert_equal "", render.call(200, "short")
    assert_equal "2 minutes", render.call(201, "long")
    assert_equal "2 min", render.call(201, "short")
    assert_equal "5 minutes", render.call(1000, "long")
  end

  def test_rows
    rows = doc.css("ol.post-list > li.post-row")
    assert_equal 3, rows.size
    assert_equal TITLES, rows.map { |r| r.at_css("a").text.strip }
    rows.each do |r|
      assert_includes SLUGS, r["data-topic"]
      s = r["data-search"].to_s
      refute_empty s
      assert_equal s.downcase, s
      assert_includes s, r.at_css("a").text.strip.downcase
      assert_match(/\A[A-Z][a-z]{2} \d{2}, \d{4}\z/, r.at_css("time.post-date[datetime]").text.strip)
      assert_nil r.at_css(".reading-time"), "1 minute or less: no reading time element"
    end
    assert_equal "Mar 17, 2016", rows.first.at_css("time").text.strip
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
