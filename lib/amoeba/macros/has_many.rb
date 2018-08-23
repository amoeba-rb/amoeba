module Amoeba
  module Macros
    class HasMany < ::Amoeba::Macros::Base

      def follow(relation_name, association)
        if @cloner.amoeba.clones.include?(relation_name.to_sym)
          follow_with_clone(relation_name, association)
        else
          follow_without_clone(relation_name, association)
        end
      end

      def follow_with_clone(relation_name, association)
        # This  is  a  M:M  "has many  through"  where  we
        # actually copy  and reassociate the  new children
        # rather than only maintaining the associations
        if @cloner.amoeba.reuse_values.include?(relation_name.to_sym)
          @new_object.__send__("#{relation_name}=", @old_object.__send__(relation_name))
          return
        end
#
        @old_object.__send__(relation_name).each do |old_obj|
          relation_name = remapped_relation_name(relation_name)
          
          # associate this new child to the new parent object
          new_object = reuse_instance(old_obj, -> do
            old_obj.amoeba_dup
          end)

          @new_object.__send__(relation_name) << new_object
        end
      end

      def follow_without_clone(relation_name, association)
        # This is a regular 1:M "has many"
        #
        # copying the children of the regular has many will
        # effectively do what is desired anyway, the through
        # association is really just for convenience usage
        # on the model
        #
        return if association.is_a?(ActiveRecord::Reflection::ThroughReflection)
        
        @old_object.__send__(relation_name).each do |old_obj|
          copy_of_obj = reuse_instance(old_obj, -> do
            copy_of_obj = old_obj.amoeba_dup(@options)
            copy_of_obj[:"#{association.foreign_key}"] = nil
            copy_of_obj
          end)

          relation_name = remapped_relation_name(relation_name)

          @new_object.__send__(relation_name) << copy_of_obj
        end
      end

    end
  end
end
