module ParanoidFu
  module BelongsToPolymorphicAssociation
    def self.included(base)
      base.class_eval do
        alias_method_chain :find_target, :paranoid_fu
      end
    end

    def find_target_with_paranoid_fu
      old_conditions = @reflection.options[:conditions]
      if @reflection.options[:without_deleted]
        # conditions method is not called if conditions isn't set in options hash
        @reflection.options[:conditions] = association_class.merge_conditions(@reflection.options[:conditions], association_class.without_deleted_conditions(association_class.table_name))
      end
      find_target_without_paranoid_fu
    ensure
      # restore conditions in options hash
      @reflection.options[:conditions] = old_conditions
    end

    def conditions
      @conditions ||= interpolate_sql(association_class.send(:sanitize_sql, @reflection.options[:conditions])) if @reflection.options[:conditions]
    end
  end
end
