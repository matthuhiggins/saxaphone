module Saxaphone
  class Element
    @@base_class_name = 'Saxaphone::Element'

    class ElementHandler < Struct.new(:class_name, :proc)
    end

    class << self
      def setup(&block)
        define_method(:setup, &block)
      end

      def element_attributes(element_names)
        element_names.each do |element_name|
          element_attribute(element_name)
        end
      end

      def element_attribute(element_name, options = {})
        converted_name = options.delete(:as) || element_name
        logic = proc { |element| attributes[converted_name] = element.content }
        element_handler = ElementHandler.new(@@base_class_name, logic)

        element_handlers[element_name] = element_handler
      end

      def has_element(element_name, class_name = @@base_class_name, &block)
        element_handlers[element_name] = ElementHandler.new(class_name, block)
      end

      def has_attributes(attribute_names)
        raise 'not implemented'
      end

      def element_handlers
        @element_handlers ||= {}
      end

      def parse(xml)
        Saxaphone::Document.parse(xml, self)
      end
    end

    attr_accessor :name, :content, :attributes
    def initialize(name = '', content = '')
      self.name = name
      self.content = content
      self.attributes = {}
      setup
    end

    def setup
    end

    def add_element(element)
      if element_handler = self.class.element_handlers[element.name]
        instance_exec(element, &element_handler.proc) if element_handler.proc
      end
    end

    def new_element(element_name)
      if element_handler = self.class.element_handlers[element_name]
        klass = Saxaphone::Util.constantize(element_handler.class_name)
      else
        klass = Saxaphone::Element
      end
      klass.new(element_name)
    end

    def append_content(string)
      content << string
    end
  end
end
