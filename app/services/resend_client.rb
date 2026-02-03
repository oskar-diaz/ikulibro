# frozen_string_literal: true

require "net/http"
require "json"
require "erb"

class ResendClient
  API_URL = URI("https://api.resend.com/emails")

  def self.send_order(name:, email:, comments:)
    api_key = ENV.fetch("RESEND_API_KEY")
    from = ENV.fetch("RESEND_FROM")
    to = ENV.fetch("RESEND_TO", from)

    payload = {
      from: from,
      to: [to],
      subject: "Nueva reseña del Ikulibro",
      replyTo: email.to_s.empty? ? nil : email,
      html: build_html(name: name, email: email, comments: comments)
    }

    response = post_json(API_URL, api_key, payload)

    return true if response.is_a?(Net::HTTPSuccess)

    raise "Resend API error: #{response.code} #{response.message}"
  end

  def self.build_html(name:, email:, comments:)
    h = ERB::Util.method(:html_escape)
    <<~HTML
      <h2>Nueva reseña del Ikulibro</h2>
      <p><strong>Nombre:</strong> #{h.call(name)}</p>
      #{email_block(email)}
      <p><strong>Reseña:</strong><br/>#{h.call(comments).gsub("\n", "<br/>")}</p>
    HTML
  end

  def self.email_block(email)
    return "" if email.to_s.strip.empty?

    h = ERB::Util.method(:html_escape)
    "<p><strong>Email:</strong> #{h.call(email)}</p>"
  end

  def self.post_json(uri, api_key, payload)
    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Bearer #{api_key}"
    request["Content-Type"] = "application/json"
    request.body = JSON.dump(payload)

    Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
  end

  private_class_method :build_html, :post_json, :email_block
end
