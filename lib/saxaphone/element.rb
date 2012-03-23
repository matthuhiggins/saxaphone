require 'set'

module Saxaphone
  class Element
    @@base_class_name = 'Saxaphone::Element'

    class ElementHandler < Struct.new(:class_name, :proc)
    end

    @element_handlers = {}
    @stored_attributes = Set.new

    class << self
      attr_accessor :element_handlers
      attr_accessor :stored_attributes

      def inherited(base)
        base.element_handlers = element_handlers.dup
        base.stored_attributes = stored_attributes.dup
      end

      # A block can be passed to <tt>setup</tt>,
      # which is called after the element is initialized.
      # 
      #   WidgetElement < Saxaphone::Element
      #     attr_accessor :foo
      #     
      #     setup do
      #       self.foo = 'bar'
      #     end
      #   end
      #
      #  It is recommended to use setup rather than
      #  overriding initialize.
      # 
      def setup(&block)
        define_method(:setup, &block)
      end

      # Define elements that should be stored as attributes:
      # 
      # WidgetElement < Saxaphone::Element
      #   element_attributes %w(color price)
      # end
      # 
      #   element = WidgetElement.parse %{
      #     <widget>
      #       <color>red</color>
      #       <price>4.33</price>
      #     </widget>
      #   }
      # 
      # element.attributes # => {"color" => "red", "price" => "4.33"}
      # 
      def element_attributes(element_names)
        element_names.each do |element_name|
          element_attribute(element_name)
        end
      end

      # Define a single element that should be stored as an attribute.
      # 
      #   WidgetElement < Saxaphone::Element
      #     element_attribute 'price'
      #   end
      # 
      #   element = WidgetElement.parse %{
      #     <widget>
      #       <price>4.33</price>
      #     </widget>
      #   }
      # 
      #   element.attributes # => {"price" => "4.33"}
      # 
      # The name of the stored attribute can optionally be changed
      # with the <tt>:as</tt> option:
      # 
      #   WidgetElement < Saxaphone::Element
      #     element_attribute 'price', as: 'dollars'
      #   end
      # 
      #   element = WidgetElement.parse %{
      #     <widget>
      #       <price>4.33</price>
      #     </widget>
      #   }
      # 
      #   element.attributes # => {"dollars" => "4.33"}
      def element_attribute(element_name, options = {})
        converted_name = options.delete(:as)

        has_element(element_name) do |element|
          attributes[converted_name || element.name] = element.content
        end
      end

      # Define what to do for a particular child element. 
      # After the element is parsed, it is passed to the block:
      # 
      #   WidgetElement < Saxaphone::Element
      #     attr_accessor :cents
      # 
      #     has_element 'price' do |element|
      #       self.cents = element.content.to_f * 100
      #     end
      #   end
      # 
      #   element = WidgetElement.parse %{
      #     <widget>
      #       <price>4.33</price>
      #     </widget>
      #   }
      #   
      #   element.cents # => 433.0
      # 
      # It is possible to define the class name that is used
      # to parse the child element: 
      # 
      #   PriceElement < Saxaphone::Element
      #     def cents
      #       content.to_f * 100
      #     end
      #   end
      # 
      #   WidgetElement < Saxaphone::Element
      #     attr_accessor :cents
      # 
      #     has_element 'price', 'PriceElement' do |element|
      #       self.cents = element.cents
      #     end
      #   end
      # 
      #   The children elements can have children of their own,
      #   and each uses has_element to define what to do.
      # 
      def has_element(element_name, class_name = @@base_class_name, &block)
        element_handlers[element_name] = ElementHandler.new(class_name, block)
      end

      # Define a white list of the attributes that are extracted
      # from the XML element and stored in the attribute hash:
      # 
      #   WidgetElement < Saxaphone::Element
      #     store_attributes 'name', 'color'
      #   end
      # 
      #   element = WidgetElement.parse %{
      #     <widget name="Acme" color="red" price="3.21">
      #       ...
      #     </widget>
      #   }
      # 
      #   element.attributes # => {"name" => "Acme", "color" => "red"}
      # 
      # Notice that the "price" attribute is not stored.
      # 
      def store_attributes(*attribute_names)
        self.stored_attributes += attribute_names.flatten.to_set
      end

      def handler_for(element_name)
        element_handlers[element_name] || element_handlers['*']
      end
      
      def parse(xml)
        Saxaphone::Document.parse(xml, self)
      end
    end

    attr_accessor :name, :content, :attributes
    def initialize(name = '', content = '', attribute_array = [])
      self.name = name
      self.content = content
      self.attributes = Hash[attribute_array.select { |(key, value)| self.class.stored_attributes.include?(key) }]
      setup
    end

    def setup
    end

    def add_element(element)
      if element_handler = self.class.handler_for(element.name)
        instance_exec(element, &element_handler.proc) if element_handler.proc
      end
    end

    def element_for(element_name)
      if element_handler = self.class.handler_for(element_name)
        Saxaphone::Util.constantize(element_handler.class_name)
      else
        Saxaphone::Element
      end
      
    end

    def append_content(string)
      content << string
    end
  end
end
