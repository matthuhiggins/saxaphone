require 'nokogiri'

module Saxaphone
  class Document < Nokogiri::XML::SAX::Document
    class << self
      def parse(io, root_element_class)
        document = new(root_element_class)
        parser = Nokogiri::XML::SAX::Parser.new(document)
        parser.parse(io)
        document.root_element
      end
    end

    attr_accessor :element_stack, :root_element_class, :root_element
    def initialize(root_element_class)
      @element_stack = []
      @root_element_class = root_element_class
    end

    def start_element(name, attributes = [])
      new_element = element_stack.empty? ? root_element_class.new(name, attributes) : element_stack.last.new_element(name, attributes)
      element_stack << new_element
    end

    def end_element(name)
      ending_element = element_stack.pop
      if element_stack.empty?
        self.root_element = ending_element
      else
        element_stack.last.add_element(ending_element)
      end
    end

    def characters(string)
      element_stack.last.append_content(string)
    end
  end
end
