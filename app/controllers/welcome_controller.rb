class WelcomeController < ApplicationController

  def index
  end

  def featured_review
    excluded_review_ids = requested_excluded_review_ids
    @featured_review_candidate = pick_featured_review(excluded_review_ids: excluded_review_ids)

    return head :no_content unless @featured_review_candidate

    render partial: "featured_review", locals: {
      featured_review: @featured_review_candidate[:review],
      featured_review_source: @featured_review_candidate[:edition_label],
      featured_review_uid: @featured_review_candidate[:uid]
    }
  end

  private

  def pick_featured_review(excluded_review_ids: [])
    candidates = available_review_candidates.select { |candidate| candidate[:review].review.to_s.strip.present? }
    return nil if candidates.empty?

    filtered_reviews = candidates.reject { |candidate| excluded_review_ids.include?(candidate[:uid].to_s) }
    pool = filtered_reviews.any? ? filtered_reviews : candidates
    pool.sample
  end

  def available_review_candidates
    candidates = spreadsheet_review_candidates
    candidates = local_review_candidates if candidates.empty?
    candidates
  end

  def requested_excluded_review_ids
    Array(params[:exclude_review_id]).map(&:to_s).reject(&:empty?)
  end

  def spreadsheet_review_candidates
    candidates = []

    if crowdfunding_reviews_url.strip.present?
      candidates += ReviewStore.from_csv_url(crowdfunding_reviews_url).map do |review|
        build_review_candidate(review, "crowdfunding", "Primera edición")
      end
    end

    if second_tab_reviews_url.strip.present?
      candidates += ReviewStore.from_csv_url(second_tab_reviews_url).map do |review|
        build_review_candidate(review, "second_tab", "Reedición")
      end
    end

    candidates.uniq { |candidate| candidate[:uid] }
  end

  def local_reviews
    ReviewStore
      .send(:load_from_yaml)
      .sort_by { |review| review.created_at.to_s }
      .reverse
  rescue StandardError
    []
  end

  def local_review_candidates
    local_reviews.map { |review| build_review_candidate(review, "local", "Primera edición") }
  end

  def crowdfunding_reviews_url
    ENV.fetch("REVIEWS_CSV_URL_CROWDFUNDING", ENV.fetch("REVIEWS_CSV_URL", "")).to_s
  end

  def second_tab_reviews_url
    ENV["REVIEWS_CSV_URL_AMAZON"].presence ||
      ENV["REVIEWS_CSV_URL_SECOND_TAB"].presence ||
      ENV["REVIEWS_CSV_URL_TAB_2"].presence ||
      ""
  end

  def build_review_candidate(review, source_key, edition_label)
    stable_key = review.id.presence || "#{review.name}|#{review.created_at}|#{review.review.to_s.first(50)}"
    {
      uid: "#{source_key}:#{stable_key}",
      review: review,
      edition_label: edition_label
    }
  end
end
