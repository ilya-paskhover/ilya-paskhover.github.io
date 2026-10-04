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
    d = page("/jekyll/update/2015/12/29/welcome-to-jekyll.html")
    note = d.at_css(".post-archived-note")
    refute_nil note
    assert_equal "This is an archived note from 2015.", note.text.strip
    refute_includes note.text, "2016"
    links = d.css("nav.post-tree ul.post-tree-fallback a")
    assert_equal ["Overview"], links.map { |a| a.text.strip }
    assert_equal "#post-body", links.first["href"]
  end

  def test_welcome_old_url_redirects
    old = page("/jekyll/update/2016/03/17/welcome-to-jekyll.html")
    target = "/jekyll/update/2015/12/29/welcome-to-jekyll.html"
    assert_includes old.at_css("link[rel=canonical]")["href"], target
    assert_includes old.at_css("meta[http-equiv=refresh]")["content"], target
    # relative, so the redirect also works on localhost and previews
    assert_equal "0; url=#{target}", old.at_css("meta[http-equiv=refresh]")["content"]
    assert_equal target, old.at_css("main a")["href"]
    assert_equal "Welcome to Jekyll!", page(target).at_css("h1.post-title").text.strip
    assert_equal "Dec 29, 2015", page(target).at_css("dl.post-meta-grid time").text.strip
    sitemap = File.read(site_file("/sitemap.xml"), encoding: "UTF-8")
    assert_includes sitemap, target
    refute_includes sitemap, "2016/03/17/welcome-to-jekyll"
  end

  def test_reading_time_matches_between_list_and_post
    post = page("/2026/10/04/how-github-pages-publishes-a-site.html")
    meta = post.css("dl.post-meta-grid dd").last.text.strip
    row = page("/").css("ol.post-list > li").find { |r| r.text.include?("How GitHub Pages publishes a site") }
    list = row.at_css(".reading-time").text.strip
    assert_equal meta[/\d+/], list[/\d+/], "list and post page must agree"
    refute_nil list[/\d+/]
  end

  def test_github_pages_post
    d = page("/2026/10/04/how-github-pages-publishes-a-site.html")
    assert_equal "How GitHub Pages publishes a site", d.at_css("h1.post-title").text.strip
    assert_equal "Notes", d.at_css(".post-topic").text.strip
    assert_equal 6, d.css("nav.post-tree ul#markdown-toc a").size
    assert_equal 1, d.css("#markdown-toc").size
    refute_includes d.text, "ushastikin"
    link = d.at_css(".post-content a[href$='public-the-blog-on-github-io.html']")
    refute_nil link
    assert_equal "An early note about publishing this blog", link.text.strip
    assert_equal "/jekyll/update/2016/03/17/public-the-blog-on-github-io.html", link["href"]
    assert File.file?(site_file(link["href"]))
    assert_equal "Public the blog on github.io!", page(link["href"]).at_css("h1.post-title").text.strip
  end

  def test_restored_2016_post
    url = "/jekyll/update/2016/03/17/public-the-blog-on-github-io.html"
    d = page(url)
    assert_equal "Public the blog on github.io!", d.at_css("h1.post-title").text.strip
    assert_equal "Notes", d.at_css(".post-topic").text.strip
    assert_equal "This is an archived note from 2016.", d.at_css(".post-archived-note").text.strip
    assert_includes d.at_css(".post-content").text, "To make this blog always accessible, I have pushed it to GitHub as a user site on github.io"
    back = d.at_css(".post-content em a")
    refute_nil back
    assert_equal "/2026/10/04/how-github-pages-publishes-a-site.html", back["href"]
    assert_includes d.at_css(".post-content em").text, "Update, 2026:"
    assert File.file?(site_file(back["href"]))
  end
end
