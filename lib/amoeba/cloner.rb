require 'forwardable'

module Amoeba
  class Cloner
    extend Forwardable

    attr_reader :new_object, :old_object, :object_klass

    def_delegators :old_object, :_parent_amoeba, :_amoeba_settings,
                   :_parent_amoeba_settings

    def_delegators :object_klass, :amoeba, :fresh_amoeba

    def initialize(object, options = {})
      @old_object, @options = object, options
      @object_klass = @old_object.class
      inherit_parent_settings
      @new_object = object.__send__(amoeba.dup_method)
    end

    def run
      process_overrides
      apply if amoeba.enabled
      after_apply if amoeba.do_preproc
      @new_object
    end

    private

    def parenting_style
      amoeba.upbringing ? amoeba.upbringing : _parent_amoeba.parenting
    end

    def inherit_strict_parent_settings
      fresh_amoeba(&_parent_amoeba_settings)
    end

    def inherit_relaxed_parent_settings
      amoeba(&_parent_amoeba_settings)
    end

    def inherit_submissive_parent_settings
      fresh_amoeba(&_parent_amoeba_settings)
      amoeba(&_amoeba_settings)
    end

    def inherit_parent_settings
      return if amoeba.enabled || !_parent_amoeba.inherit
      return unless %w(strict relaxed submissive).include?(parenting_style.to_s)
      __send__("inherit_#{parenting_style}_parent_settings".to_sym)
    end

    def apply_clones
      amoeba.clones.each do |clone_field|
        exclude_clone_if_has_many_through(clone_field)
      end
    end

    def exclude_clone_if_has_many_through(clone_field)
      association = @object_klass.reflect_on_association(clone_field)

      # if this is a has many through and we're gonna deep
      # copy the child records, exclude the regular join
      # table from copying so we don't end up with the new
      # and old children on the copy
      return unless association.macro == :has_many ||
        association.is_a?(::ActiveRecord::Reflection::ThroughReflection)
      amoeba.exclude_association(association.options[:through])
    end

    def follow_only_includes
      amoeba.includes.each do |include|
        follow_association(include, @object_klass.reflect_on_association(include))
      end
    end

    def follow_all_except_excludes
      @object_klass.reflections.each do |name, association|
        next if amoeba.excludes.include?(name.to_sym)
        follow_association(name, association)
      end
    end

    def follow_all
      @object_klass.reflections.each do |name, association|
        follow_association(name, association)
      end
    end

    def apply_associations
      if amoeba.includes.size > 0
        follow_only_includes
      elsif amoeba.excludes.size > 0
        follow_all_except_excludes
      else
        follow_all
      end
    end

    def apply
      apply_clones
      apply_associations
    end

    def follow_association(relation_name, association)
      return unless amoeba.known_macros.include?(association.macro.to_sym)
      follow_klass = ::Amoeba::Macros.list[association.macro.to_sym]
      follow_klass.new(self).follow(relation_name, association) if follow_klass
    end

    def process_overrides
      amoeba.overrides.each do |block|
        block.call(@new_object, @new_object)
      end
    end

    def process_null_fields
      # nullify any fields the user has configured
      amoeba.null_fields.each do |field_key|
        @new_object[field_key] = nil
      end
    end

    def process_coercions
      # prepend any extra strings to indicate uniqueness of the new record(s)
      amoeba.coercions.each do |field, coercion|
        @new_object[field] = "#{coercion}"
      end
    end

    def process_prefixes
      # prepend any extra strings to indicate uniqueness of the new record(s)
      amoeba.prefixes.each do |field, prefix|
        @new_object[field] = "#{prefix}#{@new_object[field]}"
      end
    end

    def process_suffixes
      # postpend any extra strings to indicate uniqueness of the new record(s)
      amoeba.suffixes.each do |field, suffix|
        @new_object[field] = "#{@new_object[field]}#{suffix}"
      end
    end

    def process_regexes
      # regex any fields that need changing
      amoeba.regexes.each do |field, action|
        @new_object[field].gsub!(action[:replace], action[:with])
      end
    end

    def process_customizations
      # prepend any extra strings to indicate uniqueness of the new record(s)
      amoeba.customizations.each do |block|
        block.call(@old_object, @new_object)
      end
    end

    def after_apply
      process_null_fields
      process_coercions
      process_prefixes
      process_suffixes
      process_regexes
      process_customizations
    end
  end
end
