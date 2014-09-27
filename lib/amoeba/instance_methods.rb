module Amoeba
  module InstanceMethods
    def _parent_amoeba
      if _first_superclass_with_amoeba.respond_to?(:amoeba)
        _first_superclass_with_amoeba.amoeba
      else
        false
      end
    end

    def _first_superclass_with_amoeba
      return @_first_superclass_with_amoeba unless @_first_superclass_with_amoeba.nil?
      klass = self.class
      while klass.superclass < ::ActiveRecord::Base
        klass = klass.superclass
        break if klass.respond_to?(:amoeba) && klass.amoeba.enabled
      end
      @_first_superclass_with_amoeba = klass
    end

    def _amoeba_settings
      self.class.amoeba_block
    end

    def _parent_amoeba_settings
      if _first_superclass_with_amoeba.respond_to?(:amoeba_block)
        _first_superclass_with_amoeba.amoeba_block
      else
        false
      end
    end

    def amoeba_dup(options = {})
      ::Amoeba::Cloner.new(self, options).run
    end
  end
end
