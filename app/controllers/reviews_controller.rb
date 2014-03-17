class ReviewsController < ApplicationController

  def index
    @reviews = Review.all.desc
  end
end
