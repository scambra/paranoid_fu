module ActsAsParanoid #:nodoc:
  # Overrides some basic methods for the current model so that calling #destroy sets a 'deleted_at' field to the current timestamp.
  # This assumes the table has a deleted_at date/time field.  Most normal model operations will work, but there will be some oddities.
  #
  #   class Widget < ActiveRecord::Base
  #     acts_as_paranoid
  #   end
  #
  #   Widget.find(:all)
  #   # SELECT * FROM widgets WHERE widgets.deleted_at IS NULL
  #
  #   Widget.find(:first, :conditions => ['title = ?', 'test'], :order => 'title')
  #   # SELECT * FROM widgets WHERE widgets.deleted_at IS NULL AND title = 'test' ORDER BY title LIMIT 1
  #
  #   Widget.find_with_deleted(:all)
  #   # SELECT * FROM widgets
  #
  #   Widget.find_only_deleted(:all)
  #   # SELECT * FROM widgets WHERE widgets.deleted_at IS NOT NULL
  #
  #   Widget.find_with_deleted(1).deleted?
  #   # Returns true if the record was previously destroyed, false if not 
  #
  #   Widget.count
  #   # SELECT COUNT(*) FROM widgets WHERE widgets.deleted_at IS NULL
  #
  #   Widget.count ['title = ?', 'test']
  #   # SELECT COUNT(*) FROM widgets WHERE widgets.deleted_at IS NULL AND title = 'test'
  #
  #   Widget.count_with_deleted
  #   # SELECT COUNT(*) FROM widgets
  #
  #   Widget.count_only_deleted
  #   # SELECT COUNT(*) FROM widgets WHERE widgets.deleted_at IS NOT NULL
  #
  #   Widget.delete_all
  #   # UPDATE widgets SET deleted_at = '2005-09-17 17:46:36'
  #
  #   Widget.delete_all!
  #   # DELETE FROM widgets
  #
  #   @widget.destroy
  #   # UPDATE widgets SET deleted_at = '2005-09-17 17:46:36' WHERE id = 1
  #
  #   @widget.destroy!
  #   # DELETE FROM widgets WHERE id = 1
  # 
  module Paranoid
    def self.included(base) # :nodoc:
      base.extend ClassMethods
    end

    module ClassMethods
      def acts_as_paranoid(options = {})
        unless paranoid? # don't let AR call this twice
          cattr_accessor :deleted_attribute
          self.deleted_attribute = options[:with] || :deleted_at
          alias_method :destroy_without_callbacks!, :destroy_without_callbacks
          class << self
            alias_method :delete_all!, :delete_all
          end
          named_scope :without_deleted, lambda{ {:conditions => without_deleted_conditions} }
          named_scope :only_deleted, lambda{ {:conditions => only_deleted_conditions} }
        end
        include InstanceMethods
      end

      def paranoid?
        self.included_modules.include?(InstanceMethods)
      end
    end

    module InstanceMethods #:nodoc:
      def self.included(base) # :nodoc:
        base.extend ClassMethods
      end

      module ClassMethods
        def delete_all(conditions = nil)
          self.update_all ["#{self.deleted_attribute} = ?", current_time], conditions
        end

        def without_deleted_conditions(table_name = table_name)
          ["#{table_name}.#{deleted_attribute} IS NULL OR #{table_name}.#{deleted_attribute} > ?", current_time]
        end

        def only_deleted_conditions(table_name = table_name)
          ["#{table_name}.#{deleted_attribute} IS NOT NULL AND #{table_name}.#{deleted_attribute} <= ?", current_time]
        end

        protected
        def current_time
          default_timezone == :utc ? Time.now.utc : Time.now
        end
      end

      def destroy_without_callbacks
        unless new_record?
          self.class.update_all self.class.send(:sanitize_sql, ["#{self.class.deleted_attribute} = ?", (self.deleted_at = self.class.send(:current_time))]), ["#{self.class.primary_key} = ?", id]
        end
        freeze
      end

      def destroy_with_callbacks!
        return false if callback(:before_destroy) == false
        result = destroy_without_callbacks!
        callback(:after_destroy)
        result
      end

      def destroy!
        transaction { destroy_with_callbacks! }
      end

      def deleted?
        !!read_attribute(:deleted_at)
      end

      def recover!
        self.deleted_at = nil
        save!
      end
      
      def recover_with_associations!(*associations)
        self.recover!
        associations.to_a.each do |assoc|
          self.send(assoc).all.each do |a|
            a.recover! if a.class.paranoid?
          end
        end
      end
    end
  end
end
