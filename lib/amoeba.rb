# frozen_string_literal: true

require 'active_record'
require 'active_support/all'
require 'amoeba/version'
require 'amoeba/config'
require 'amoeba/macros'
require 'amoeba/macros/base'
require 'amoeba/macros/has_many'
require 'amoeba/macros/has_one'
require 'amoeba/macros/has_and_belongs_to_many'
require 'amoeba/cloner'
require 'amoeba/class_methods'
require 'amoeba/instance_methods'

module Amoeba
end

ActiveSupport.on_load :active_record do
  extend Amoeba::ClassMethods
  include Amoeba::InstanceMethods
end
