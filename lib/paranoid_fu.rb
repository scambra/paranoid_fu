module ParanoidFu; end
ActiveRecord::Associations::BelongsToPolymorphicAssociation.send :include, ParanoidFu::BelongsToPolymorphicAssociation
ActiveRecord::Reflection::MacroReflection.send :include, ParanoidFu::ReflectionConditions
ActiveRecord::Base.send :extend, ParanoidFu::Associations
ActiveRecord::Base.send :extend, ParanoidFu::AssociationPreload
ActiveRecord::Base.send :include, ParanoidFu::Paranoid
