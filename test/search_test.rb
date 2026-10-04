require_relative "test_helper"

class SearchTest < Minitest::Test
  def doc
    @doc ||= page("/")
  end

  def test_toggle
    b = doc.at_css("div.feed-toolbar button.search-toggle")
    refute_nil b
    assert_equal "post-search-panel", b["aria-controls"]
    assert_equal "false", b["aria-expanded"]
    assert_equal "[S]", b.at_css("span.kbd-hint").text.strip
    assert_includes b.text, "Search"
  end

  def test_panel_and_input
    refute_nil doc.at_css("#post-search-panel[hidden]")
    input = doc.at_css('#post-search-panel input#post-search[type="search"]')
    refute_nil input
    assert_equal "Search posts", doc.at_css("label[for=post-search]").text.strip
  end

  def test_empty_state
    assert_equal "No posts match.", doc.at_css("p.search-empty[hidden]").text.strip
  end

  def test_data_search
    row = doc.css("li.post-row").find { |r| r.at_css("a").text.include?("Linux Kernel") }
    refute_nil row
    assert_includes row["data-search"], "kernel"
    doc.css("article.post-featured").each { |f| refute_empty f["data-search"] }
  end

  def test_js
    %w[post-search data-search #search].each { |s| assert_includes js, s }
  end
end
