class ReviewsController < ApplicationController

  def index
    crowdfunding_url = ENV.fetch("REVIEWS_CSV_URL_CROWDFUNDING", ENV.fetch("REVIEWS_CSV_URL", "")).to_s
    amazon_url = ENV.fetch("REVIEWS_CSV_URL_AMAZON", "").to_s

    @reviews_crowdfunding = ReviewStore.from_csv_url(crowdfunding_url)
    @reviews_amazon = ReviewStore.from_csv_url(amazon_url)
  end

end
