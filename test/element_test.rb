require 'test_helper'

class Saxaphone::ElementTest < MiniTest::Spec
  class TestChildElement < Saxaphone::Element
    attr_accessor :special
  end

  def test_setup
    element = define_element do
      attr_accessor :setup_attr
      setup do
        self.setup_attr = 'hola'
      end
    end

    assert_equal 'hola', element.setup_attr
  end

  def test_initialize
    element = Saxaphone::Element.new('foo', 'bar', [['a', 'b']])
    assert_equal 'foo', element.name
    assert_equal 'bar', element.content
    assert_equal({'a' => 'b'}, element.attributes)
  end

  def test_element_attributes
    element = define_element do
      element_attributes %w(foo bar)
    end

    element.add_element(Saxaphone::Element.new('foo', 'value1'))
    element.add_element(Saxaphone::Element.new('bar', 'value2'))
    element.add_element(Saxaphone::Element.new('invalid', 'value3'))

    assert_equal({'foo' => 'value1', 'bar' => 'value2'}, element.attributes)
  end

  def test_element_attribute
    element = define_element do
      element_attribute 'faz', as: 'baz'
    end

    element.add_element(Saxaphone::Element.new('faz', 'value'))

    assert_equal({'baz' => 'value'}, element.attributes)
  end

  def test_has_element_with_block
    element = define_element do
      attr_accessor :child_special

      has_element 'omg', 'Saxaphone::ElementTest::TestChildElement' do |element|
        self.child_special = element.special
      end
    end

    child_element = element.element_for('omg').new('omg')
    
    assert_kind_of TestChildElement, child_element
    child_element.special = 'weee'
    element.add_element(child_element)

    assert_equal 'weee', element.child_special
  end
  
  def test_has_element_without_block
    element = define_element do
      has_element 'wtf', 'Saxaphone::ElementTest::TestChildElement'
    end

    child_element = element.element_for('wtf').new('wtf')
    
    assert_kind_of TestChildElement, child_element
    element.add_element(child_element)
    # silence?
  end
  
  private
    def define_element(&block)
      Class.new(Saxaphone::Element, &block).new
    end
end