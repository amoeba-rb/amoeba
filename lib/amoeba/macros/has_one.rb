module Amoeba
  module Macros
    class HasOne < ::Amoeba::Macros::Base
      def follow(relation_name, association)
        return if association.is_a?(::ActiveRecord::Reflection::ThroughReflection)
        old_obj = @old_object.__send__(relation_name)
        return unless old_obj
        copy_of_obj = old_obj.amoeba_dup(@options)
        copy_of_obj[:"#{association.foreign_key}"] = nil
        relation_name = remapped_relation_name(relation_name)
        @new_object.__send__(:"#{relation_name}=", copy_of_obj)
      end
    end
  end
end
