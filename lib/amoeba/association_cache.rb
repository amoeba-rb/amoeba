module Amoeba
  module AssociationCache
    def self.flush
      RequestStore.store[:amoeba_cache] = {}
    end

    def self.cache(instance)
      key = get_key(instance)

      unless RequestStore.store.has_key?(:amoeba_cache)
        RequestStore.store[:amoeba_cache] = {}
      end

      RequestStore.store[:amoeba_cache][key] = instance
    end

    def self.get(instance)
      key = get_key(instance)
      
      unless RequestStore.store.has_key?(:amoeba_cache)
        RequestStore.store[:amoeba_cache] = {}
      end

      RequestStore.store[:amoeba_cache][key]
    end

    private

    def self.get_key(new_object)
      if new_object.respond_to?(:name)
        new_object.class.name + '::' + new_object.name
      else
        new_object.class.name + '::' + Digest::MD5.hexdigest(new_object.attributes.reject{|x| x == 'id'}.values.join(','))
      end
    end
  end
end
