module ActsAsParanoid #:nodoc:
  module Associations
    # === Options
    # [:without_deleted]
    #  Don't load associated object if it's deleted.
    def belongs_to(association_id, options = {})
      without_deleted = options.delete :without_deleted
      returning super(association_id, options) do
        restore_without_deleted(association_id, without_deleted)
      end
    end
  
    def has_many(association_id, options = {}, &extension)
      without_deleted = options.delete :without_deleted
      returning super(association_id, options, &extension) do
        restore_without_deleted(association_id, without_deleted)
      end
    end
  
    protected
    def restore_without_deleted(association_id, value)
      if value
        reflection = reflect_on_association(association_id)
        reflection.options[:without_deleted] = value
        # has_many :through doesn't use sanitized_conditions, so we set the conditions in options hash
        reflection.options[:conditions] = reflection.sanitized_conditions unless reflection.options[:polymorphic]
      end
    end
  end
end