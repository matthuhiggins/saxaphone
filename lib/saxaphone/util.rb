module Saxaphone
  class Util
    class << self
      def constantize(camel_cased_word)
        names = camel_cased_word.split('::')
        names.shift if names.empty? || names.first.empty?

        constant = Object
        names.each do |name|
          constant = standardized_const_defined?(constant, name) ? constant.const_get(name) : constant.const_missing(name)
        end
        constant
      end

      if Module.method(:const_defined?).arity == 1
        def standardized_const_defined?(constant, name)
          constant.const_defined?(name)
        end
      else
        def standardized_const_defined?(constant, name)
          constant.const_defined?(name, false)
        end
      end
    end
  end
end