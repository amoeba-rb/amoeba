require "amoeba/version"

module Amoeba
  module ClassMethods
    def amoeba(&block)
      @config ||= Amoeba::ClassMethods::Config.new
      @config.instance_eval(&block) if block_given?
      @config
    end

    class Config
      # Getters {{{
      def enabled
        @enabled ||= false
        @enabled
      end

      def do_preproc
        @do_preproc ||= false
        @do_preproc
      end

      def includes
        @includes ||= []
        @includes
      end

      def excludes
        @excludes ||= []
        @excludes
      end

      def known_macros
        @known_macros ||= [:has_one, :has_many, :has_and_belongs_to_many]
        @known_macros
      end

      def null_fields
        @null_fields ||= []
        @null_fields
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

      def include_field(value=nil)
        @enabled ||= true
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
        @excludes ||= []
        if value.is_a?(Array)
          @excludes = value
        else
          @excludes << value if value
        end
        @excludes
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
  end

  module InstanceMethods
    def amoeba_conf
      self.class.amoeba
    end

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
        # copying the children of the regular has many will
        # effectively do what is desired anyway, the through
        # association is really just for convenience usage
        # on the model
        if settings.is_a?(ActiveRecord::Reflection::ThroughReflection)
          return
        end

        self.send(relation_name).each do |old_obj|
          copy_of_obj = old_obj.dup
          copy_of_obj[:"#{settings.foreign_key}"] = nil

          # associate this new child to the new parent object
          @result.send(relation_name) << copy_of_obj
        end
      when :has_and_belongs_to_many
        self.send(relation_name).each do |old_obj|
          # associate this new child to the new parent object
          @result.send(relation_name) << old_obj
        end
      end
    end

    def dup(options={})
      @result = super()

      if amoeba_conf.enabled
        if amoeba_conf.includes.count > 0
          amoeba_conf.includes.each do |i|
            r = self.class.reflect_on_association i
            amo_process_association(i, r)
          end
        elsif amoeba_conf.excludes.count > 0
          reflections.each do |r|
            if not amoeba_conf.excludes.include?(r[0])
              amo_process_association(r[0], r[1])
            end
          end
        else
          reflections.each do |r|
            amo_process_association(r[0], r[1])
          end
        end
      end

      if amoeba_conf.do_preproc
        preprocess_parent_copy
      end

      @result
    end

    def preprocess_parent_copy
      # nullify any fields the user has configured
      amoeba_conf.null_fields.each do |n|
        @result[n] = nil
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
    end
  end
end

ActiveRecord::Base.send :extend,  Amoeba::ClassMethods
ActiveRecord::Base.send :include, Amoeba::InstanceMethods
