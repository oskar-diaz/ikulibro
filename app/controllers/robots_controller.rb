class RobotsController < ApplicationController
  layout false

  def index
    base_url = request.base_url
    lines = []
    lines << "User-agent: *"
    lines << "Allow: /"
    lines << "Sitemap: #{base_url}/sitemap.xml"
    render plain: lines.join("\n")
  end
end
