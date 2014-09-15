module Amoeba
  module ClassMethods
    def amoeba(&block)
      @config_block ||= block if block_given?

      @config ||= Amoeba::Config.new(self)
      @config.instance_eval(&block) if block_given?
      @config
    end

    def fresh_amoeba(&block)
      @config_block = block if block_given?

      @config = Amoeba::Config.new(self)
      @config.instance_eval(&block) if block_given?
      @config
    end

    def amoeba_block
      @config_block
    end
  end
end
