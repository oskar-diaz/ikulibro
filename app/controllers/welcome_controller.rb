class WelcomeController < ApplicationController

  def index
    excluded_review_ids = requested_excluded_review_ids
    @featured_review = pick_featured_review(excluded_review_ids: excluded_review_ids)
  end

  def featured_review
    excluded_review_ids = requested_excluded_review_ids
    @featured_review = pick_featured_review(excluded_review_ids: excluded_review_ids)

    return head :no_content unless @featured_review

    render partial: "featured_review", locals: { featured_review: @featured_review }
  end

  private

  def pick_featured_review(excluded_review_ids: [])
    reviews = available_reviews.select { |review| review.review.to_s.strip.present? }
    return nil if reviews.empty?

    filtered_reviews = reviews.reject { |review| excluded_review_ids.include?(review.id.to_s) }
    pool = filtered_reviews.any? ? filtered_reviews : reviews
    pool.sample
  end

  def available_reviews
    reviews = spreadsheet_reviews
    reviews = local_reviews if reviews.empty?
    reviews
  end

  def requested_excluded_review_ids
    Array(params[:exclude_review_id]).map(&:to_s).reject(&:empty?)
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
