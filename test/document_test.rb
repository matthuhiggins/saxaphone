require 'test_helper'

class Saxaphone::DocumentTest < MiniTest::Spec
  class TestDocument < Saxaphone::Document
  end

  def test_cdata
    klass = Class.new Saxaphone::Element do
      element_attribute 'thoughts'
    end

    element = klass.parse(StringIO.new %{<?xml version="1.0" encoding="utf-8"?>
      <foo>
        <thoughts>Bob is <![CDATA[hungry]]></thoughts>
      </foo>
    })
    assert_equal 'Bob is hungry', element.attributes['thoughts']
  end
end