module Amoeba
  module InstanceMethods
    def _parent_amoeba
      if self.class.superclass.respond_to?(:amoeba)
        self.class.superclass.amoeba
      else
        false
      end
    end

    def _amoeba_settings
      self.class.amoeba_block
    end

    def _parent_amoeba_settings
      if self.class.superclass.respond_to?(:amoeba_block)
        self.class.superclass.amoeba_block
      else
        false
      end
    end

    def amoeba_dup(options = {})
      ::Amoeba::Cloner.new(self, options).run
    end
  end
end
