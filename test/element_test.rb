require 'test_helper'

class Saxaphone::ElementTest < MiniTest::Spec
  class TestChildElement < Saxaphone::Element
    attr_accessor :special
  end

  class TestElement < Saxaphone::Element
    attr_accessor :setup_attr
    attr_accessor :child_special
    setup do
      self.setup_attr = 'hola'
    end

    element_attributes %w(foo bar)
    element_attribute 'faz', as: 'baz'

    has_element 'omg', 'Saxaphone::ElementTest::TestChildElement' do |element|
      self.child_special = element.special
    end

    has_element 'wtf', 'Saxaphone::ElementTest::TestChildElement'
  end

  def test_setup
    element = TestElement.new
    assert_equal 'hola', element.setup_attr
  end

  def test_element_attributes
    element = TestElement.new
    element.add_element(Saxaphone::Element.new('foo', 'value1'))
    element.add_element(Saxaphone::Element.new('bar', 'value2'))
    element.add_element(Saxaphone::Element.new('invalid', 'value3'))

    assert_equal({'foo' => 'value1', 'bar' => 'value2'}, element.attributes)
  end

  def test_element_attribute
    element = TestElement.new
    element.add_element(Saxaphone::Element.new('faz', 'value'))

    assert_equal({'baz' => 'value'}, element.attributes)
  end

  def test_has_element_with_block
    element = TestElement.new
    child_element = element.new_element('omg')
    
    assert_kind_of TestChildElement, child_element
    child_element.special = 'weee'
    element.add_element(child_element)

    assert_equal 'weee', element.child_special
  end
  
  def test_has_element_without_block
    element = TestElement.new
    child_element = element.new_element('omg')
    
    assert_kind_of TestChildElement, child_element
    element.add_element(child_element)
    # silence?
  end
end