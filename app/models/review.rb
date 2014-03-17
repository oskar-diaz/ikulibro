class Review < ActiveRecord::Base

  has_many :images
  scope :desc, order("created_at DESC")

end
