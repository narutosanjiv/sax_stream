require 'spec_helper'
require 'sax_stream/internal/field_mapping'

module SaxStream
  module Internal
    describe FieldMapping do
      context "instantiating" do
        class NoParse
        end

        it "raises an error if :as option doesn't support parse" do
          lambda {
            FieldMapping.new('foobar', :as => NoParse)
          }.should raise_error(ArgumentError)
        end
      end

      context "mapping value onto object" do
        let(:object)    { Hash.new }
        let(:converter) { double("converter") }

        it "sets a string value on the object" do
          FieldMapping.new('foobar').map_value_onto_object(object, 'moose')
          object['foobar'].should == 'moose'
        end

        it "sets a nil value on the object" do
          FieldMapping.new('foobar').map_value_onto_object(object, nil)
          object['foobar'].should == nil
        end

        it "uses the :as option to convert the value if it is a string" do
          converter.stub(:parse).with('moose').and_return('rabbit')
          FieldMapping.new('foobar', :as => converter).map_value_onto_object(object, 'moose')
          object['foobar'].should == 'rabbit'
        end

        it "doesnt try and convert the value if it is nil" do
          converter.should_not_receive(:parse)
          FieldMapping.new('foobar', :as => converter).map_value_onto_object(object, nil)
          object['foobar'].should == nil
        end

        it "uses an accessor method if it exists" do
          object.stub(:respond_to?).with(:foobar=).and_return(true)
          object.should_receive(:foobar=).with('moose')
          FieldMapping.new('foobar').map_value_onto_object(object, 'moose')
          object['foobar'].should == nil
        end
      end
    end
  end
end