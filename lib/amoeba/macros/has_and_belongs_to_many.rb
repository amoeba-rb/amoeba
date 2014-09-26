module Amoeba
  module Macros
    class HasAndBelongsToMany < ::Amoeba::Macros::Base
      def follow(relation_name, _association)
        clone = @cloner.amoeba.clones.include?(relation_name.to_sym)
        @old_object.__send__(relation_name).each do |old_obj|
          fill_relation(relation_name, old_obj, clone)
        end
      end

      def fill_relation(relation_name, old_obj, clone)
        # associate this new child to the new parent object
        old_obj = old_obj.amoeba_dup if clone
        relation_name = remapped_relation_name(relation_name)
        @new_object.__send__(relation_name) << old_obj
      end
    end
  end
end
