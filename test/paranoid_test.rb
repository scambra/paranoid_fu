require File.join(File.dirname(__FILE__), 'test_helper')

class ParanoidTest < ActiveSupport::TestCase
  fixtures :categories, :widgets, :categories_widgets, :tags, :taggings, :orders
  
  def test_without_deleted_scope
    assert_equal [1, 2], Widget.all.ids
    assert_equal [1], Widget.without_deleted.all.ids
  end
  
  def test_only_deleted_scope
    assert_equal [2], Widget.only_deleted.all.ids
    assert_equal [1, 2], Widget.all.ids
  end
  
  def test_should_exists_with_deleted
    assert Widget.exists?(2)
    assert !Widget.without_deleted.exists?(2)
  end

  def test_should_exists_only_deleted
    assert Widget.only_deleted.exists?(2)
    assert !Widget.only_deleted.exists?(1)
  end

  def test_should_count_with_deleted
    assert_equal 1, Widget.without_deleted.count
    assert_equal 2, Widget.count
    assert_equal 1, Widget.only_deleted.count
    assert_equal 2, Widget.calculate(:count, :all)
    assert_equal 1, Widget.without_deleted.calculate(:count, :all)
  end

  def test_should_set_deleted_at
    assert_equal 1, Widget.without_deleted.count
    assert_equal 1, Category.without_deleted.count
    widgets(:widget_1).destroy
    assert_equal 0, Widget.without_deleted.count
    assert_equal 0, Category.without_deleted.count
    assert_equal 2, Widget.count
    assert_equal 4, Category.count
  end
  
  def test_should_destroy
    assert_equal 1, Widget.without_deleted.count
    assert_equal 1, Category.without_deleted.count
    widgets(:widget_1).destroy!
    assert_equal 0, Widget.without_deleted.count
    assert_equal 0, Category.without_deleted.count
    assert_equal 1, Widget.only_deleted.count
    assert_equal 1, Widget.count
    # Category doesn't get destroyed because the dependent before_destroy callback uses #destroy
    assert_equal 4, Category.count
  end
  
  def test_should_set_deleted_at_when_delete_all
    assert_equal 1, Widget.without_deleted.count
    assert_equal 2, Widget.count
    assert_equal 1, Category.without_deleted.count
    Widget.delete_all
    assert_equal 0, Widget.without_deleted.count
    # delete_all doesn't call #destroy, so the dependent callback never fires
    assert_equal 1, Category.without_deleted.count
    assert_equal 2, Widget.count
  end
  
  def test_should_set_deleted_at_when_delete_all_with_conditions
    assert_equal 1, Widget.without_deleted.count
    assert_equal 2, Widget.count
    Widget.delete_all("id < 3")
    assert_equal 0, Widget.without_deleted.count
    assert_equal 2, Widget.count
  end
  
  def test_should_delete_all
    assert_equal 1, Category.without_deleted.count
    assert_equal 4, Category.count
    Category.delete_all!
    assert_equal 0, Category.without_deleted.count
    assert_equal 0, Category.count
  end
  
  def test_should_delete_all_with_conditions
    assert_equal 1, Category.without_deleted.count
    assert_equal 4, Category.count
    Category.delete_all!("id < 3")
    assert_equal 0, Category.without_deleted.count
    assert_equal 2, Category.count
  end
  
  def test_should_not_count_deleted
    assert_equal 1, Widget.without_deleted.count
    assert_equal 1, Widget.without_deleted.count(:all, :conditions => ['title=?', 'widget 1'])
    assert_equal 2, Widget.count
    assert_equal 1, Widget.only_deleted.count
  end
  
  def test_should_find_deleted_has_many_associations
    assert_equal 2, widgets(:widget_1).categories.size
    assert_equal [categories(:category_1), categories(:category_2)], widgets(:widget_1).categories
  end
  
  def test_should_not_find_deleted_has_many_associations
    assert_equal 1, widgets(:widget_1).categories.without_deleted.size
    assert_equal [categories(:category_1)], widgets(:widget_1).categories.without_deleted
  end
  
  def test_should_find_deleted_habtm_associations
    assert_equal 2, widgets(:widget_1).habtm_categories.size
    assert_equal [categories(:category_1), categories(:category_2)], widgets(:widget_1).habtm_categories
  end
  
  def test_should_not_find_deleted_habtm_associations
    assert_equal 1, widgets(:widget_1).habtm_categories.without_deleted.size
    assert_equal [categories(:category_1)], widgets(:widget_1).habtm_categories.without_deleted
  end
  
  def test_should_not_find_deleted_has_many_through_associations_without_deleted
    assert_equal 1, widgets(:widget_1).tags.size
    assert_equal [tags(:tag_2)], widgets(:widget_1).tags
  end
  
  def test_should_find_has_many_through_associations
    assert_equal 2, widgets(:widget_1).any_tags.size
    assert_equal Tag.find(:all), widgets(:widget_1).any_tags
  end

  def test_should_not_find_deleted_belongs_to_associations_without_deleted
    assert_nil Category.find(3).widget
  end

  def test_should_find_belongs_to_assocation
    assert_equal Widget.find(2), Category.find(3).any_widget
  end

  def test_should_not_find_deleted_belongs_to_associations_polymorphic_without_deleted
    assert_nil orders(:order_1).item
    assert_equal categories(:category_1), orders(:order_2).item
  end

  def test_should_find_deleted_belongs_to_associations_polymorphic
    assert_equal widgets(:widget_2), orders(:order_1).any_item
  end

  def test_should_find_first_with_deleted
    assert_equal widgets(:widget_1), Widget.without_deleted.first
    assert_equal 2, Widget.first(:order => 'id desc').id
  end
  
  def test_should_find_single_id
    assert Widget.without_deleted.find(1)
    assert Widget.find(2)
    assert_raises(ActiveRecord::RecordNotFound) { Widget.without_deleted.find(2) }
  end
  
  def test_should_find_multiple_ids
    assert_equal [1,2], Widget.find(1,2).sort_by { |w| w.id }.ids
    assert_equal [1,2], Widget.find([1,2]).sort_by { |w| w.id }.ids
    assert_raises(ActiveRecord::RecordNotFound) { Widget.without_deleted.find(1,2) }
  end
  
  def test_should_ignore_multiple_includes
    Widget.class_eval { paranoid_fu }
    assert Widget.find(1)
  end

  def test_should_not_override_scopes_when_counting
    assert_equal 1, Widget.send(:with_scope, :find => { :conditions => "title = 'widget 1'" }) { Widget.without_deleted.count }
    assert_equal 0, Widget.send(:with_scope, :find => { :conditions => "title = 'deleted widget 2'" }) { Widget.without_deleted.count }
    assert_equal 1, Widget.send(:with_scope, :find => { :conditions => "title = 'deleted widget 2'" }) { Widget.count }
  end

  def test_should_not_override_scopes_when_finding
    assert_equal [1], Widget.send(:with_scope, :find => { :conditions => "title = 'widget 1'" }) { Widget.without_deleted.find(:all) }.ids
    assert_equal [],  Widget.send(:with_scope, :find => { :conditions => "title = 'deleted widget 2'" }) { Widget.without_deleted.find(:all) }.ids
    assert_equal [2], Widget.send(:with_scope, :find => { :conditions => "title = 'deleted widget 2'" }) { Widget.find(:all) }.ids
  end

  def test_should_allow_multiple_scoped_calls_when_finding
    Widget.send(:with_scope, :find => { :conditions => "title = 'deleted widget 2'" }) do
      assert_equal [2], Widget.find(:all).ids
      assert_equal [2], Widget.find(:all).ids, "clobbers the constrain on the unmodified find"
      assert_equal [], Widget.without_deleted.find(:all).ids
      assert_equal [], Widget.without_deleted.find(:all).ids, 'clobbers the constrain on a paranoid find'
    end
  end

  def test_should_allow_multiple_scoped_calls_when_counting
    Widget.send(:with_scope, :find => { :conditions => "title = 'deleted widget 2'" }) do
      assert_equal 1, Widget.calculate(:count, :all)
      assert_equal 1, Widget.calculate(:count, :all), "clobbers the constrain on the unmodified find"
      assert_equal 0, Widget.without_deleted.count
      assert_equal 0, Widget.without_deleted.count, 'clobbers the constrain on a paranoid find'
    end
  end

  def test_should_give_paranoid_status
    assert Widget.paranoid?
    assert !NonParanoidAndroid.paranoid?
  end

  def test_should_give_record_status
    assert_equal false, Widget.find(1).deleted? 
    Widget.find(1).destroy
    assert Widget.find(1).deleted?
  end

  def test_should_find_deleted_has_many_assocations_on_deleted_records_by_default
    w = Widget.find 2
    assert_equal 2, w.categories.find(:all).length
    assert_equal 2, w.categories.find(:all).size
  end
  
  def test_should_find_deleted_habtm_assocations_on_deleted_records_by_default
    w = Widget.find 2
    assert_equal 2, w.habtm_categories.find(:all).length
    assert_equal 2, w.habtm_categories.find(:all).size
  end

  def test_dynamic_finders
    assert     Widget.without_deleted.find_by_id(1)
    assert_nil Widget.without_deleted.find_by_id(2)
  end

  def test_custom_finder_methods
    w = Widget.all.inject({}) { |all, w| all.merge(w.id => w) }
    assert_equal [1],       Category.search('c').ids
    assert_equal [1,2,3,4], Category.search_with_deleted('c', :order => 'id').ids
    assert_equal [1],       widgets(:widget_1).categories.search('c').collect(&:id)
    assert_equal [1,2],     widgets(:widget_1).categories.search_with_deleted('c').ids
    assert_equal [],        w[2].categories.search('c').ids
    assert_equal [3,4],     w[2].categories.search_with_deleted('c').ids
  end
  
  def test_should_recover_record
    Widget.find(1).destroy
    assert_equal true, Widget.find(1).deleted?
    
    Widget.find(1).recover!
    assert_equal false, Widget.find(1).deleted?
  end
  
  def test_should_recover_record_and_has_many_associations
    Widget.find(1).destroy
    assert_equal true, Widget.find(1).deleted?
    assert_equal true, Category.find(1).deleted?
    
    Widget.find(1).recover_with_associations!(:categories)
    assert_equal false, Widget.find(1).deleted?
    assert_equal false, Category.find(1).deleted?
  end
  
  def test_find_including_associations
    w = Widget.find(1, :include => :categories)
    assert_equal widgets(:widget_1), w
    assert_equal 2, w.instance_variable_get(:@categories).size

    c = Category.find(:first, :include => :widget, :conditions => {'widgets.title' => 'widget 1'})
    assert_equal categories(:category_1), c
    assert_equal widgets(:widget_1), c.instance_variable_get(:@widget)
    c = Category.find(3, :include => :widget)
    assert_equal categories(:category_3), c
    assert_nil c.instance_variable_get(:@widget)
    assert_raises(ActiveRecord::RecordNotFound) { Category.find(3, :include => :widget, :conditions => {'widgets.title' => 'deleted widget 2'}) }

    o = Order.find(:first, :include => :item)
    assert_equal orders(:order_1), o
    assert_nil o.instance_variable_get(:@item)
    o = Order.find(:first, :include => :any_item)
    assert_equal orders(:order_1), o
    assert_equal widgets(:widget_2), o.instance_variable_get(:@any_item)

    assert_equal 1, widgets(:widget_1).non_deleted_habtm_categories.size
    assert_equal [categories(:category_1)], widgets(:widget_1).non_deleted_habtm_categories
    w = Widget.find(1, :include => :non_deleted_habtm_categories, :conditions => {'categories.title' => 'category 1'})
    assert_equal [categories(:category_1)], w.non_deleted_habtm_categories
    assert_raises(ActiveRecord::RecordNotFound) do
      Widget.find(1, :include => :non_deleted_habtm_categories, :conditions => {'categories.title' => 'category 2'})
    end
  end
end

class Array
  def ids
    collect &:id
  end
end
