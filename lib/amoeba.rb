require "active_record"
require "amoeba/version"

module Amoeba
  module Dsl # {{{
    class Config
      def initialize(parent)
        @parent = parent
      end

      # Getters {{{
      def upbringing
        @raised ||= false
        @raised
      end

      def enabled
        @enabled ||= false
        @enabled
      end

      def inherit
        @inherit ||= false
        @inherit
      end

      def do_preproc
        @do_preproc ||= false
        @do_preproc
      end

      def parenting
        @parenting ||= false
        @parenting
      end

      def known_macros
        @known_macros ||= [:has_one, :has_many, :has_and_belongs_to_many]
        @known_macros
      end

      def includes
        @includes ||= []
        @includes
      end

      def excludes
        @excludes ||= []
        @excludes
      end

      def clones
        @clones ||= []
        @clones
      end

      def customizations
        @customizations ||= []
        @customizations
      end

      def overrides
        @overrides ||= []
        @overrides
      end

      def null_fields
        @null_fields ||= []
        @null_fields
      end

      def coercions
        @coercions ||= {}
        @coercions
      end

      def prefixes
        @prefixes ||= {}
        @prefixes
      end

      def suffixes
        @suffixes ||= {}
        @suffixes
      end

      def regexes
        @regexes ||= {}
        @regexes
      end
      # }}}

      # Setters (Config DSL) {{{
      def enable
        @enabled = true
      end

      def disable
        @enabled = false
      end

      def raised(style=:submissive)
        @raised = style
      end

      def propagate(style=:submissive)
        @parenting ||= style
        @inherit = true
      end

      def include_field(value=nil)
        @enabled ||= true
        @excludes = []
        @includes ||= []
        if value.is_a?(Array)
          @includes = value
        else
          @includes << value if value
        end
        @includes
      end

      def exclude_field(value=nil)
        @enabled ||= true
        @includes = []
        @excludes ||= []
        if value.is_a?(Array)
          @excludes = value
        else
          @excludes << value if value
        end
        @excludes
      end

      def clone(value=nil)
        @enabled ||= true
        @clones ||= []
        if value.is_a?(Array)
          @clones = value
        else
          @clones << value if value
        end
        @clones
      end

      def override(value=nil)
        @do_preproc ||= true
        @overrides ||= []
        if value.is_a?(Array)
          @overrides = value
        else
          @overrides << value if value
        end
        @overrides
      end

      def customize(value=nil)
        @do_preproc ||= true
        @customizations ||= []
        if value.is_a?(Array)
          @customizations = value
        else
          @customizations << value if value
        end
        @customizations
      end

      def recognize(value=nil)
        @enabled ||= true
        @known_macros ||= []
        if value.is_a?(Array)
          @known_macros = value
        else
          @known_macros << value if value
        end
        @known_macros
      end

      def nullify(value=nil)
        @do_preproc ||= true
        @null_fields ||= []
        if value.is_a?(Array)
          @null_fields = value
        else
          @null_fields << value if value
        end
        @null_fields
      end

      def set(defs=nil)
        @do_preproc ||= true
        @coercions ||= {}
        if defs.is_a?(Array)
          @coercions = {}

          defs.each do |d|
            d.each do |k,v|
              @coercions[k] = v if v
            end
          end
        else
          defs.each do |k,v|
            @coercions[k] = v if v
          end
        end
        @coercions
      end

      def prepend(defs=nil)
        @do_preproc ||= true
        @prefixes ||= {}
        if defs.is_a?(Array)
          @prefixes = {}

          defs.each do |d|
            d.each do |k,v|
              @prefixes[k] = v if v
            end
          end
        else
          defs.each do |k,v|
            @prefixes[k] = v if v
          end
        end
        @prefixes
      end

      def append(defs=nil)
        @do_preproc ||= true
        @suffixes ||= {}
        if defs.is_a?(Array)
          @suffixes = {}

          defs.each do |d|
            d.each do |k,v|
              @suffixes[k] = v if v
            end
          end
        else
          defs.each do |k,v|
            @suffixes[k] = v if v
          end
        end
        @suffixes
      end

      def regex(defs=nil)
        @do_preproc ||= true
        @regexes ||= {}
        if defs.is_a?(Array)
          @regexes = {}

          defs.each do |d|
            d.each do |k,v|
              @regexes[k] = v if v
            end
          end
        else
          defs.each do |k,v|
            @regexes[k] = v if v
          end
        end
        @regexes
      end
      # }}}
    end
  end # }}}

  module ClassMethods
    def amoeba(&block)
      @config_block ||= block if block_given?

      @config ||= Amoeba::Dsl::Config.new(self)
      @config.instance_eval(&block) if block_given?
      @config
    end

    def fresh_amoeba(&block)
      @config_block = block if block_given?

      @config = Amoeba::Dsl::Config.new(self)
      @config.instance_eval(&block) if block_given?
      @config
    end

    def amoeba_block
      @config_block
    end
  end

  module InstanceMethods
    # Config Getters {{{
    def amoeba_conf
      self.class.amoeba
    end

    def has_parent_amoeba_conf?
      self.class.superclass.respond_to?(:amoeba)
    end

    def parent_amoeba_conf
      if has_parent_amoeba_conf?
        self.class.superclass.amoeba
      else
        false
      end
    end

    def amoeba_settings
      self.class.amoeba_block
    end

    def has_parent_amoeba_settings?
      self.class.superclass.respond_to?(:amoeba_block)
    end

    def parent_amoeba_settings
      if has_parent_amoeba_conf?
        self.class.superclass.amoeba_block
      else
        false
      end
    end
    # }}}

    def dup(options={})
      @result = super()

      # Inherit Parent Settings {{{
      if !amoeba_conf.enabled && parent_amoeba_conf.inherit
        if amoeba_conf.upbringing
          parenting_style = amoeba_conf.upbringing
        else
          parenting_style = parent_amoeba_conf.parenting
        end

        case parenting_style
        when :strict
          # parent settings only
          self.class.fresh_amoeba(&parent_amoeba_settings)
        when :relaxed
          # parent takes precedence
          self.class.amoeba(&parent_amoeba_settings)
        when :submissive
          # parent suggests things
          # child does what it wants to anyway
          child_settings = amoeba_settings
          self.class.fresh_amoeba(&parent_amoeba_settings)
          self.class.amoeba(&child_settings)
        end
      end
      # }}}

      # Run Amoeba {{{
      # pramoeba_conf.overridesepend any extra strings to indicate uniqueness of the new record(s)
      if amoeba_conf.overrides.length > 0
        amoeba_conf.overrides.each do |block|
          block.call(self, @result)
        end
      end

      if amoeba_conf.enabled
        # Deep Clone Settings {{{
        amoeba_conf.clones.each do |clone_field|
          r = self.class.reflect_on_association clone_field

          # if this is a has many through and we're gonna deep
          # copy the  child records, exclude the  regular join
          # table from copying so we don't end up with the new
          # and old children on the copy
          if r.macro == :has_many && r.is_a?(ActiveRecord::Reflection::ThroughReflection)
            amoeba_conf.exclude_field r.options[:through]
          end
        end
        # }}}

        # Inclusive Style {{{
        if amoeba_conf.includes.count > 0
          amoeba_conf.includes.each do |i|
            r = self.class.reflect_on_association i
            amo_process_association(i, r)
          end
        # }}}
        # Exclusive Style {{{
        elsif amoeba_conf.excludes.count > 0
          reflections.each do |r|
            if not amoeba_conf.excludes.include?(r[0])
              amo_process_association(r[0], r[1])
            end
          end
        # }}}
        # Indiscriminate Style {{{
        else
          reflections.each do |r|
            amo_process_association(r[0], r[1])
          end
        end
        # }}}
      end

      if amoeba_conf.do_preproc
        amo_preprocess_parent_copy
      end
      # }}}

      @result
    end

  private
    # Copy Children {{{
    def amo_process_association(relation_name, settings)
      if not amoeba_conf.known_macros.include?(settings.macro)
        return
      end

      case settings.macro
      when :has_one
        if settings.is_a?(ActiveRecord::Reflection::ThroughReflection)
          return
        end

        old_obj = self.send(relation_name)

        if not old_obj.nil?
          copy_of_obj = old_obj.dup
          copy_of_obj[:"#{settings.foreign_key}"] = nil

          @result.send(:"#{relation_name}=", copy_of_obj)
        end
      when :has_many
        clone = amoeba_conf.clones.include?(:"#{relation_name}")

        # this could  be DRYed up for  better readability by
        # duplicating the loop code, but I'm duplicating the
        # loops to avoid that extra check on each iteration
        if clone
          # This  is  a  M:M  "has many  through"  where  we
          # actually copy  and reassociate the  new children
          # rather than only maintaining the associations
          self.send(relation_name).each do |old_obj|

            copy_of_obj = old_obj.dup

            # associate this new child to the new parent object
            @result.send(relation_name) << copy_of_obj
          end
        else
          # This is a regular 1:M "has many"
          #
          # copying the children of the regular has many will
          # effectively do what is desired anyway, the through
          # association is really just for convenience usage
          # on the model
          return if settings.is_a?(ActiveRecord::Reflection::ThroughReflection)

          self.send(relation_name).each do |old_obj|
            copy_of_obj = old_obj.dup
            copy_of_obj[:"#{settings.foreign_key}"] = nil

            # associate this new child to the new parent object
            @result.send(relation_name) << copy_of_obj
          end
        end

      when :has_and_belongs_to_many
        clone = amoeba_conf.clones.include?(relation_name)

        if clone
          self.send(relation_name).each do |old_obj|
            copy_of_obj = old_obj.dup

            # associate this new child to the new parent object
            @result.send(relation_name) << copy_of_obj
          end
        else
          self.send(relation_name).each do |old_obj|
            # associate this new child to the new parent object
            @result.send(relation_name) << old_obj
          end
        end
      end
    end
    # }}}

    # Field Preprocessor {{{
    def amo_preprocess_parent_copy
      # nullify any fields the user has configured
      amoeba_conf.null_fields.each do |n|
        @result[n] = nil
      end

      # prepend any extra strings to indicate uniqueness of the new record(s)
      amoeba_conf.coercions.each do |field,coercion|
        @result[field] = "#{coercion}"
      end

      # prepend any extra strings to indicate uniqueness of the new record(s)
      amoeba_conf.prefixes.each do |field,prefix|
        @result[field] = "#{prefix}#{@result[field]}"
      end

      # postpend any extra strings to indicate uniqueness of the new record(s)
      amoeba_conf.suffixes.each do |field,suffix|
        @result[field] = "#{@result[field]}#{suffix}"
      end

      # regex andy fields that need changing
      amoeba_conf.regexes.each do |field,action|
        @result[field].gsub!(action[:replace], action[:with])
      end

      # prepend any extra strings to indicate uniqueness of the new record(s)
      amoeba_conf.customizations.each do |block|
        block.call(self, @result)
      end
    end
    # }}}
  end
end

ActiveRecord::Base.send :extend,  Amoeba::ClassMethods
ActiveRecord::Base.send :include, Amoeba::InstanceMethods
