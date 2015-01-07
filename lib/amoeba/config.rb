module Amoeba
  class Config
    DEFAULTS = {
      enabled:        false,
      inherit:        false,
      do_preproc:     false,
      parenting:      false,
      raised:         false,
      dup_method:     :dup,
      remap_method:   nil,
      includes:       [],
      excludes:       [],
      clones:         [],
      customizations: [],
      overrides:      [],
      null_fields:    [],
      coercions:      {},
      prefixes:       {},
      suffixes:       {},
      regexes:        {},
      known_macros:   [:has_one, :has_many, :has_and_belongs_to_many]
    }

    # ActiveRecord 3.x have different implementation of deep_dup
    if ::ActiveRecord::VERSION::MAJOR == 3
      DEFAULTS.instance_eval do
        def deep_dup
          each_with_object(dup) do |(key, value), hash|
            hash[key.deep_dup] = value.deep_dup
          end
        end
      end
      Object.class_eval do
        def deep_dup
          duplicable? ? dup : self
        end
      end
    end

    DEFAULTS.freeze

    DEFAULTS.each do |key, value|
      value.freeze
      class_eval <<-EOS, __FILE__, __LINE__ + 1
        def #{key}          # def enabled
          @config[:#{key}]  #   @config[:enabled]
        end                 # end
      EOS
    end

    def initialize(klass)
      @klass  = klass
      @config = self.class::DEFAULTS.deep_dup
    end

    alias_method :upbringing, :raised

    def enable
      @config[:enabled] = true
    end

    def disable
      @config[:enabled] = false
    end

    def raised(style = :submissive)
      @config[:raised] = style
    end

    def propagate(style = :submissive)
      @config[:parenting] ||= style
      @config[:inherit]  = true
    end

    def push_value_to_array(value, key)
      res = @config[key]
      if value.is_a?(::Array)
        res = value
      else
        res << value if value
      end
      @config[key] = res.uniq
    end

    def push_array_value_to_hash(value, config_key)
      @config[config_key] = {}

      value.each do |definition|
        definition.each do |key, val|
          fill_hash_value_for(config_key, key, val)
        end
      end
    end

    def push_value_to_hash(value, config_key)
      if value.is_a?(Array)
        push_array_value_to_hash(value, config_key)
      else
        value.each do |key, val|
          fill_hash_value_for(config_key, key, val)
        end
      end
      @config[config_key]
    end

    def fill_hash_value_for(config_key, key, val)
      @config[config_key][key] = val if val || (!val.nil? && config_key == :coercions)
    end

    def include_association(value = nil)
      @config[:enabled]  = true
      @config[:excludes] = []
      push_value_to_array(value, :includes)
    end

    # TODO remove this method in v3.0.0
    def include_field(value = nil)
      warn "include_field is deprecated and will be removed in version 3.0.0; please use include_association instead"
      include_association(value)
    end

    def exclude_association(value = nil)
      @config[:enabled]  = true
      @config[:includes] = []
      push_value_to_array(value, :excludes)
    end

    # TODO remove this method in v3.0.0
    def exclude_field(value = nil)
      warn "exclude_field is deprecated and will be removed in version 3.0.0; please use exclude_association instead"
      exclude_association(value)
    end

    def clone(value = nil)
      @config[:enabled] = true
      push_value_to_array(value, :clones)
    end

    def recognize(value = nil)
      @config[:enabled] = true
      push_value_to_array(value, :known_macros)
    end

    { override: 'overrides', customize: 'customizations',
      nullify: 'null_fields' }.each do |method, key|
      class_eval <<-EOS, __FILE__, __LINE__ + 1
        def #{method}(value = nil)             # def override(value = nil)
          @config[:do_preproc] = true          #   @config[:do_preproc] = true
          push_value_to_array(value, :#{key})  #   push_value_to_array(value, :overrides)
        end                                    # end
      EOS
    end

    { set: 'coercions', prepend: 'prefixes',
      append: 'suffixes', regex:   'regexes' }.each do |method, key|
      class_eval <<-EOS, __FILE__, __LINE__ + 1
        def #{method}(value = nil)            # def set(value = nil)
          @config[:do_preproc] = true         #   @config[:do_preproc] = true
          push_value_to_hash(value, :#{key})  #   push_value_to_hash(value, :coercions)
        end                                   # end
      EOS
    end

    def through(value)
      @config[:dup_method] = value.to_sym
    end

    def remapper(value)
      @config[:remap_method] = value.to_sym
    end
  end
end
