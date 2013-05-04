require 'spec_helper'

load_schema

module Genealogy
  describe "simplest individual" do
    
    let(:indiv) {SimplestIndividual.new(:name => "Ryan")}

    it "should have blank parents" do
      indiv.save!
      indiv.father.should be(nil)
      indiv.mother.should be(nil)
    end

    it "should have foo methods" do
      indiv.foo.should == 'InstanceMethods#foo'
      indiv.class.foo.should == 'ClassMethods#foo'
    end

    it "should has a father named Peter" do
      indiv.add_father(:name => "Peter")
      indiv.father.name.should == 'Peter'
      indiv.save!
    end

    it "should has a mother named Maggie" do
      indiv.add_mother(:name => "Maggie")
      indiv.mother.name.should == 'Maggie'
      indiv.save!
    end
  end
end
