class Order < ActiveRecord::Base
  belongs_to :item, :polymorphic => true, :without_deleted => true
  belongs_to :any_item, :polymorphic => true, :foreign_key => 'item_id', :foreign_type => 'item_type'
end
