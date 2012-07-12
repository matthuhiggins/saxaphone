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

  def test_accessors_inheritence
    parent = Class.new(Saxaphone::Element) do
      has_element 'foo'
      store_attributes 'faz'
    end

    child = Class.new(parent) do
      has_element 'bar'
      store_attribute 'baz', as: 'moo'
    end

    assert_equal ['foo'].to_set, parent.element_handlers.keys.to_set
    assert_equal ['faz'].to_set, parent.stored_attributes
    assert_equal({}, parent.attribute_aliases)

    assert_equal ['foo', 'bar'].to_set, child.element_handlers.keys.to_set
    assert_equal ['faz', 'baz'].to_set, child.stored_attributes
    assert_equal({'baz' => 'moo'}, child.attribute_aliases)
  end

  def test_store_attributes
    element = Class.new(Saxaphone::Element) do
      store_attributes 'a', 'm'
    end.new('foo', 'bar', [['a', 'b'], ['m', 'n'], ['x', 'y']])
    
    assert_equal 'foo', element.name
    assert_equal 'bar', element.content
    assert_equal({'a' => 'b', 'm' => 'n'}, element.attributes)
  end

  def test_store_attribute
    element = Class.new(Saxaphone::Element) do
      store_attribute 'm', as: 'n'
    end.new('foo', 'bar', [['a', 'b'], ['m', 'o']])

    assert_equal({'n' => 'o'}, element.attributes)
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

    element.add_element(Saxaphone::Element.new('faz', 'value1'))
    element.add_element(Saxaphone::Element.new('foo', 'value2'))

    assert_equal({'baz' => 'value1'}, element.attributes)
  end

  def test_element_attribute_with_any
    element = define_element do
      element_attribute 'faz', as: 'baz'
      element_attribute '*'
    end

    element.add_element(Saxaphone::Element.new('faz', 'value1'))
    element.add_element(Saxaphone::Element.new('foo', 'value2'))

    assert_equal({'baz' => 'value1', 'foo' => 'value2'}, element.attributes)    
  end

  def test_has_element_with_block
    element = define_element do
      attr_accessor :child_content

      has_element 'omg'  do |element|
        self.child_content = element.content
      end
    end

    child_element = element.element_for('omg').new('omg')    
    child_element.content = 'weee'
    element.add_element(child_element)

    assert_kind_of Saxaphone::Element, child_element
    assert_equal 'weee', element.child_content
  end

  def test_has_element_with_block_and_custom_element
    element = define_element do
      attr_accessor :child_special

      has_element 'omg', 'Saxaphone::ElementTest::TestChildElement' do |element|
        self.child_special = element.special
      end
    end

    child_element = element.element_for('omg').new('omg')
    child_element.special = 'weee'
    element.add_element(child_element)
    
    assert_kind_of TestChildElement, child_element
    assert_equal 'weee', element.child_special
  end

  def test_has_element_with_any
    element = define_element do
      has_element '*'  do |element|
        self.attributes[element.name.upcase] = element.content
      end
    end

    child_element = element.element_for('faz').new('faz')
    child_element.content = 'weee'
    element.add_element(child_element)

    assert_kind_of Saxaphone::Element, child_element
    assert_equal({'FAZ' => 'weee'}, element.attributes)
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