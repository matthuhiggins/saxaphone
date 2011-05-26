require 'test_helper'

class Saxaphone::DocumentTest < MiniTest::Spec
  class TestDocument < Saxaphone::Document
    class FooElement < Saxaphone::Element
    end
  end

  def test_parse_xml
    # assert false
  end

  private
    def xml
      StringIO.new %{<?xml version="1.0" encoding="utf-8"?>
        <foo>
          <hola>como estas</hola>
          <omg>wtf</omg>
        </foo>
      }
    end
end