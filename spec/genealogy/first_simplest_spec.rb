require 'spec_helper'

load_schema

module Genealogy
  describe "simplest individual" do
    
    let(:indiv) {SimplestIndividual.new}

    it "should have blank parents" do
      indiv.save!
      indiv.father.should be(nil)
      indiv.mother.should be(nil)
     end
  end  
end
