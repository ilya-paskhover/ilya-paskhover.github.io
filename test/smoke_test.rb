require_relative "test_helper"

class SmokeTest < Minitest::Test
  POST_URLS = Dir.glob(File.join(SRC, "_posts", "*")).map do |f|
    m = File.basename(f).match(/\A(\d{4})-(\d{2})-(\d{2})-(.+)\.(markdown|md)\z/)
    cats = File.read(f, encoding: "UTF-8")[/\A---\s*\n(.*?)\n---/m, 1].to_s[/^categories:\s*(.+)$/, 1].to_s.split
    "/" + (cats + [m[1], m[2], m[3], "#{m[4]}.html"]).join("/")
  end

  def test_seven_posts
    assert_equal 7, POST_URLS.size
  end

  def test_urls_return_200
    paths = ["/", "/about/", "/feed.xml", "/css/main.css", "/shallow-whale/",
             "/assets/html_apps/math_bubbles.html"] + POST_URLS
    paths.each do |p|
      assert_equal "200", http_get(p).code, "GET #{p}"
    end
  end

  def test_shallow_whale_identical
    assert_equal File.binread(File.join(SRC, "shallow-whale/index.html")),
                 File.binread(File.join(SITE, "shallow-whale/index.html"))
  end

  def test_excluded_files_absent
    %w[docs test README.md Dockerfile Gemfile].each do |n|
      refute File.exist?(File.join(SITE, n)), "#{n} should not be in _site"
    end
  end

  def test_internal_links_resolve
    own_pages.each do |f|
      doc = Nokogiri::HTML(File.read(f, encoding: "UTF-8"))
      doc.css("[href], [src]").each do |el|
        ref = el["href"] || el["src"]
        next if ref.nil? || ref.empty? || ref == "#" || ref.start_with?("#")
        next unless ref.start_with?("/") && !ref.start_with?("//")
        assert File.file?(site_file(ref)), "#{f.sub(SITE, '')} links to missing #{ref}"
      end
    end
  end
end
