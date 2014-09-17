module Amoeba
  module Macros
    class Base
      def initialize(cloner)
        @cloner     = cloner
        @old_object = cloner.old_object
        @new_object = cloner.new_object
      end

      def follow(_relation_name, _association)
        fail "#{self.class.name} doesn't implement `follow`!"
      end

      class << self
        def inherited(klass)
          ::Amoeba::Macros.add(klass)
        end
      end
    end
  end
end
