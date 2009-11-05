module ActsAsParanoid
  module AssociationPreload
    def set_association_single_records(id_to_record_map, reflection_name, associated_records, key)
      reflection = reflect_on_association(reflection_name)
      # only it's needed to reject deleted records for polymorphic belongs_to, because in other case deleted records won't be loaded
      if reflection.options[:without_deleted] && reflection.options[:polymorphic]
        associated_records.delete_if {|item| item.class.paranoid? && item.deleted?}
      end
      super
    end
  end
end