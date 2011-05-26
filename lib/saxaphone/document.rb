require 'nokogiri'

module Saxaphone
  class Document < Nokogiri::XML::SAX::Document
    class << self
      def parse(io, root_element_class)
        parser = Nokogiri::XML::SAX::Parser.new(new(root_element_class))
        parser.parse(io)
      end
    end

    attr_accessor :element_stack, :root_element_class
    def initialize(root_element_class)
      @element_stack = []
      @root_element_class = root_element_class
    end

    def start_element(name, attributes = [])
      new_element = element_stack.empty? ? root_element_class.new(name) : element_stack.last.new_element(name)
      element_stack << new_element
    end

    def end_element(name)
      ending_element = element_stack.pop
      unless element_stack.empty?
        element_stack.last.add_element(ending_element)
      end
    end

    def characters(string)
      element_stack.last.append_content(string)
    end
  end
end
