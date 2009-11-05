module ActsAsParanoid; end
ActiveRecord::Associations::BelongsToPolymorphicAssociation.send :include, ActsAsParanoid::BelongsToPolymorphicAssociation
ActiveRecord::Reflection::MacroReflection.send :include, ActsAsParanoid::ReflectionConditions
ActiveRecord::Base.send :extend, ActsAsParanoid::Associations
ActiveRecord::Base.send :extend, ActsAsParanoid::AssociationPreload
ActiveRecord::Base.send :include, ActsAsParanoid::Paranoid
