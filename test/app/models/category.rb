class Category < ActiveRecord::Base
  paranoid_fu
  belongs_to :widget, :without_deleted => true
  belongs_to :any_widget, :class_name => 'Widget', :foreign_key => 'widget_id'

  def self.search(name, options = {})
    without_deleted.all options.merge(:conditions => ['LOWER(title) LIKE ?', "%#{name.to_s.downcase}%"])
  end

  def self.search_with_deleted(name, options = {})
    all options.merge(:conditions => ['LOWER(title) LIKE ?', "%#{name.to_s.downcase}%"])
  end
end
