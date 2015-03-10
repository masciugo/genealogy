require 'spec_helper'

describe "*** Ineligible methods ***", :ineligible do

  context 'when ineligibility checks involve only pedigree (default)' do
    before { @model = get_test_model({current_spouse: true }) }  
    include_context "pedigree exists" #all following examples are based on sample pedigree

    describe "#ineligible_fathers" do
      it "returns nil if father already set" do
        expect(rud.ineligible_fathers).to be nil
      end
      it "does not return nil if father is not set" do
        expect(manuel.ineligible_fathers).not_to be nil
      end  
      it "includes theirself" do
        expect(manuel.ineligible_fathers).to include manuel
      end
      it "includes all females" do
        expect(manuel.ineligible_fathers).to include *@model.females
      end
      it "does not include male ancestors (e.g., maternal grandfather)" do
        rud.update_attributes(father_id: nil)
        expect(rud.ineligible_fathers).not_to include luis,larry,tommy
      end
      it "includes male descendants" do
        expect(alison.ineligible_fathers).to include paso,john,rud,mark,peter,steve,sam,charlie
      end
      it "does not include male maternal half siblings" do
        steve.update_attributes(father_id: nil)
        expect(steve.ineligible_fathers).not_to include peter
      end
    end

    describe "#ineligible_mothers" do
      it "returns nil if mother already set" do
        expect(rud.ineligible_mothers).to be nil
      end
      it "does not return nil if mother is not set" do
        expect(mia.ineligible_mothers).not_to be nil
      end  
      it "includes theirself" do
        expect(manuel.ineligible_mothers).to include manuel
      end
      it "includes all males" do
        expect(manuel.ineligible_mothers).to include *@model.males
      end
      it "does not include female ancestors (e.g., paternal grandmother)" do
        rud.update_attributes(mother_id: nil)
        expect(rud.ineligible_mothers).not_to include alison
      end
      it "includes female descendants" do
        expect(alison.ineligible_mothers).to include titty,sue
      end
      it "does not include female paternal half siblings" do
        expect(ruben.ineligible_mothers).not_to include mary
      end
    end

    describe "#ineligible_paternal_grandfathers" do
      it "returns nil if paternal_grandfather already set" do
        expect(rud.ineligible_paternal_grandfathers).to be nil
      end
      it "does not return nil if paternal_grandfather is not set" do
        expect(paul.ineligible_paternal_grandfathers).not_to be nil
      end 
      it "includes theirself" do
        expect(paul.ineligible_paternal_grandfathers).to include paul
      end
      it "includes father (i.e., father can't be paternal grandfather)" do
        expect(paul.ineligible_paternal_grandfathers).to include manuel
      end
      it "does not include maternal male ancestors" do
        expect(paul.ineligible_paternal_grandfathers).not_to include marcel
      end
      it "includes male descendants" do
        expect(jack.ineligible_paternal_grandfathers).to include rud,mark,sam,charlie,peter,steve
      end
      it "includes all females" do
        expect(manuel.ineligible_paternal_grandfathers).to include *@model.females
      end
      it "includes full siblings" do
        paul.update_attributes(father_id: nil)
        expect(peter.ineligible_paternal_grandfathers).to include steve
      end
      it "includes paternal half siblings" do
        paul.update_attributes(father_id: nil)
        expect(peter.ineligible_paternal_grandfathers).to include julian,ruben
      end
      it "does not include maternal half siblings (it might happen when a grandparent have a child with their child-in-law)" do
        paul.update_attributes(father_id: nil)
        ruben.update_attributes(father_id: nil, mother_id: titty)
        expect(peter.ineligible_paternal_grandfathers).not_to include ruben
      end
    end

    describe "#ineligible_paternal_grandmothers" do
      it "returns nil if paternal_grandmother already set" do
        expect(rud.ineligible_paternal_grandmothers).to be nil
      end
      it "does not return nil if paternal_grandmother is not set" do
        expect(paul.ineligible_paternal_grandmothers).not_to be nil
      end 
      it "includes theirself" do
        expect(mia.ineligible_paternal_grandmothers).to include mia
      end
      it "does not include maternal female ancestors" do
        paso.update_attributes(mother_id: nil)
        expect(rud.ineligible_paternal_grandmothers).not_to include irene,emily,rosa
      end
      it "includes female descendants" do
        expect(jack.ineligible_paternal_grandmothers).to include barbara,mary
      end
      it "includes all males" do
        expect(paul.ineligible_paternal_grandmothers).to include *@model.males
      end
      it "includes full siblings" do
        paul.update_attributes(mother_id: nil)
        expect(julian.ineligible_paternal_grandmothers).to include beatrix
      end
      it "includes paternal half siblings" do
        paul.update_attributes(mother_id: nil)
        expect(julian.ineligible_paternal_grandmothers).to include mary
      end
      it "does not include maternal half siblings (it might happen when a grandparent have a child with their child-in-law)" do
        paso.update_attributes(mother_id: nil)
        titty.update_attributes(father_id: nil, mother_id: irene)
        expect(rud.ineligible_paternal_grandmothers).not_to include titty
      end
      
    end

    describe "#ineligible_maternal_grandfathers" do
      it "returns nil if maternal_grandfather already set" do
        expect(rud.ineligible_maternal_grandfathers).to be nil
      end
      it "does not return nil if maternal_grandfather is not set" do
        expect(sam.ineligible_maternal_grandfathers).not_to be nil
      end 
      it "includes theirself" do
        expect(sam.ineligible_maternal_grandfathers).to include sam
      end
      it "does not include paternal male ancestors" do
        expect(barbara.ineligible_maternal_grandfathers).not_to include jack,bob
      end
      it "includes male descendants" do
        expect(paso.ineligible_maternal_grandfathers).to include rud,mark,sam,charlie,peter,steve
      end
      it "includes all females" do
        expect(paso.ineligible_maternal_grandfathers).to include *@model.females
      end
      it "includes full siblings" do
        expect(sue.ineligible_maternal_grandfathers).to include sam,charlie
      end
      it "includes maternal half siblings" do
        expect(jack.ineligible_maternal_grandfathers).to include tommy
      end
      it "does not include paternal half siblings (it might happen when a grandparent have a child with their child-in-law)" do
        michelle.update_attributes(father_id: nil)
        expect(julian.ineligible_maternal_grandfathers).not_to include ruben,peter,steve
      end      
    end

    describe "#ineligible_maternal_grandmothers" do
      it "returns nil if maternal_grandmother already set" do
        expect(rud.ineligible_maternal_grandmothers).to be nil
      end
      it "does not return nil if maternal_grandmother is not set" do
        expect(paul.ineligible_maternal_grandmothers).not_to be nil
      end 
      it "includes theirself" do
        expect(paul.ineligible_maternal_grandmothers).to include paul
      end
      it "includes mother, i.e., mother can't be maternal grandmother" do
        expect(paul.ineligible_maternal_grandmothers).to include terry
      end
      it "does not include paternal female ancestors" do
        expect(barbara.ineligible_maternal_grandmothers).not_to include alison,louise
      end
      it "includes female descendants" do
        expect(jack.ineligible_maternal_grandmothers).to include barbara,mary
      end
      it "includes all males" do
        expect(manuel.ineligible_maternal_grandmothers).to include *@model.males
      end
      it "includes full siblings" do
        michelle.update_attributes(mother_id: nil)
        expect(julian.ineligible_maternal_grandmothers).to include beatrix
      end
      it "includes maternal half siblings" do
        expect(tommy.ineligible_maternal_grandmothers).to include debby
      end
      it "does not include paternal half siblings (it might happen when a grandparent have a child with their child-in-law)" do
        michelle.update_attributes(mother_id: nil)
        expect(julian.ineligible_maternal_grandmothers).not_to include mary
      end      
    end

    describe "#ineligible_siblings" do
      it "includes theirself" do
        expect(rud.ineligible_siblings).to include rud
      end
      it "includes full siblings" do
        expect(rud.ineligible_siblings).to include mark,titty
      end
      it "does not include half siblings with other parent unset" do
        expect(peter.ineligible_siblings).not_to include ruben
      end
      it "includes half siblings with other parent set" do
        expect(peter.ineligible_siblings).to include mary
      end
      it "includes descendants" do
        expect(paso.ineligible_siblings).to include titty,rud,mark,peter,steve,sue,sam,charlie
      end
      it "includes ancestors" do
        expect(rud.ineligible_siblings).to include irene,paso,emily,tommy,jack,alison,luis,rosa,larry,louise,bob
      end
      it "includes all individuals with both parents set" do
        expect(rud.ineligible_siblings).to include *@model.all_with(:parents)
      end
      context 'when both parents are unset' do
        it "does not include individuals with both parents set (expect descendants)" do
          expect(manuel.ineligible_siblings).not_to include (@model.all_with(:parents) - manuel.descendants)
        end
      end
      context 'when mother is unset' do
        it "includes all individuals with father already set but different" do
          expect(ruben.ineligible_siblings).to include *@model.all_with(:father).where.not(father_id: ruben.father.id)
        end
        it "does not include individuals without father, except ancestors, descendants and siblings" do
          sam.update_attributes(father_id: nil)
          expect(ruben.ineligible_siblings).not_to include sam,ned,naomi,luis,rosa,larry,louise,bob,alison,maggie,mia
        end
      end
      context 'when father is unset' do
        before { peter.update_attributes(father_id: nil) }
        it "includes all individuals with mother already set but different" do
          expect(peter.ineligible_siblings).to include *@model.all_with(:mother).where.not(mother_id: peter.mother.id)
        end
        it "does not include individuals without mother, except ancestors, descendants and siblings" do
          sam.update_attributes(mother_id: nil)
          expect(peter.ineligible_siblings).not_to include sam,ned,naomi,maggie,mia
        end
      end
    end

    describe "#ineligible_children" do
      it "includes theirself" do
        expect(paul.ineligible_children).to include paul
      end
      it "includes ancestors" do
        expect(titty.ineligible_children).to include paso,irene,emily,tommy,jack,alison,luis,rosa,larry,louise,bob
      end
      it "includes full siblings" do
        expect(sam.ineligible_children).to include sue,charlie
      end
      it "includes all individuals with both parents" do
        expect(rud.ineligible_children).to include *@model.all_with(:parents)
      end
      context 'when receiver is male' do
        it "includes all individuals with father" do
          expect(manuel.ineligible_children).to include *@model.all_with(:father)
        end
        it "does not include maternal half siblings without father (i.e., the father can be the receiver itself)" do
          sam.update_attributes(father_id: nil)
          expect(charlie.ineligible_children).not_to include sam
        end
        it "includes maternal half siblings with father" do
          sam.update_attributes(father_id: rud.id)
          expect(charlie.ineligible_children).to include sam
        end
      end
      context 'when receiver is female' do
        it "includes all individuals with mother" do
          expect(titty.ineligible_children).to include *@model.all_with(:mother)
        end
        it "does not include paternal half siblings without mother (i.e., the mother can be the receiver itself)" do
          expect(beatrix.ineligible_children).not_to include ruben
        end
        it "includes paternal half siblings with mother" do
          expect(beatrix.ineligible_children).to include peter,steve,mary
        end
      end
    end

  end

  context 'when ineligibility checks involve only dates' do

    before { 
      @model = get_test_model({
        current_spouse: true, 
        ineligibility: :dates, 
        limit_ages: { min_male_procreation_age: 12, max_male_procreation_age: 75, min_female_procreation_age: 9, max_female_procreation_age: 50, max_male_life_expectancy: 110, max_female_life_expectancy: 110}
      }) 
    }
    include_context "unreleted people exist with dates"

    # describe "paul", :cin do
    #   subject {paul}
    #   its(:ineligible_mothers) {is_expected.to match_array @model.males + [michelle,mia,barbara,beatrix,mary,sue,emily,debby,louise,rosa] }

    # end
    # describe "titty", :cin do
    #   subject {titty}
    #   its(:ineligible_fathers) {is_expected.to match_array @model.females + [larry,julian,peter,steve,sam,charlie]}
    #   its(:ineligible_mothers) {is_expected.to match_array @model.males + [titty,beatrix,mary] }
    #   its(:ineligible_maternal_grandfathers) {is_expected.to match_array @model.females + [julian,ruben,peter,steve,sam,charlie]}
    # end

    # describe "paso" do
    #   subject { paso }
    #   its(:ineligible_fathers) {is_expected.to match_array @model.females + [manuel,paso,john,paul,rud,mark,ruben,julian,peter,steve,sam,charlie,larry] }
    #   its(:ineligible_mothers) {is_expected.to match_array @model.males + [terry,naomi,maggie,barbara,michelle,mia,sue,beatrix,mary,rosa,louise,irene,emily] }
    # end

    # describe "mia", :cin do
    #   subject { mia }
    #   its(:ineligible_children) {is_expected.to match_array [mia,barbara,mark,rud,paul,michelle,maggie,john,paso,irene,manuel,terry,naomi,ned,alison,jack,debby,tommy,emily,marcel,bob,louise,larry,rosa,luis] }
    #   its(:ineligible_mothers) {is_expected.to match_array @model.males + [mia,michelle,beatrix,mary,sue,maggie,irene,emily,debby,alison,rosa,louise] }
      
    # end

    # describe "#ineligible_fathers" do
    #   it "returns nil if father already set" do
    #     expect(rud.ineligible_fathers).to be nil
    #   end
    #   it "does not return nil if father is not set" do
    #     expect(manuel.ineligible_fathers).not_to be nil
    #   end  
    #   it "includes theirself" do
    #     expect(manuel.ineligible_fathers).to include manuel
    #   end
    #   it "includes all females" do
    #     expect(manuel.ineligible_fathers).to include *@model.females
    #   end
    #   it "does not include male ancestors (e.g., maternal grandfather)" do
    #     rud.update_attributes(father_id: nil)
    #     expect(rud.ineligible_fathers).not_to include luis,larry,tommy
    #   end
    #   it "includes male descendants" do
    #     expect(alison.ineligible_fathers).to include paso,john,rud,mark,peter,steve,sam,charlie
    #   end
    #   it "does not include male maternal half siblings" do
    #     steve.update_attributes(father_id: nil)
    #     expect(steve.ineligible_fathers).not_to include peter
    #   end
    # end

    # describe "#ineligible_mothers" do
    #   it "returns nil if mother already set" do
    #     expect(rud.ineligible_mothers).to be nil
    #   end
    #   it "does not return nil if mother is not set" do
    #     expect(mia.ineligible_mothers).not_to be nil
    #   end  
    #   it "includes theirself" do
    #     expect(manuel.ineligible_mothers).to include manuel
    #   end
    #   it "includes all males" do
    #     expect(manuel.ineligible_mothers).to include *@model.males
    #   end
    #   it "does not include female ancestors (e.g., paternal grandmother)" do
    #     rud.update_attributes(mother_id: nil)
    #     expect(rud.ineligible_mothers).not_to include alison
    #   end
    #   it "includes female descendants" do
    #     expect(alison.ineligible_mothers).to include titty,sue
    #   end
    #   it "does not include female paternal half siblings" do
    #     expect(ruben.ineligible_mothers).not_to include mary
    #   end
    # end

    # describe "#ineligible_paternal_grandfathers" do
    #   it "returns nil if paternal_grandfather already set" do
    #     expect(rud.ineligible_paternal_grandfathers).to be nil
    #   end
    #   it "does not return nil if paternal_grandfather is not set" do
    #     expect(paul.ineligible_paternal_grandfathers).not_to be nil
    #   end 
    #   it "includes theirself" do
    #     expect(paul.ineligible_paternal_grandfathers).to include paul
    #   end
    #   it "includes father (i.e., father can't be paternal grandfather)" do
    #     expect(paul.ineligible_paternal_grandfathers).to include manuel
    #   end
    #   it "does not include maternal male ancestors" do
    #     expect(paul.ineligible_paternal_grandfathers).not_to include marcel
    #   end
    #   it "includes male descendants" do
    #     expect(jack.ineligible_paternal_grandfathers).to include rud,mark,sam,charlie,peter,steve
    #   end
    #   it "includes all females" do
    #     expect(manuel.ineligible_paternal_grandfathers).to include *@model.females
    #   end
    #   it "includes full siblings" do
    #     paul.update_attributes(father_id: nil)
    #     expect(peter.ineligible_paternal_grandfathers).to include steve
    #   end
    #   it "includes paternal half siblings" do
    #     paul.update_attributes(father_id: nil)
    #     expect(peter.ineligible_paternal_grandfathers).to include julian,ruben
    #   end
    #   it "does not include maternal half siblings (it might happen when a grandparent have a child with their child-in-law)" do
    #     paul.update_attributes(father_id: nil)
    #     ruben.update_attributes(father_id: nil, mother_id: titty)
    #     expect(peter.ineligible_paternal_grandfathers).not_to include ruben
    #   end
    # end

    # describe "#ineligible_paternal_grandmothers" do
    #   it "returns nil if paternal_grandmother already set" do
    #     expect(rud.ineligible_paternal_grandmothers).to be nil
    #   end
    #   it "does not return nil if paternal_grandmother is not set" do
    #     expect(paul.ineligible_paternal_grandmothers).not_to be nil
    #   end 
    #   it "includes theirself" do
    #     expect(mia.ineligible_paternal_grandmothers).to include mia
    #   end
    #   it "does not include maternal female ancestors" do
    #     paso.update_attributes(mother_id: nil)
    #     expect(rud.ineligible_paternal_grandmothers).not_to include irene,emily,rosa
    #   end
    #   it "includes female descendants" do
    #     expect(jack.ineligible_paternal_grandmothers).to include barbara,mary
    #   end
    #   it "includes all males" do
    #     expect(paul.ineligible_paternal_grandmothers).to include *@model.males
    #   end
    #   it "includes full siblings" do
    #     paul.update_attributes(mother_id: nil)
    #     expect(julian.ineligible_paternal_grandmothers).to include beatrix
    #   end
    #   it "includes paternal half siblings" do
    #     paul.update_attributes(mother_id: nil)
    #     expect(julian.ineligible_paternal_grandmothers).to include mary
    #   end
    #   it "does not include maternal half siblings (it might happen when a grandparent have a child with their child-in-law)" do
    #     paso.update_attributes(mother_id: nil)
    #     titty.update_attributes(father_id: nil, mother_id: irene)
    #     expect(rud.ineligible_paternal_grandmothers).not_to include titty
    #   end
      
    # end

    # describe "#ineligible_maternal_grandfathers" do
    #   it "returns nil if maternal_grandfather already set" do
    #     expect(rud.ineligible_maternal_grandfathers).to be nil
    #   end
    #   it "does not return nil if maternal_grandfather is not set" do
    #     expect(sam.ineligible_maternal_grandfathers).not_to be nil
    #   end 
    #   it "includes theirself" do
    #     expect(sam.ineligible_maternal_grandfathers).to include sam
    #   end
    #   it "does not include paternal male ancestors" do
    #     expect(barbara.ineligible_maternal_grandfathers).not_to include jack,bob
    #   end
    #   it "includes male descendants" do
    #     expect(paso.ineligible_maternal_grandfathers).to include rud,mark,sam,charlie,peter,steve
    #   end
    #   it "includes all females" do
    #     expect(paso.ineligible_maternal_grandfathers).to include *@model.females
    #   end
    #   it "includes full siblings" do
    #     expect(sue.ineligible_maternal_grandfathers).to include sam,charlie
    #   end
    #   it "includes maternal half siblings" do
    #     expect(jack.ineligible_maternal_grandfathers).to include tommy
    #   end
    #   it "does not include paternal half siblings (it might happen when a grandparent have a child with their child-in-law)" do
    #     michelle.update_attributes(father_id: nil)
    #     expect(julian.ineligible_maternal_grandfathers).not_to include ruben,peter,steve
    #   end      
    # end

    # describe "#ineligible_maternal_grandmothers" do
    #   it "returns nil if maternal_grandmother already set" do
    #     expect(rud.ineligible_maternal_grandmothers).to be nil
    #   end
    #   it "does not return nil if maternal_grandmother is not set" do
    #     expect(paul.ineligible_maternal_grandmothers).not_to be nil
    #   end 
    #   it "includes theirself" do
    #     expect(paul.ineligible_maternal_grandmothers).to include paul
    #   end
    #   it "includes mother, i.e., mother can't be maternal grandmother" do
    #     expect(paul.ineligible_maternal_grandmothers).to include terry
    #   end
    #   it "does not include paternal female ancestors" do
    #     expect(barbara.ineligible_maternal_grandmothers).not_to include alison,louise
    #   end
    #   it "includes female descendants" do
    #     expect(jack.ineligible_maternal_grandmothers).to include barbara,mary
    #   end
    #   it "includes all males" do
    #     expect(manuel.ineligible_maternal_grandmothers).to include *@model.males
    #   end
    #   it "includes full siblings" do
    #     michelle.update_attributes(mother_id: nil)
    #     expect(julian.ineligible_maternal_grandmothers).to include beatrix
    #   end
    #   it "includes maternal half siblings" do
    #     expect(tommy.ineligible_maternal_grandmothers).to include debby
    #   end
    #   it "does not include paternal half siblings (it might happen when a grandparent have a child with their child-in-law)" do
    #     michelle.update_attributes(mother_id: nil)
    #     expect(julian.ineligible_maternal_grandmothers).not_to include mary
    #   end      
    # end

    # describe "#ineligible_siblings" do
    #   it "includes theirself" do
    #     expect(rud.ineligible_siblings).to include rud
    #   end
    #   it "includes full siblings" do
    #     expect(rud.ineligible_siblings).to include mark,titty
    #   end
    #   it "does not include half siblings with other parent unset" do
    #     expect(peter.ineligible_siblings).not_to include ruben
    #   end
    #   it "includes half siblings with other parent set" do
    #     expect(peter.ineligible_siblings).to include mary
    #   end
    #   it "includes descendants" do
    #     expect(paso.ineligible_siblings).to include titty,rud,mark,peter,steve,sue,sam,charlie
    #   end
    #   it "includes ancestors" do
    #     expect(rud.ineligible_siblings).to include irene,paso,emily,tommy,jack,alison,luis,rosa,larry,louise,bob
    #   end
    #   it "includes all individuals with both parents set" do
    #     expect(rud.ineligible_siblings).to include *@model.all_with(:parents)
    #   end
    #   context 'when both parents are unset' do
    #     it "does not include individuals with both parents set (expect descendants)" do
    #       expect(manuel.ineligible_siblings).not_to include (@model.all_with(:parents) - manuel.descendants)
    #     end
    #   end
    #   context 'when mother is unset' do
    #     it "includes all individuals with father already set but different" do
    #       expect(ruben.ineligible_siblings).to include *@model.all_with(:father).where.not(father_id: ruben.father.id)
    #     end
    #     it "does not include individuals without father, except ancestors, descendants and siblings" do
    #       sam.update_attributes(father_id: nil)
    #       expect(ruben.ineligible_siblings).not_to include sam,ned,naomi,luis,rosa,larry,louise,bob,alison,maggie,mia
    #     end
    #   end
    #   context 'when father is unset' do
    #     before { peter.update_attributes(father_id: nil) }
    #     it "includes all individuals with mother already set but different" do
    #       expect(peter.ineligible_siblings).to include *@model.all_with(:mother).where.not(mother_id: peter.mother.id)
    #     end
    #     it "does not include individuals without mother, except ancestors, descendants and siblings" do
    #       sam.update_attributes(mother_id: nil)
    #       expect(peter.ineligible_siblings).not_to include sam,ned,naomi,maggie,mia
    #     end
    #   end
    # end

    # describe "#ineligible_children" do
    #   it "includes theirself" do
    #     expect(paul.ineligible_children).to include paul
    #   end
    #   it "includes ancestors" do
    #     expect(titty.ineligible_children).to include paso,irene,emily,tommy,jack,alison,luis,rosa,larry,louise,bob
    #   end
    #   it "includes full siblings" do
    #     expect(sam.ineligible_children).to include sue,charlie
    #   end
    #   it "includes all individuals with both parents" do
    #     expect(rud.ineligible_children).to include *@model.all_with(:parents)
    #   end
    #   context 'when receiver is male' do
    #     it "includes all individuals with father" do
    #       expect(manuel.ineligible_children).to include *@model.all_with(:father)
    #     end
    #     it "does not include maternal half siblings without father (i.e., the father can be the receiver itself)" do
    #       sam.update_attributes(father_id: nil)
    #       expect(charlie.ineligible_children).not_to include sam
    #     end
    #     it "includes maternal half siblings with father" do
    #       sam.update_attributes(father_id: rud.id)
    #       expect(charlie.ineligible_children).to include sam
    #     end
    #   end
    #   context 'when receiver is female' do
    #     it "includes all individuals with mother" do
    #       expect(titty.ineligible_children).to include *@model.all_with(:mother)
    #     end
    #     it "does not include paternal half siblings without mother (i.e., the mother can be the receiver itself)" do
    #       expect(beatrix.ineligible_children).not_to include ruben
    #     end
    #     it "includes paternal half siblings with mother" do
    #       expect(beatrix.ineligible_children).to include peter,steve,mary
    #     end
    #   end

  end

  context 'when ineligibility checks involve pedigree and dates' do
    # before { @model = get_test_model({current_spouse: true }) }  
    # include_context "pedigree exists" #all following examples are based on sample pedigree

    # describe "#ineligible_fathers" do
    #   it "returns nil if father already set" do
    #     expect(rud.ineligible_fathers).to be nil
    #   end
    #   it "does not return nil if father is not set" do
    #     expect(manuel.ineligible_fathers).not_to be nil
    #   end  
    #   it "includes theirself" do
    #     expect(manuel.ineligible_fathers).to include manuel
    #   end
    #   it "includes all females" do
    #     expect(manuel.ineligible_fathers).to include *@model.females
    #   end
    #   it "does not include male ancestors (e.g., maternal grandfather)" do
    #     rud.update_attributes(father_id: nil)
    #     expect(rud.ineligible_fathers).not_to include luis,larry,tommy
    #   end
    #   it "includes male descendants" do
    #     expect(alison.ineligible_fathers).to include paso,john,rud,mark,peter,steve,sam,charlie
    #   end
    #   it "does not include male maternal half siblings" do
    #     steve.update_attributes(father_id: nil)
    #     expect(steve.ineligible_fathers).not_to include peter
    #   end
    # end

    # describe "#ineligible_mothers" do
    #   it "returns nil if mother already set" do
    #     expect(rud.ineligible_mothers).to be nil
    #   end
    #   it "does not return nil if mother is not set" do
    #     expect(mia.ineligible_mothers).not_to be nil
    #   end  
    #   it "includes theirself" do
    #     expect(manuel.ineligible_mothers).to include manuel
    #   end
    #   it "includes all males" do
    #     expect(manuel.ineligible_mothers).to include *@model.males
    #   end
    #   it "does not include female ancestors (e.g., paternal grandmother)" do
    #     rud.update_attributes(mother_id: nil)
    #     expect(rud.ineligible_mothers).not_to include alison
    #   end
    #   it "includes female descendants" do
    #     expect(alison.ineligible_mothers).to include titty,sue
    #   end
    #   it "does not include female paternal half siblings" do
    #     expect(ruben.ineligible_mothers).not_to include mary
    #   end
    # end

    # describe "#ineligible_paternal_grandfathers" do
    #   it "returns nil if paternal_grandfather already set" do
    #     expect(rud.ineligible_paternal_grandfathers).to be nil
    #   end
    #   it "does not return nil if paternal_grandfather is not set" do
    #     expect(paul.ineligible_paternal_grandfathers).not_to be nil
    #   end 
    #   it "includes theirself" do
    #     expect(paul.ineligible_paternal_grandfathers).to include paul
    #   end
    #   it "includes father (i.e., father can't be paternal grandfather)" do
    #     expect(paul.ineligible_paternal_grandfathers).to include manuel
    #   end
    #   it "does not include maternal male ancestors" do
    #     expect(paul.ineligible_paternal_grandfathers).not_to include marcel
    #   end
    #   it "includes male descendants" do
    #     expect(jack.ineligible_paternal_grandfathers).to include rud,mark,sam,charlie,peter,steve
    #   end
    #   it "includes all females" do
    #     expect(manuel.ineligible_paternal_grandfathers).to include *@model.females
    #   end
    #   it "includes full siblings" do
    #     paul.update_attributes(father_id: nil)
    #     expect(peter.ineligible_paternal_grandfathers).to include steve
    #   end
    #   it "includes paternal half siblings" do
    #     paul.update_attributes(father_id: nil)
    #     expect(peter.ineligible_paternal_grandfathers).to include julian,ruben
    #   end
    #   it "does not include maternal half siblings (it might happen when a grandparent have a child with their child-in-law)" do
    #     paul.update_attributes(father_id: nil)
    #     ruben.update_attributes(father_id: nil, mother_id: titty)
    #     expect(peter.ineligible_paternal_grandfathers).not_to include ruben
    #   end
    # end

    # describe "#ineligible_paternal_grandmothers" do
    #   it "returns nil if paternal_grandmother already set" do
    #     expect(rud.ineligible_paternal_grandmothers).to be nil
    #   end
    #   it "does not return nil if paternal_grandmother is not set" do
    #     expect(paul.ineligible_paternal_grandmothers).not_to be nil
    #   end 
    #   it "includes theirself" do
    #     expect(mia.ineligible_paternal_grandmothers).to include mia
    #   end
    #   it "does not include maternal female ancestors" do
    #     paso.update_attributes(mother_id: nil)
    #     expect(rud.ineligible_paternal_grandmothers).not_to include irene,emily,rosa
    #   end
    #   it "includes female descendants" do
    #     expect(jack.ineligible_paternal_grandmothers).to include barbara,mary
    #   end
    #   it "includes all males" do
    #     expect(paul.ineligible_paternal_grandmothers).to include *@model.males
    #   end
    #   it "includes full siblings" do
    #     paul.update_attributes(mother_id: nil)
    #     expect(julian.ineligible_paternal_grandmothers).to include beatrix
    #   end
    #   it "includes paternal half siblings" do
    #     paul.update_attributes(mother_id: nil)
    #     expect(julian.ineligible_paternal_grandmothers).to include mary
    #   end
    #   it "does not include maternal half siblings (it might happen when a grandparent have a child with their child-in-law)" do
    #     paso.update_attributes(mother_id: nil)
    #     titty.update_attributes(father_id: nil, mother_id: irene)
    #     expect(rud.ineligible_paternal_grandmothers).not_to include titty
    #   end
      
    # end

    # describe "#ineligible_maternal_grandfathers" do
    #   it "returns nil if maternal_grandfather already set" do
    #     expect(rud.ineligible_maternal_grandfathers).to be nil
    #   end
    #   it "does not return nil if maternal_grandfather is not set" do
    #     expect(sam.ineligible_maternal_grandfathers).not_to be nil
    #   end 
    #   it "includes theirself" do
    #     expect(sam.ineligible_maternal_grandfathers).to include sam
    #   end
    #   it "does not include paternal male ancestors" do
    #     expect(barbara.ineligible_maternal_grandfathers).not_to include jack,bob
    #   end
    #   it "includes male descendants" do
    #     expect(paso.ineligible_maternal_grandfathers).to include rud,mark,sam,charlie,peter,steve
    #   end
    #   it "includes all females" do
    #     expect(paso.ineligible_maternal_grandfathers).to include *@model.females
    #   end
    #   it "includes full siblings" do
    #     expect(sue.ineligible_maternal_grandfathers).to include sam,charlie
    #   end
    #   it "includes maternal half siblings" do
    #     expect(jack.ineligible_maternal_grandfathers).to include tommy
    #   end
    #   it "does not include paternal half siblings (it might happen when a grandparent have a child with their child-in-law)" do
    #     michelle.update_attributes(father_id: nil)
    #     expect(julian.ineligible_maternal_grandfathers).not_to include ruben,peter,steve
    #   end      
    # end

    # describe "#ineligible_maternal_grandmothers" do
    #   it "returns nil if maternal_grandmother already set" do
    #     expect(rud.ineligible_maternal_grandmothers).to be nil
    #   end
    #   it "does not return nil if maternal_grandmother is not set" do
    #     expect(paul.ineligible_maternal_grandmothers).not_to be nil
    #   end 
    #   it "includes theirself" do
    #     expect(paul.ineligible_maternal_grandmothers).to include paul
    #   end
    #   it "includes mother, i.e., mother can't be maternal grandmother" do
    #     expect(paul.ineligible_maternal_grandmothers).to include terry
    #   end
    #   it "does not include paternal female ancestors" do
    #     expect(barbara.ineligible_maternal_grandmothers).not_to include alison,louise
    #   end
    #   it "includes female descendants" do
    #     expect(jack.ineligible_maternal_grandmothers).to include barbara,mary
    #   end
    #   it "includes all males" do
    #     expect(manuel.ineligible_maternal_grandmothers).to include *@model.males
    #   end
    #   it "includes full siblings" do
    #     michelle.update_attributes(mother_id: nil)
    #     expect(julian.ineligible_maternal_grandmothers).to include beatrix
    #   end
    #   it "includes maternal half siblings" do
    #     expect(tommy.ineligible_maternal_grandmothers).to include debby
    #   end
    #   it "does not include paternal half siblings (it might happen when a grandparent have a child with their child-in-law)" do
    #     michelle.update_attributes(mother_id: nil)
    #     expect(julian.ineligible_maternal_grandmothers).not_to include mary
    #   end      
    # end

    # describe "#ineligible_siblings" do
    #   it "includes theirself" do
    #     expect(rud.ineligible_siblings).to include rud
    #   end
    #   it "includes full siblings" do
    #     expect(rud.ineligible_siblings).to include mark,titty
    #   end
    #   it "does not include half siblings with other parent unset" do
    #     expect(peter.ineligible_siblings).not_to include ruben
    #   end
    #   it "includes half siblings with other parent set" do
    #     expect(peter.ineligible_siblings).to include mary
    #   end
    #   it "includes descendants" do
    #     expect(paso.ineligible_siblings).to include titty,rud,mark,peter,steve,sue,sam,charlie
    #   end
    #   it "includes ancestors" do
    #     expect(rud.ineligible_siblings).to include irene,paso,emily,tommy,jack,alison,luis,rosa,larry,louise,bob
    #   end
    #   it "includes all individuals with both parents set" do
    #     expect(rud.ineligible_siblings).to include *@model.all_with(:parents)
    #   end
    #   context 'when both parents are unset' do
    #     it "does not include individuals with both parents set (expect descendants)" do
    #       expect(manuel.ineligible_siblings).not_to include (@model.all_with(:parents) - manuel.descendants)
    #     end
    #   end
    #   context 'when mother is unset' do
    #     it "includes all individuals with father already set but different" do
    #       expect(ruben.ineligible_siblings).to include *@model.all_with(:father).where.not(father_id: ruben.father.id)
    #     end
    #     it "does not include individuals without father, except ancestors, descendants and siblings" do
    #       sam.update_attributes(father_id: nil)
    #       expect(ruben.ineligible_siblings).not_to include sam,ned,naomi,luis,rosa,larry,louise,bob,alison,maggie,mia
    #     end
    #   end
    #   context 'when father is unset' do
    #     before { peter.update_attributes(father_id: nil) }
    #     it "includes all individuals with mother already set but different" do
    #       expect(peter.ineligible_siblings).to include *@model.all_with(:mother).where.not(mother_id: peter.mother.id)
    #     end
    #     it "does not include individuals without mother, except ancestors, descendants and siblings" do
    #       sam.update_attributes(mother_id: nil)
    #       expect(peter.ineligible_siblings).not_to include sam,ned,naomi,maggie,mia
    #     end
    #   end
    # end

    # describe "#ineligible_children" do
    #   it "includes theirself" do
    #     expect(paul.ineligible_children).to include paul
    #   end
    #   it "includes ancestors" do
    #     expect(titty.ineligible_children).to include paso,irene,emily,tommy,jack,alison,luis,rosa,larry,louise,bob
    #   end
    #   it "includes full siblings" do
    #     expect(sam.ineligible_children).to include sue,charlie
    #   end
    #   it "includes all individuals with both parents" do
    #     expect(rud.ineligible_children).to include *@model.all_with(:parents)
    #   end
    #   context 'when receiver is male' do
    #     it "includes all individuals with father" do
    #       expect(manuel.ineligible_children).to include *@model.all_with(:father)
    #     end
    #     it "does not include maternal half siblings without father (i.e., the father can be the receiver itself)" do
    #       sam.update_attributes(father_id: nil)
    #       expect(charlie.ineligible_children).not_to include sam
    #     end
    #     it "includes maternal half siblings with father" do
    #       sam.update_attributes(father_id: rud.id)
    #       expect(charlie.ineligible_children).to include sam
    #     end
    #   end
    #   context 'when receiver is female' do
    #     it "includes all individuals with mother" do
    #       expect(titty.ineligible_children).to include *@model.all_with(:mother)
    #     end
    #     it "does not include paternal half siblings without mother (i.e., the mother can be the receiver itself)" do
    #       expect(beatrix.ineligible_children).not_to include ruben
    #     end
    #     it "includes paternal half siblings with mother" do
    #       expect(beatrix.ineligible_children).to include peter,steve,mary
    #     end
    #   end

  end

  context 'when ineligibility checks are turned off' do
    # before { @model = get_test_model({current_spouse: true }) }  
    # include_context "pedigree exists" #all following examples are based on sample pedigree

    # describe "#ineligible_fathers" do
    #   it "returns nil if father already set" do
    #     expect(rud.ineligible_fathers).to be nil
    #   end
    #   it "does not return nil if father is not set" do
    #     expect(manuel.ineligible_fathers).not_to be nil
    #   end  
    #   it "includes theirself" do
    #     expect(manuel.ineligible_fathers).to include manuel
    #   end
    #   it "includes all females" do
    #     expect(manuel.ineligible_fathers).to include *@model.females
    #   end
    #   it "does not include male ancestors (e.g., maternal grandfather)" do
    #     rud.update_attributes(father_id: nil)
    #     expect(rud.ineligible_fathers).not_to include luis,larry,tommy
    #   end
    #   it "includes male descendants" do
    #     expect(alison.ineligible_fathers).to include paso,john,rud,mark,peter,steve,sam,charlie
    #   end
    #   it "does not include male maternal half siblings" do
    #     steve.update_attributes(father_id: nil)
    #     expect(steve.ineligible_fathers).not_to include peter
    #   end
    # end

    # describe "#ineligible_mothers" do
    #   it "returns nil if mother already set" do
    #     expect(rud.ineligible_mothers).to be nil
    #   end
    #   it "does not return nil if mother is not set" do
    #     expect(mia.ineligible_mothers).not_to be nil
    #   end  
    #   it "includes theirself" do
    #     expect(manuel.ineligible_mothers).to include manuel
    #   end
    #   it "includes all males" do
    #     expect(manuel.ineligible_mothers).to include *@model.males
    #   end
    #   it "does not include female ancestors (e.g., paternal grandmother)" do
    #     rud.update_attributes(mother_id: nil)
    #     expect(rud.ineligible_mothers).not_to include alison
    #   end
    #   it "includes female descendants" do
    #     expect(alison.ineligible_mothers).to include titty,sue
    #   end
    #   it "does not include female paternal half siblings" do
    #     expect(ruben.ineligible_mothers).not_to include mary
    #   end
    # end

    # describe "#ineligible_paternal_grandfathers" do
    #   it "returns nil if paternal_grandfather already set" do
    #     expect(rud.ineligible_paternal_grandfathers).to be nil
    #   end
    #   it "does not return nil if paternal_grandfather is not set" do
    #     expect(paul.ineligible_paternal_grandfathers).not_to be nil
    #   end 
    #   it "includes theirself" do
    #     expect(paul.ineligible_paternal_grandfathers).to include paul
    #   end
    #   it "includes father (i.e., father can't be paternal grandfather)" do
    #     expect(paul.ineligible_paternal_grandfathers).to include manuel
    #   end
    #   it "does not include maternal male ancestors" do
    #     expect(paul.ineligible_paternal_grandfathers).not_to include marcel
    #   end
    #   it "includes male descendants" do
    #     expect(jack.ineligible_paternal_grandfathers).to include rud,mark,sam,charlie,peter,steve
    #   end
    #   it "includes all females" do
    #     expect(manuel.ineligible_paternal_grandfathers).to include *@model.females
    #   end
    #   it "includes full siblings" do
    #     paul.update_attributes(father_id: nil)
    #     expect(peter.ineligible_paternal_grandfathers).to include steve
    #   end
    #   it "includes paternal half siblings" do
    #     paul.update_attributes(father_id: nil)
    #     expect(peter.ineligible_paternal_grandfathers).to include julian,ruben
    #   end
    #   it "does not include maternal half siblings (it might happen when a grandparent have a child with their child-in-law)" do
    #     paul.update_attributes(father_id: nil)
    #     ruben.update_attributes(father_id: nil, mother_id: titty)
    #     expect(peter.ineligible_paternal_grandfathers).not_to include ruben
    #   end
    # end

    # describe "#ineligible_paternal_grandmothers" do
    #   it "returns nil if paternal_grandmother already set" do
    #     expect(rud.ineligible_paternal_grandmothers).to be nil
    #   end
    #   it "does not return nil if paternal_grandmother is not set" do
    #     expect(paul.ineligible_paternal_grandmothers).not_to be nil
    #   end 
    #   it "includes theirself" do
    #     expect(mia.ineligible_paternal_grandmothers).to include mia
    #   end
    #   it "does not include maternal female ancestors" do
    #     paso.update_attributes(mother_id: nil)
    #     expect(rud.ineligible_paternal_grandmothers).not_to include irene,emily,rosa
    #   end
    #   it "includes female descendants" do
    #     expect(jack.ineligible_paternal_grandmothers).to include barbara,mary
    #   end
    #   it "includes all males" do
    #     expect(paul.ineligible_paternal_grandmothers).to include *@model.males
    #   end
    #   it "includes full siblings" do
    #     paul.update_attributes(mother_id: nil)
    #     expect(julian.ineligible_paternal_grandmothers).to include beatrix
    #   end
    #   it "includes paternal half siblings" do
    #     paul.update_attributes(mother_id: nil)
    #     expect(julian.ineligible_paternal_grandmothers).to include mary
    #   end
    #   it "does not include maternal half siblings (it might happen when a grandparent have a child with their child-in-law)" do
    #     paso.update_attributes(mother_id: nil)
    #     titty.update_attributes(father_id: nil, mother_id: irene)
    #     expect(rud.ineligible_paternal_grandmothers).not_to include titty
    #   end
      
    # end

    # describe "#ineligible_maternal_grandfathers" do
    #   it "returns nil if maternal_grandfather already set" do
    #     expect(rud.ineligible_maternal_grandfathers).to be nil
    #   end
    #   it "does not return nil if maternal_grandfather is not set" do
    #     expect(sam.ineligible_maternal_grandfathers).not_to be nil
    #   end 
    #   it "includes theirself" do
    #     expect(sam.ineligible_maternal_grandfathers).to include sam
    #   end
    #   it "does not include paternal male ancestors" do
    #     expect(barbara.ineligible_maternal_grandfathers).not_to include jack,bob
    #   end
    #   it "includes male descendants" do
    #     expect(paso.ineligible_maternal_grandfathers).to include rud,mark,sam,charlie,peter,steve
    #   end
    #   it "includes all females" do
    #     expect(paso.ineligible_maternal_grandfathers).to include *@model.females
    #   end
    #   it "includes full siblings" do
    #     expect(sue.ineligible_maternal_grandfathers).to include sam,charlie
    #   end
    #   it "includes maternal half siblings" do
    #     expect(jack.ineligible_maternal_grandfathers).to include tommy
    #   end
    #   it "does not include paternal half siblings (it might happen when a grandparent have a child with their child-in-law)" do
    #     michelle.update_attributes(father_id: nil)
    #     expect(julian.ineligible_maternal_grandfathers).not_to include ruben,peter,steve
    #   end      
    # end

    # describe "#ineligible_maternal_grandmothers" do
    #   it "returns nil if maternal_grandmother already set" do
    #     expect(rud.ineligible_maternal_grandmothers).to be nil
    #   end
    #   it "does not return nil if maternal_grandmother is not set" do
    #     expect(paul.ineligible_maternal_grandmothers).not_to be nil
    #   end 
    #   it "includes theirself" do
    #     expect(paul.ineligible_maternal_grandmothers).to include paul
    #   end
    #   it "includes mother, i.e., mother can't be maternal grandmother" do
    #     expect(paul.ineligible_maternal_grandmothers).to include terry
    #   end
    #   it "does not include paternal female ancestors" do
    #     expect(barbara.ineligible_maternal_grandmothers).not_to include alison,louise
    #   end
    #   it "includes female descendants" do
    #     expect(jack.ineligible_maternal_grandmothers).to include barbara,mary
    #   end
    #   it "includes all males" do
    #     expect(manuel.ineligible_maternal_grandmothers).to include *@model.males
    #   end
    #   it "includes full siblings" do
    #     michelle.update_attributes(mother_id: nil)
    #     expect(julian.ineligible_maternal_grandmothers).to include beatrix
    #   end
    #   it "includes maternal half siblings" do
    #     expect(tommy.ineligible_maternal_grandmothers).to include debby
    #   end
    #   it "does not include paternal half siblings (it might happen when a grandparent have a child with their child-in-law)" do
    #     michelle.update_attributes(mother_id: nil)
    #     expect(julian.ineligible_maternal_grandmothers).not_to include mary
    #   end      
    # end

    # describe "#ineligible_siblings" do
    #   it "includes theirself" do
    #     expect(rud.ineligible_siblings).to include rud
    #   end
    #   it "includes full siblings" do
    #     expect(rud.ineligible_siblings).to include mark,titty
    #   end
    #   it "does not include half siblings with other parent unset" do
    #     expect(peter.ineligible_siblings).not_to include ruben
    #   end
    #   it "includes half siblings with other parent set" do
    #     expect(peter.ineligible_siblings).to include mary
    #   end
    #   it "includes descendants" do
    #     expect(paso.ineligible_siblings).to include titty,rud,mark,peter,steve,sue,sam,charlie
    #   end
    #   it "includes ancestors" do
    #     expect(rud.ineligible_siblings).to include irene,paso,emily,tommy,jack,alison,luis,rosa,larry,louise,bob
    #   end
    #   it "includes all individuals with both parents set" do
    #     expect(rud.ineligible_siblings).to include *@model.all_with(:parents)
    #   end
    #   context 'when both parents are unset' do
    #     it "does not include individuals with both parents set (expect descendants)" do
    #       expect(manuel.ineligible_siblings).not_to include (@model.all_with(:parents) - manuel.descendants)
    #     end
    #   end
    #   context 'when mother is unset' do
    #     it "includes all individuals with father already set but different" do
    #       expect(ruben.ineligible_siblings).to include *@model.all_with(:father).where.not(father_id: ruben.father.id)
    #     end
    #     it "does not include individuals without father, except ancestors, descendants and siblings" do
    #       sam.update_attributes(father_id: nil)
    #       expect(ruben.ineligible_siblings).not_to include sam,ned,naomi,luis,rosa,larry,louise,bob,alison,maggie,mia
    #     end
    #   end
    #   context 'when father is unset' do
    #     before { peter.update_attributes(father_id: nil) }
    #     it "includes all individuals with mother already set but different" do
    #       expect(peter.ineligible_siblings).to include *@model.all_with(:mother).where.not(mother_id: peter.mother.id)
    #     end
    #     it "does not include individuals without mother, except ancestors, descendants and siblings" do
    #       sam.update_attributes(mother_id: nil)
    #       expect(peter.ineligible_siblings).not_to include sam,ned,naomi,maggie,mia
    #     end
    #   end
    # end

    # describe "#ineligible_children" do
    #   it "includes theirself" do
    #     expect(paul.ineligible_children).to include paul
    #   end
    #   it "includes ancestors" do
    #     expect(titty.ineligible_children).to include paso,irene,emily,tommy,jack,alison,luis,rosa,larry,louise,bob
    #   end
    #   it "includes full siblings" do
    #     expect(sam.ineligible_children).to include sue,charlie
    #   end
    #   it "includes all individuals with both parents" do
    #     expect(rud.ineligible_children).to include *@model.all_with(:parents)
    #   end
    #   context 'when receiver is male' do
    #     it "includes all individuals with father" do
    #       expect(manuel.ineligible_children).to include *@model.all_with(:father)
    #     end
    #     it "does not include maternal half siblings without father (i.e., the father can be the receiver itself)" do
    #       sam.update_attributes(father_id: nil)
    #       expect(charlie.ineligible_children).not_to include sam
    #     end
    #     it "includes maternal half siblings with father" do
    #       sam.update_attributes(father_id: rud.id)
    #       expect(charlie.ineligible_children).to include sam
    #     end
    #   end
    #   context 'when receiver is female' do
    #     it "includes all individuals with mother" do
    #       expect(titty.ineligible_children).to include *@model.all_with(:mother)
    #     end
    #     it "does not include paternal half siblings without mother (i.e., the mother can be the receiver itself)" do
    #       expect(beatrix.ineligible_children).not_to include ruben
    #     end
    #     it "includes paternal half siblings with mother" do
    #       expect(beatrix.ineligible_children).to include peter,steve,mary
    #     end
    #   end

  end

end
































