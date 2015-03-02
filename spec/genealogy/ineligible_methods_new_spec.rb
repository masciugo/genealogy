require 'spec_helper'

describe "*** Ineligible methods without considering ages ***", :ineligible, :new do

  context 'when cannot replace parent (default)' do
    before { @model = get_test_model({:current_spouse => true, :check_ages => false }) }  
    include_context "releted people exist" #all following examples are based on sample pedigree

    describe "#ineligible_fathers" do
      it "returns nil if father already set" do
        expect(rud.ineligible_fathers).to be nil
      end
      it "does not return nil if father is not set" do
        expect(manuel.ineligible_fathers).to_not be nil
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
      it "does not include male maternal half siblings" do
        steve.update_attributes(father_id: nil)
        expect(steve.ineligible_fathers).to_not include peter
      end
    end

    describe "#ineligible_mothers" do
      it "returns nil if mother already set" do
        expect(rud.ineligible_mothers).to be nil
      end
      it "does not return nil if mother is not set" do
        expect(mia.ineligible_mothers).to_not be nil
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
      it "does not include female paternal half siblings" do
        expect(ruben.ineligible_mothers).to_not include mary
      end
    end

    describe "#ineligible_paternal_grandfathers" do
      it "returns nil if paternal_grandfather already set" do
        expect(rud.ineligible_paternal_grandfathers).to be nil
      end
      it "does not return nil if paternal_grandfather is not set" do
        expect(paul.ineligible_paternal_grandfathers).to_not be nil
      end 
      it "includes theirself" do
        expect(paul.ineligible_paternal_grandfathers).to include paul
      end
      it "includes father, i.e., father can't be paternal grandfather" do
        expect(paul.ineligible_paternal_grandfathers).to include manuel
      end
      it "does not include maternal male ancestors" do
        expect(paul.ineligible_paternal_grandfathers).to_not include marcel
      end
      it "includes male descendants" do
        expect(jack.ineligible_paternal_grandfathers).to include rud,mark,sam,charlie,peter,steve
      end
      it "includes all females" do
        expect(manuel.ineligible_paternal_grandfathers).to include *@model.females
      end
      it "includes all half siblings"
    end

    describe "#ineligible_paternal_grandmothers" do
      
    end

    describe "#ineligible_maternal_grandfathers" do
      
    end

    describe "#ineligible_maternal_grandmothers" do
      
    end

    describe "#siblings" do
      
    end

    describe "#children" do
      it "includes theirself"
      it "includes ancestors"
      it "includes full siblings"
      it "includes all individuals with both parents"
      context 'when receiver is male' do
        it "includes all individuals with father"
        it "does not include maternal half siblings without father, i.e., the father can be the receiver"
        it "includes maternal half siblings with father"
      end
      context 'when receiver is female' do
        it "includes all individuals with mother"
        it "does not include paternal half siblings without mother, i.e., the mother can be the receiver"
        it "includes paternal half siblings with mother"
      end
    end

  end

  context 'when can replace parent' do
    before { @model = get_test_model({:current_spouse => true, :check_ages => false, :replace_parent => true }) }  
    include_context "releted people exist"

    describe "#siblings" do
      
    end

    describe "#children" do
      
    end

  end
end
































