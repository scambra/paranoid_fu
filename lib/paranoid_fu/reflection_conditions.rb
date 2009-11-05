module ParanoidFu
  module ReflectionConditions
    def self.included(base)
      base.class_eval do
        alias_method_chain :sanitized_conditions, :paranoid_fu
      end
    end
  
    # Returns the SQL string that corresponds to the <tt>:conditions</tt>
    # option of the macro, if given, or +nil+ otherwise.
    def sanitized_conditions_with_paranoid_fu
      sanitized_conditions_without_paranoid_fu
      if !self.options[:polymorphic] && self.options.delete(:without_deleted)
        klass = if self.through_reflection
          self.through_reflection.klass
        else
          self.klass
        end
        @sanitized_conditions = klass.merge_conditions(@sanitized_conditions, klass.without_deleted_conditions(klass.table_name)) if klass
      end
      @sanitized_conditions
    end
  end
end
