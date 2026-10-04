require_relative "test_helper"

class ContentTest < Minitest::Test
  POSTS = %w[
    /jekyll/update/2016/03/17/about-this-blog.html
    /jekyll/update/2016/03/17/small-summary-for-linux-kernel-course.html
    /jekyll/update/2015/12/29/welcome-to-jekyll.html
  ].freeze

  def test_no_typos_in_2016_posts
    POSTS.each do |p|
      text = page(p).text
      refute_match(/wiht/, text, p)
      refute_match(/direcroy/, text, p)
      refute_match(/\bi\b/, page(p).css("article, .post-content, main").text.gsub(/'[^']*'/, ""), "lowercase pronoun i in #{p}")
    end
  end

  def test_linux_post_has_no_empty_li
    doc = page(POSTS[1])
    items = doc.css("li")
    assert items.size >= 4
    items.each { |li| refute_empty li.text.strip, "empty li" }
    assert_includes doc.text, "directory"
  end

  def test_readme
    readme = File.read(File.join(SRC, "README.md"), encoding: "UTF-8")
    ["docker compose up -d --build --force-recreate --wait", "http://localhost:14000", "topic:", "{:toc}", "* TOC", "featured", "description"].each do |s|
      assert_includes readme, s
    end
  end
end
