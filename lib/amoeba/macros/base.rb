module Amoeba
  module Macros
    class Base
      @@associationCache = {}
      
      def initialize(cloner)
        @cloner     = cloner
        @old_object = cloner.old_object
        @new_object = cloner.new_object
      end

      def follow(_relation_name, _association)
        fail "#{self.class.name} doesn't implement `follow`!"
      end

      class << self
        def inherited(klass)
          ::Amoeba::Macros.add(klass)
        end
      end

      def remapped_relation_name(name)
        return name unless @cloner.amoeba.remap_method
        @old_object.__send__(@cloner.amoeba.remap_method, name.to_sym) || name
      end
      
      def reuse_instance(new_object, lambda)
        if @@associationCache.nil?
          @@associationCache = {}
        end

        if not @@associationCache.has_key? new_object.class.name
          @@associationCache[new_object.class.name] = {}
        end

        if not new_object.attributes.has_key? 'name'
          relationName = Digest::MD5.hexdigest(new_object.attributes.reject{|x| x == 'id'}.values.join(','))
        else
          relationName = new_object.name
        end

        if @@associationCache[new_object.class.name].has_key? relationName
          return @@associationCache[new_object.class.name][relationName]
        else
          new_instance = lambda.call
          
          if new_instance.nil?
            return nil
          end

          @@associationCache[new_object.class.name][relationName] = new_instance
          return new_instance
        end
      end
    end
  end
end
