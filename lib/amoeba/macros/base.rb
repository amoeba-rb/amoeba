# frozen_string_literal: true

module Amoeba
  module Macros
    class Base
      def initialize(cloner)
        @cloner     = cloner
        @old_object = cloner.old_object
        @new_object = cloner.new_object
        @options    = cloner.options
      end

      def follow(_relation_name, _association)
        raise "#{self.class.name} doesn't implement `follow`!"
      end

      class << self
        def inherited(klass)
          ::Amoeba::Macros.add(klass)
        end
      end

      def remapped_relation_name(name)
        return name unless @cloner.amoeba.remap_method

        @old_object.__send__(@cloner.amoeba.remap_method, name.to_sym) || name
      end
    end
  end
end
