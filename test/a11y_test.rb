require_relative "test_helper"

class A11yTest < Minitest::Test
  def docs
    own_pages.map { |f| [f, Nokogiri::HTML(File.read(f, encoding: "UTF-8"))] }
  end

  def each_doc
    pages = docs
    refute_empty pages
    pages.each { |f, d| yield f.sub("#{SITE}/", ""), d }
  end

  def hidden_ancestor?(node)
    node.ancestors.any? { |a| a.respond_to?(:[]) && a["aria-hidden"] == "true" }
  end

  def accessible_text(node)
    return "" if node.element? && node["aria-hidden"] == "true"
    return node.text if node.text? || node.cdata?
    node.children.map { |c| accessible_text(c) }.join
  end

  def test_document_structure
    each_doc do |name, d|
      next if d.at_css("meta[http-equiv='refresh']") && d.at_css("body").text.strip.length < 200 && d.css("h1").empty?
      assert d.at_css("html")["lang"].to_s != "", "#{name}: html[lang]"
      assert_equal 1, d.css("h1").size, "#{name}: h1 count"
      assert_equal 1, d.css("main").size, "#{name}: main count"
      level = 0
      d.css("h1,h2,h3,h4,h5,h6").each do |h|
        n = h.name[1].to_i
        assert n <= level + 1, "#{name}: heading skip to #{h.name} after h#{level}"
        level = n
      end
      ids = d.css("[id]").map { |e| e["id"] }
      dups = ids.select { |i| ids.count(i) > 1 }.uniq
      assert_empty dups, "#{name}: duplicate ids"
    end
  end

  def test_images_have_alt
    each_doc do |name, d|
      d.css("img").each { |i| assert i.key?("alt"), "#{name}: img without alt #{i['src']}" }
    end
  end

  def test_accessible_names
    each_doc do |name, d|
      d.css("a, button").each do |e|
        next if e.name == "a" && !e.key?("href")
        label = e["aria-label"].to_s.strip
        text = accessible_text(e).strip
        refute_empty label + text, "#{name}: unnamed #{e.name} #{e.to_html[0, 80]}"
      end
    end
  end

  def test_blank_links_have_noopener
    each_doc do |name, d|
      d.css("a[target='_blank']").each do |a|
        assert_includes a["rel"].to_s, "noopener", "#{name}: #{a['href']}"
      end
    end
  end

  def test_decorative_and_interactive_markup
    each_doc do |name, d|
      d.css(".kbd-hint, .tree-glyph, .progress-glyphs").each do |e|
        assert_equal "true", e["aria-hidden"], "#{name}: #{e['class']} not aria-hidden"
      end
      d.css(".topic-tab").each { |t| assert t.key?("aria-pressed"), "#{name}: topic-tab aria-pressed" }
    end
  end

  def test_skip_link_is_first_focusable
    each_doc do |name, d|
      first = d.at_css("a[href], button, input, select, textarea, [tabindex]:not([tabindex='-1'])")
      refute_nil first, name
      assert_includes first["class"].to_s, "skip", "#{name}: first focusable is not skip link"
      assert_match(/\A#/, first["href"].to_s)
    end
  end

  def test_shortcut_opt_out
    d = page("/")
    b = d.at_css("button#shortcuts-toggle")
    refute_nil b
    assert d.at_css("footer.site-footer button#shortcuts-toggle")
    assert_equal "Keyboard shortcuts: on", b.text.strip
    assert b.key?("aria-pressed")
    assert_includes js, "shortcuts"
  end
end
