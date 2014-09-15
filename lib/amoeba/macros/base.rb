module Amoeba
  module Macros
    class Base
      def initialize(cloner)
        @cloner = cloner
        @old_object = cloner.old_object
        @new_object = cloner.new_object
      end

      def follow(_relation_name, _association)
        fail 'need to be implemented in specific macros'
      end
    end
  end
end
