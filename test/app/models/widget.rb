class Widget < ActiveRecord::Base
  paranoid_fu
  has_many :categories, :dependent => :destroy
  has_and_belongs_to_many :habtm_categories, :class_name => 'Category'
  has_and_belongs_to_many :non_deleted_habtm_categories, :class_name => 'Category', :without_deleted => true
  has_one :category
  belongs_to :parent_category, :class_name => 'Category'
  has_many :taggings
  has_many :tags, :through => :taggings, :without_deleted => true
  has_many :any_tags, :through => :taggings, :class_name => 'Tag', :source => :tag
end
