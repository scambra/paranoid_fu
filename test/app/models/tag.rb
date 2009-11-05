class Tag < ActiveRecord::Base
  has_many :taggings
  has_many :widgets, :through => :taggings
end
