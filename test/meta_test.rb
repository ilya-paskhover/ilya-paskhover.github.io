require_relative "test_helper"

class MetaTest < Minitest::Test
  def test_titles
    assert_equal "Ilya Paskhover | Senior software developer", page("/").at("title").text.strip
    assert page("/about/").at("title").text.strip.start_with?("About")
    assert page("/projects/").at("title").text.strip.start_with?("Projects")
  end

  def test_seo_tags_on_own_pages
    assert own_pages.size > 3
    own_pages.each do |f|
      doc = Nokogiri::HTML(File.read(f, encoding: "UTF-8"))
      assert doc.at('meta[property="og:title"]'), "og:title missing in #{f}"
      canon = doc.at('link[rel="canonical"]')
      assert canon && canon["href"].start_with?("https://ilya-paskhover.github.io"), "canonical in #{f}"
      assert doc.at('link[rel="alternate"][type="application/atom+xml"]'), "atom link in #{f}"
    end
  end

  def test_favicon_and_theme_color
    doc = page("/")
    assert doc.at('link[rel="icon"][href="/favicon.svg"]')
    assert doc.at('meta[name="theme-color"][content="#141414"]')
    f = File.join(SITE, "favicon.svg")
    assert File.file?(f)
    assert_includes File.read(f, encoding: "UTF-8"), "IP"
  end

  def test_feed
    refute File.exist?(File.join(SRC, "feed.xml"))
    xml = Nokogiri::XML(File.read(File.join(SITE, "feed.xml"), encoding: "UTF-8"))
    assert_equal "feed", xml.root.name
    assert_includes xml.to_s, "Vibe coding apps"
  end

  def test_sitemap
    s = File.read(File.join(SITE, "sitemap.xml"), encoding: "UTF-8")
    assert_includes s, "https://ilya-paskhover.github.io/projects/"
    assert_includes s, "https://ilya-paskhover.github.io/about/"
    refute_includes s, "googlec97749bedfe403e3"
  end
end
