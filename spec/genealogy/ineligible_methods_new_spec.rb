require 'spec_helper'

describe "*** Ineligible methods without considering ages ***", :ineligible, :new do

  context 'when can replace parent' do
    before { @model = get_test_model({:current_spouse => true, :check_ages => false, :replace_parent => true }) }  
    include_context "releted people exist" #all following examples are based on sample pedigree

    describe "#ineligible_fathers" do
      it "returns nil if father already set" do
        expect(rud.ineligible_fathers).to be nil
      end
      it "includes theirself" do
        expect(manuel.ineligible_fathers).to include manuel
      end
      it "includes all females" do
        expect(manuel.ineligible_fathers).to include *@model.females
      end
      it "does not include male ancestors (e.g., maternal grandfather)" do
        rud.update_attributes(father_id: nil)
        expect(rud.ineligible_fathers).to_not include luis,larry,tommy
      end
      it "includes male descendants" do
        expect(alison.ineligible_fathers).to include paso,john,rud,mark,peter,steve,sam,charlie
      end
      it "does not include male maternal half siblings, i.e., they can become full siblings" do
        steve.update_attributes(father_id: nil)
        expect(steve.ineligible_fathers).to_not include peter
      end
    end

    describe "#ineligible_mothers" do
      it "returns nil if mother already set" do
        expect(rud.ineligible_mothers).to be nil
      end
      it "includes theirself" do
        expect(manuel.ineligible_mothers).to include manuel
      end
      it "includes all males" do
        expect(manuel.ineligible_mothers).to include *@model.males
      end
      it "does not include female ancestors (e.g., paternal grandmother)" do
        rud.update_attributes(mother_id: nil)
        expect(rud.ineligible_mothers).to_not include alison
      end
      it "includes female descendants" do
        expect(alison.ineligible_mothers).to include titty,sue
      end
      it "does not include female paternal half siblings, i.e., they can become full siblings" do
        expect(ruben.ineligible_mothers).to_not include mary
      end
    end

    describe "#ineligible_paternal_grandfathers" do
      it "returns nil if paternal_grandfather already set" do
        expect(rud.ineligible_paternal_grandfathers).to be nil
      end
      it "includes theirself" do
        expect(paul.ineligible_paternal_grandfathers).to include paul
      end
      it "includes father, i.e., father can't be paternal grandfather"
      it "does not include maternal male ancestors"
      it "includes male descendants"
      it "includes all females" do
        expect(manuel.ineligible_paternal_grandfathers).to include *@model.females
      end

    end

    describe "#siblings" do
      
    end

    describe "#children" do
      
    end

  end

  context 'when cannot replace parent (default)' do
    before { @model = get_test_model({:current_spouse => true, :check_ages => false }) }  
    include_context "releted people exist"

  end
end
































