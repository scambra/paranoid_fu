class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :widget
  paranoid_fu
end
