class SitemapsController < ApplicationController
  layout false

  def index
    base_url = request.base_url
    lastmod = Date.current.iso8601
    @urls = [
      { loc: "#{base_url}#{root_path}", changefreq: "weekly", priority: "1.0", lastmod: lastmod },
      { loc: "#{base_url}#{reviews_path}", changefreq: "weekly", priority: "0.7", lastmod: lastmod }
    ]
  end
end
