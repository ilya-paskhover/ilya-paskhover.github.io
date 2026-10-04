require_relative "test_helper"
require "yaml"

class HomeIntroTest < Minitest::Test
  PROFILE = YAML.load_file(File.join(SRC, "_data", "profile.yml"))

  def doc
    @doc ||= page("/")
  end

  def test_single_h1_title
    assert_equal ["Ilya Paskhover"], doc.css("h1").map { |h| h.text.strip }
    assert_equal 1, doc.css("h1.home-title").size
  end

  def test_tagline_and_facts
    assert_equal PROFILE["tagline"], doc.at_css("p.home-tagline").text.strip
    items = doc.css("ul.home-facts li")
    assert_equal 3, items.size
    items.each do |li|
      glyph = li.at_css(".tree-glyph")
      refute_nil glyph
      assert_equal "└", glyph.text.strip
    end
  end

  def test_grid_order
    kids = doc.at_css(".home-grid").element_children
    assert_equal "aside", kids.first.name
    assert_includes kids.first["class"], "home-intro"
    assert_operator kids.index { |k| k["id"] == "writing" }, :>, 0
  end

  def test_featured_projects
    grid = doc.at_css(".home-grid")
    sec = doc.at_css("section#featured-projects")
    refute_nil sec
    assert_equal grid, sec.previous_element
    assert_equal ["Featured projects"], sec.css("h2").map { |h| h.text.strip }
    titles = sec.css("article.project-card h3.project-title a").map { |a| a.text.sub("(opens in a new tab)", "").sub("↗", "").strip }
    assert_equal ["Shallow Whale", "Interactive AI CV", "YouTube Videos Summarizer"], titles
    assert_equal 1, sec.css('a.view-all[href="/projects/"]').size
    assert_equal "View all projects", sec.at_css("a.view-all").text.strip
  end

  def test_css_layout
    assert_includes css_compact, "minmax(260px,1fr)2fr"
    assert_includes css_compact, ".home-title{"
  end
end
