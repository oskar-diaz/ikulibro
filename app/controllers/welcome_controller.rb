class WelcomeController < ApplicationController

  def index
    @featured_review = pick_featured_review
  end

  private

  def pick_featured_review
    reviews = spreadsheet_reviews
    reviews = local_reviews if reviews.empty?
    reviews = reviews.select { |review| review.review.to_s.strip.present? }
    return nil if reviews.empty?

    reviews.sample
  end

  def spreadsheet_reviews
    urls = [
      ENV.fetch("REVIEWS_CSV_URL_CROWDFUNDING", ENV.fetch("REVIEWS_CSV_URL", "")).to_s,
      ENV.fetch("REVIEWS_CSV_URL_AMAZON", "").to_s
    ].map(&:strip).reject(&:empty?).uniq

    urls
      .flat_map { |url| ReviewStore.from_csv_url(url) }
      .uniq { |review| "#{review.id}|#{review.name}|#{review.review}" }
  end

  def local_reviews
    ReviewStore
      .send(:load_from_yaml)
      .sort_by { |review| review.created_at.to_s }
      .reverse
  rescue StandardError
    []
  end
end
