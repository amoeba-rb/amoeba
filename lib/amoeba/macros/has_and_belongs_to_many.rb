module Amoeba
  module Macros
    class HasAndBelongsToMany < ::Amoeba::Macros::Base
      def follow(relation_name, _association)
        if @cloner.amoeba.clones.include?(relation_name.to_sym)
          @old_object.__send__(relation_name).each do |old_obj|
            # associate this new child to the new parent object
            @new_object.__send__(relation_name) << old_obj.amoeba_dup
          end
        else
          @old_object.__send__(relation_name).each do |old_obj|
            # associate this new child to the new parent object
            @new_object.__send__(relation_name) << old_obj
          end
        end
      end
    end
  end
end
