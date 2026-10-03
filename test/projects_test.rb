require_relative "test_helper"

class ProjectsTest < Minitest::Test
  TITLES = ["Shallow Whale", "Interactive AI CV", "YouTube Videos Summarizer", "Epoch Converter", "Math Bubbles"].freeze

  def doc
    @doc ||= page("/projects/")
  end

  def test_heading_and_current_nav
    assert_equal ["Projects"], doc.css("h1").map { |h| h.text.strip }
    assert_equal "Apps, games and AI agents I have built.", doc.at_css("p.page-tagline").text.strip
    assert_equal ["/projects/"], doc.css('nav.site-nav a.nav-link[aria-current="page"]').map { |a| a["href"] }
  end

  def test_rows
    rows = doc.css("ol.project-list > li.project-row")
    assert_equal TITLES, rows.map { |r| r.at_css("h2.project-title a").text.sub("(opens in a new tab)", "").sub("↗", "").strip }
    rows.each do |r|
      refute_empty r.at_css(".project-description").text.strip
      refute_empty r.at_css(".project-kind").text.strip
      refute_empty r.css(".project-tags li.chip")
    end
    first = rows.first
    assert_equal "Web game", first.at_css(".project-kind").text.strip
    assert_equal %w[Game PWA], first.css(".project-tags li.chip").map { |c| c.text.strip }
  end

  def test_links
    whale = doc.css("h2.project-title a").first
    assert_equal "/shallow-whale/", whale["href"]
    assert_nil whale["target"]
    refute_includes whale.text, "opens in a new tab"
    math = doc.css("h2.project-title a").last
    assert_equal "/assets/html_apps/math_bubbles.html", math["href"]
    assert_nil math["target"]
    http = doc.css(".project-list a").select { |a| a["href"].start_with?("http") }
    assert_equal 3, http.size
    http.each do |a|
      assert_equal "_blank", a["target"]
      assert_includes a["rel"].to_s, "noopener"
      assert_includes a.text, "(opens in a new tab)"
      assert a.at_css('span[aria-hidden="true"]')
    end
  end

  def test_no_svg
    assert_empty doc.css(".project-list svg")
  end
end
