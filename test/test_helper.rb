require "minitest/autorun"
require "nokogiri"
require "net/http"
require "uri"

SITE = File.expand_path("../_site", __dir__)
SRC = File.expand_path("..", __dir__)

module SiteHelpers
  def site_file(url_path)
    path = url_path.split("#").first.split("?").first
    rel = path.sub(%r{\A/}, "")
    rel = File.join(rel, "index.html") if rel.empty? || rel.end_with?("/")
    File.join(SITE, rel)
  end

  def page(url_path)
    file = site_file(url_path)
    assert File.file?(file), "missing built file for #{url_path} (#{file})"
    Nokogiri::HTML(File.read(file, encoding: "UTF-8"))
  end

  def css
    file = File.join(SITE, "css", "main.css")
    File.file?(file) ? File.read(file, encoding: "UTF-8") : ""
  end

  def css_compact
    css.gsub(/\s+/, "")
  end

  def js
    file = File.join(SITE, "assets", "js", "site.js")
    File.file?(file) ? File.read(file, encoding: "UTF-8") : ""
  end

  def http_get(path)
    Net::HTTP.get_response(URI("http://127.0.0.1:4000#{path}"))
  end

  def own_pages
    Dir.glob(File.join(SITE, "**", "*.html")).reject do |f|
      rel = f.sub("#{SITE}/", "")
      rel.start_with?("shallow-whale/") || rel.start_with?("assets/html_apps/") || File.basename(rel).start_with?("googlec")
    end
  end
end

class Minitest::Test
  include SiteHelpers
end
