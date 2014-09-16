module Amoeba
  class Config
    DEFAULTS = {
      enabled:        false,
      inherit:        false,
      do_preproc:     false,
      parenting:      false,
      raised:         false,
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
    }.freeze

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
      @config[:inherit]   = true
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
          @config[config_key][key] = val if val
        end
      end
    end

    def push_value_to_hash(value, config_key)
      if value.is_a?(Array)
        push_array_value_to_hash(value, config_key)
      else
        value.each do |key, val|
          @config[config_key][key] = val if val
        end
      end
      @config[config_key]
    end

    def include_field(value = nil)
      @config[:enabled]  = true
      @config[:excludes] = []
      push_value_to_array(value, :includes)
    end

    def exclude_field(value = nil)
      @config[:enabled]  = true
      @config[:includes] = []
      push_value_to_array(value, :excludes)
    end

    def clone(value = nil)
      @config[:enabled] = true
      push_value_to_array(value, :clones)
    end

    def recognize(value = nil)
      @config[:enabled] = true
      push_value_to_array(value, :known_macros)
    end

    def override(value = nil)
      @config[:do_preproc] = true
      push_value_to_array(value, :overrides)
    end

    def customize(value = nil)
      @config[:do_preproc] = true
      push_value_to_array(value, :customizations)
    end

    def nullify(value = nil)
      @config[:do_preproc] = true
      push_value_to_array(value, :null_fields)
    end

    def set(value = nil)
      @config[:do_preproc] = true
      push_value_to_hash(value, :coercions)
    end

    def prepend(value = nil)
      @config[:do_preproc] = true
      push_value_to_hash(value, :prefixes)
    end

    def append(value = nil)
      @config[:do_preproc] = true
      push_value_to_hash(value, :suffixes)
    end

    def regex(value = nil)
      @config[:do_preproc] = true
      push_value_to_hash(value, :regexes)
    end
  end
end
