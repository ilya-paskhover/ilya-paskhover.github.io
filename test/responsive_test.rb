require_relative "test_helper"

class ResponsiveTest < Minitest::Test
  def test_css_has_breakpoints_and_rules
    c = css_compact
    refute_empty c
    assert_match(/@media[^{]*min-width:768px/, c)
    assert_match(/@media[^{]*min-width:1024px/, c)
    assert_includes c, "position:sticky"
    assert(c.include?("overflow-wrap:anywhere") || c.include?("overflow-wrap:break-word"))
    assert_includes c, "overflow-x:auto"
    assert_includes c, "min-height:44px"
  end

  def test_tap_targets_and_row_layout_below_768
    c = css_compact
    assert_match(/@media[^{]*max-width:767px\)\{.*min-height:44px/, c)
    assert_match(/grid-template-areas:"datetime""titletitle"/, c)
  end

  def test_tree_not_sticky_below_1024
    assert_match(/@media[^{]*max-width:1023px\)\{\.post-aside\{position:static/, css_compact)
  end

  def test_viewport_meta_on_every_page
    pages = own_pages
    refute_empty pages
    pages.each do |f|
      doc = Nokogiri::HTML(File.read(f, encoding: "UTF-8"))
      next if doc.at_css("meta[http-equiv='refresh']")
      assert doc.at_css('meta[name="viewport"][content*="width=device-width"]'), "no viewport meta in #{f}"
    end
  end

  def test_sticky_tree_has_room_below_last_section
    c = css_compact
    assert_match(/@media[^{]*min-width:1024px\)\{\.post-aside\{position:sticky;top:[^;}]+;align-self:start\}/, c)
    assert_match(/@media[^{]*min-width:1024px\)\{[^@]*\.post-layout>\.post-content\{padding-bottom:\d+vh/, c)
  end
end
