# frozen_string_literal: true

require "csv"
require "net/http"
require "uri"
require "yaml"

class ReviewEntry
  attr_reader :id, :name, :review, :created_at, :updated_at, :images

  def initialize(id:, name:, review:, created_at:, updated_at:, images: [])
    @id = id
    @name = name
    @review = review
    @created_at = created_at
    @updated_at = updated_at
    @images = images
  end
end

class ReviewImage
  attr_reader :id, :url, :created_at, :updated_at

  def initialize(id:, url:, created_at:, updated_at:)
    @id = id
    @url = url
    @created_at = created_at
    @updated_at = updated_at
  end
end

class ReviewStore
  DATA_PATH = Rails.root.join("data", "reviews.yml")
  CSV_URL_ENV = "REVIEWS_CSV_URL"
  CSV_CACHE_TTL = 60

  class << self
    def all_desc
      all.sort_by { |r| r.created_at.to_s }.reverse
    end

    def all
      reload_if_changed!
      @all ||= load_entries
    end

    def from_csv_url(url)
      url = url.to_s.strip
      return [] if url.empty?

      cache_entry = csv_cache[url]
      if cache_entry && (Time.now - cache_entry[:fetched_at]) < CSV_CACHE_TTL
        return cache_entry[:entries]
      end

      entries = load_from_csv(url) || []
      csv_cache[url] = { entries: entries, fetched_at: Time.now }
      entries
    end

    def reload!
      @all = load_entries
      if csv_url?
        @csv_fetched_at = Time.now
      else
        @mtime = data_mtime
      end
      @all
    end

    private

    def reload_if_changed!
      if csv_url?
        reload_csv_if_stale!
      else
        current_mtime = data_mtime
        reload! if @mtime != current_mtime
      end
    end

    def data_mtime
      File.exist?(DATA_PATH) ? File.mtime(DATA_PATH) : nil
    end

    def load_entries
      if csv_url?
        entries = load_from_csv(csv_url)
        return entries if entries
        raise "REVIEWS_CSV_URL set but CSV could not be loaded"
      end

      load_from_yaml
    end

    def load_from_yaml
      raw = File.exist?(DATA_PATH) ? YAML.load_file(DATA_PATH) : {}
      items = raw["reviews"] || []

      items.map do |item|
        images = Array(item["images"]).map do |img|
          ReviewImage.new(
            id: img["id"],
            url: img["url"],
            created_at: img["created_at"],
            updated_at: img["updated_at"]
          )
        end

        ReviewEntry.new(
          id: item["id"],
          name: item["name"],
          review: item["review"],
          created_at: item["created_at"],
          updated_at: item["updated_at"],
          images: images
        )
      end
    end

    def csv_url
      ENV.fetch(CSV_URL_ENV, "").strip
    end

    def csv_url?
      !csv_url.empty?
    end

    def reload_csv_if_stale!
      return if @csv_fetched_at && (Time.now - @csv_fetched_at) < CSV_CACHE_TTL

      reload!
    end

    def load_from_csv(url)
      response = fetch_csv_response(url)
      unless response&.is_a?(Net::HTTPSuccess)
        Rails.logger.warn("ReviewStore CSV HTTP error: #{response&.code} #{response&.message}")
        return nil
      end

      csv_text = response.body.dup
      csv_text.force_encoding("UTF-8")
      csv_text = csv_text.encode("UTF-8", invalid: :replace, undef: :replace, replace: "")

      CSV.parse(csv_text, headers: true).map do |row|
        images = split_images(row["images"]).map.with_index(1) do |url, idx|
          ReviewImage.new(
            id: "#{row['id']}-#{idx}",
            url: url,
            created_at: row["created_at"],
            updated_at: row["updated_at"]
          )
        end

        ReviewEntry.new(
          id: row["id"],
          name: row["name"],
          review: row["review"],
          created_at: row["created_at"],
          updated_at: row["updated_at"],
          images: images
        )
      end
    rescue CSV::MalformedCSVError => e
      Rails.logger.warn("ReviewStore CSV malformed: #{e.message}")
      Rails.logger.warn("ReviewStore CSV preview: #{response&.body&.slice(0, 200)}")
      nil
    rescue StandardError => e
      Rails.logger.warn("ReviewStore CSV load failed: #{e.class}: #{e.message}")
      Rails.logger.warn("ReviewStore CSV preview: #{response&.body&.slice(0, 200)}")
      nil
    end

    def split_images(value)
      value.to_s.split("|").map(&:strip).reject(&:empty?)
    end

    def csv_cache
      @csv_cache ||= {}
    end

    def fetch_csv_response(url, limit = 5)
      return nil if limit <= 0

      uri = URI.parse(url)
      response = Net::HTTP.get_response(uri)
      return response unless response.is_a?(Net::HTTPRedirection)

      location = response["location"]
      Rails.logger.info("ReviewStore CSV redirect: #{response.code} -> #{location}")
      fetch_csv_response(location, limit - 1)
    end
  end
end
