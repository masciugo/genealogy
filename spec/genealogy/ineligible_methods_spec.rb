require 'spec_helper'

shared_examples "including individuals because of basic checks" do |indiv_with,indiv_without,relationship,expected_sex|
  let(:iw) { eval(indiv_with.to_s) }
  let(:iwo) { eval(indiv_without.to_s) }
  method = "ineligible_#{relationship.to_s.pluralize}"
  unexpected_sex = Genealogy::Constants::OPPOSITESEX[expected_sex].to_s.pluralize
  it "returns nil if #{relationship} already set" do
    expect(iw.send(method)).to be nil
  end
  it "does not return nil if #{relationship} is not set" do
    expect(iwo.send(method)).not_to be nil
  end
  it "includes theirself" do
    expect(iwo.send(method)).to include iwo
  end
  it "includes all #{unexpected_sex}" do
    expect(iwo.send(method)).to include *@model.send(unexpected_sex)
  end
end

shared_examples "including fathers because of checks on pedigree" do
  it "includes male descendants" do
    expect(alison.ineligible_fathers).to include paso,john,rud,mark,peter,steve,sam,charlie
  end
end

shared_examples "including mothers because of checks on pedigree" do
  it "includes female descendants" do
    expect(alison.ineligible_mothers).to include titty,sue
  end
end

shared_examples "including paternal grandfathers because of checks on pedigree" do
  it "includes father (i.e., father can't be paternal grandfather)" do
    expect(paul.ineligible_paternal_grandfathers).to include manuel
  end
  it "includes male descendants" do
    expect(jack.ineligible_paternal_grandfathers).to include rud,mark,sam,charlie,peter,steve
  end
  it "includes full siblings" do
    paul.update_attributes(father_id: nil)
    expect(peter.ineligible_paternal_grandfathers).to include steve
  end
  it "includes paternal half siblings" do
    paul.update_attributes(father_id: nil)
    expect(peter.ineligible_paternal_grandfathers).to include julian,ruben
  end
end

shared_examples "including paternal grandmothers because of checks on pedigree" do
  it "includes female descendants" do
    expect(jack.ineligible_paternal_grandmothers).to include barbara,mary
  end
  it "includes full siblings" do
    paul.update_attributes(mother_id: nil)
    expect(julian.ineligible_paternal_grandmothers).to include beatrix
  end
  it "includes paternal half siblings" do
    paul.update_attributes(mother_id: nil)
    expect(julian.ineligible_paternal_grandmothers).to include mary
  end
end

shared_examples "including maternal grandfathers because of checks on pedigree" do
  it "includes male descendants" do
    expect(paso.ineligible_maternal_grandfathers).to include rud,mark,sam,charlie,peter,steve
  end
  it "includes full siblings" do
    expect(sue.ineligible_maternal_grandfathers).to include sam,charlie
  end
  it "includes maternal half siblings" do
    expect(jack.ineligible_maternal_grandfathers).to include tommy
  end
end

shared_examples "including maternal grandmothers because of checks on pedigree" do
  it "includes mother, i.e., mother can't be maternal grandmother" do
    expect(paul.ineligible_maternal_grandmothers).to include terry
  end
  it "includes female descendants" do
    expect(jack.ineligible_maternal_grandmothers).to include barbara,mary
  end
  it "includes full siblings" do
    michelle.update_attributes(mother_id: nil)
    expect(julian.ineligible_maternal_grandmothers).to include beatrix
  end
  it "includes maternal half siblings" do
    expect(tommy.ineligible_maternal_grandmothers).to include debby
  end
end

shared_examples "including siblings because of checks on pedigree" do
  it "includes full siblings" do
    expect(rud.ineligible_siblings).to include mark,titty
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
      expect(ruben.ineligible_siblings).to include *@model.all_with(:father).where("father_id != ?", ruben.father)
    end
  end
  context 'when father is unset' do
    before { peter.update_attributes(father_id: nil) }
    it "includes all individuals with mother already set but different" do
      expect(peter.ineligible_siblings).to include *@model.all_with(:mother).where("mother_id != ?", peter.mother.id)
    end
  end
end

shared_examples "including children because of checks on pedigree" do
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
    it "includes maternal half siblings with father" do
      sam.update_attributes(father_id: rud.id)
      expect(charlie.ineligible_children).to include sam
    end
  end
  context 'when receiver is female' do
    it "includes all individuals with mother" do
      expect(titty.ineligible_children).to include *@model.all_with(:mother)
    end
    it "includes paternal half siblings with mother" do
      expect(beatrix.ineligible_children).to include peter,steve,mary
    end
  end
end


describe "*** Ineligible methods ***", :ineligible do

  context 'when ineligibility checks involve only pedigree (default)' do
    before { @model = get_test_model({current_spouse: true }) }
    include_context "pedigree exists" #all following examples are based on sample pedigree

    describe "#ineligible_fathers" do
      it_behaves_like "including fathers because of checks on pedigree"
      it_behaves_like "including individuals because of basic checks", :rud, :manuel, :father, :male
      it "does not include male ancestors (e.g., maternal grandfather)" do
        rud.update_attributes(father_id: nil)
        expect(rud.ineligible_fathers).not_to include luis,larry,tommy
      end
      it "does not include male maternal half siblings" do
        steve.update_attributes(father_id: nil)
        expect(steve.ineligible_fathers).not_to include peter
      end
    end

    describe "#ineligible_mothers" do
      it_behaves_like "including mothers because of checks on pedigree"
      it_behaves_like "including individuals because of basic checks", :rud, :mia, :mother, :female
      it "does not include female ancestors (e.g., paternal grandmother)" do
        rud.update_attributes(mother_id: nil)
        expect(rud.ineligible_mothers).not_to include alison
      end
      it "does not include female paternal half siblings" do
        expect(ruben.ineligible_mothers).not_to include mary
      end
    end

    describe "#ineligible_paternal_grandfathers" do
      it_behaves_like "including paternal grandfathers because of checks on pedigree"
      it_behaves_like "including individuals because of basic checks", :rud, :paul, :paternal_grandfather, :male
      it "does not include maternal male ancestors" do
        expect(paul.ineligible_paternal_grandfathers).not_to include marcel
      end
      it "does not include maternal half siblings (it might happen when a grandparent have a child with their child-in-law)" do
        paul.update_attributes(father_id: nil)
        ruben.update_attributes(father_id: nil, mother_id: titty)
        expect(peter.ineligible_paternal_grandfathers).not_to include ruben
      end
    end

    describe "#ineligible_paternal_grandmothers"do
      it_behaves_like "including paternal grandmothers because of checks on pedigree"
      it_behaves_like "including individuals because of basic checks", :rud, :mia, :paternal_grandmother, :female
      it "does not include maternal female ancestors" do
        paso.update_attributes(mother_id: nil)
        expect(rud.ineligible_paternal_grandmothers).not_to include irene,emily,rosa
      end
      it "does not include maternal half siblings (it might happen when a grandparent have a child with their child-in-law)" do
        paso.update_attributes(mother_id: nil)
        titty.update_attributes(father_id: nil, mother_id: irene)
        expect(rud.ineligible_paternal_grandmothers).not_to include titty
      end
    end

    describe "#ineligible_maternal_grandfathers" do
      it_behaves_like "including maternal grandfathers because of checks on pedigree"
      it_behaves_like "including individuals because of basic checks", :rud, :sam, :maternal_grandfather, :male
      it "does not include paternal male ancestors" do
        expect(barbara.ineligible_maternal_grandfathers).not_to include jack,bob
      end
      it "does not include paternal half siblings (it might happen when a grandparent have a child with their child-in-law)" do
        michelle.update_attributes(father_id: nil)
        expect(julian.ineligible_maternal_grandfathers).not_to include ruben,peter,steve
      end
    end

    describe "#ineligible_maternal_grandmothers" do
      it_behaves_like "including maternal grandmothers because of checks on pedigree"
      it_behaves_like "including individuals because of basic checks", :rud, :paul, :maternal_grandmother, :female
      it "does not include paternal female ancestors" do
        expect(barbara.ineligible_maternal_grandmothers).not_to include alison,louise
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
      it_behaves_like "including siblings because of checks on pedigree"
      it "does not include half siblings with other parent unset" do
        expect(peter.ineligible_siblings).not_to include ruben
      end
      context 'when mother is unset' do
        it "does not include individuals without father, except ancestors, descendants and siblings" do
          sam.update_attributes(father_id: nil)
          expect(ruben.ineligible_siblings).not_to include sam,ned,naomi,luis,rosa,larry,louise,bob,alison,maggie,mia
        end
      end
      context 'when father is unset' do
        before { peter.update_attributes(father_id: nil) }
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
      it_behaves_like "including children because of checks on pedigree"
      context 'when receiver is male' do
        it "does not include maternal half siblings without father (i.e., the father can be the receiver itself)" do
          sam.update_attributes(father_id: nil)
          expect(charlie.ineligible_children).not_to include sam
        end
      end
      context 'when receiver is female' do
        it "does not include paternal half siblings without mother (i.e., the mother can be the receiver itself)" do
          expect(beatrix.ineligible_children).not_to include ruben
        end
      end
    end

  end

  context 'when ineligibility checks involve pedigree and dates' do

    before {
      @model = get_test_model({
        current_spouse: true,
        ineligibility: :pedigree_and_dates,
        limit_ages: { min_male_procreation_age: 12, max_male_procreation_age: 75, min_female_procreation_age: 9, max_female_procreation_age: 50, max_male_life_expectancy: 110, max_female_life_expectancy: 110}
      })
    }
    include_context "pedigree exists with dates" #all following examples are based on sample pedigree with dates

    describe "#ineligible_fathers" do
      it_behaves_like "including fathers because of checks on pedigree"
      it_behaves_like "including individuals because of basic checks", :rud, :manuel, :father, :male
      context 'when life range is estimable' do
        it "includes individuals too young (not fertile)" do
          expect(marcel.ineligible_fathers).to include tommy,jack and
          expect(manuel.ineligible_fathers).to include ned
        end
        it "includes individuals too young (not born yet)" do
          expect(alison.ineligible_fathers).to include mark and
          expect(manuel.ineligible_fathers).to include paso,john
        end
        it "includes individuals too old (not fertile)" do
          expect(mia.ineligible_fathers).to include jack,tommy
        end
        it "includes individuals too old (died)" do
          expect(marcel.ineligible_fathers).to include larry
        end
      end
    end

    describe "#ineligible_mothers" do
      it_behaves_like "including mothers because of checks on pedigree"
      it_behaves_like "including individuals because of basic checks", :rud, :mia, :mother, :female
      context 'when life range is estimable' do
        it "includes individuals too young (not fertile)" do
          expect(larry.ineligible_mothers).to include titty
        end
        it "includes individuals too young (not born yet)" do
          expect(naomi.ineligible_mothers).to include maggie,mia
        end
        it "includes individuals too old (not fertile)" do
          expect(manuel.ineligible_mothers).to include rosa
        end
        it "includes individuals too old (died)" do
          expect(naomi.ineligible_mothers).to include emily
        end
        it "does not includes individuals with birth date unknown (maybe still fertile)" do
          titty.update_attributes(father_id: nil, mother_id: nil)
          expect(bob.ineligible_mothers).not_to include titty
        end
        it "does not includes individuals born on mother's date of death" do
          naomi.update_attributes(death_date: Date.new(1952,4,17), birth_date: Date.new(1932,4,18))
          expect(maggie.ineligible_mothers).not_to include naomi
        end
      end
    end

    describe "#ineligible_paternal_grandfathers" do
      it_behaves_like "including paternal grandfathers because of checks on pedigree"
      it_behaves_like "including individuals because of basic checks", :rud, :paul, :paternal_grandfather, :male
      context 'when has father' do
        it "returns the same as father.ineligible_fathers" do
          expect(terry.ineligible_paternal_grandfathers).to match_array terry.father.ineligible_fathers
        end
      end
      context 'when does not have father' do
        it "includes individuals too young (not born yet)" do
          expect(naomi.ineligible_paternal_grandfathers).to include rud,paul,mark
        end
        it "includes individuals too old" do
          marcel.update_attributes(birth_date: Date.new(1834,4,17))
          expect(mia.ineligible_paternal_grandfathers).to include larry,marcel
        end
      end
    end

    describe "#ineligible_paternal_grandmothers" do
      it_behaves_like "including paternal grandmothers because of checks on pedigree"
      it_behaves_like "including individuals because of basic checks", :rud, :mia, :paternal_grandmother, :female
      context 'when has father' do
        it "returns the same as father.ineligible_mothers" do
          expect(paul.ineligible_paternal_grandmothers).to match_array paul.father.ineligible_mothers
        end
      end
      context 'when does not have father' do
        it "includes individuals too young (not born yet)" do
          expect(naomi.ineligible_paternal_grandmothers).to include maggie,barbara
        end
        it "includes individuals too young" do
          expect(maggie.ineligible_paternal_grandmothers).to include naomi,terry,irene
        end
        it "includes individuals too old" do
          rosa.update_attributes(birth_date: Date.new(183,10,6))
          expect(mia.ineligible_paternal_grandmothers).to include rosa
        end
      end
    end

    describe "#ineligible_maternal_grandfathers" do
      it_behaves_like "including maternal grandfathers because of checks on pedigree"
      it_behaves_like "including individuals because of basic checks", :rud, :sam, :maternal_grandfather, :male
      context 'when has mother' do
        it "returns the same as mother.ineligible_fathers" do
          expect(paso.ineligible_maternal_grandfathers).to match_array paso.mother.ineligible_fathers
        end
      end
      context 'when does not have mother' do
        it "includes individuals too young (not born yet)" do
          expect(naomi.ineligible_maternal_grandfathers).to include paul,mark
        end
        it "includes individuals too young" do
          expect(mia.ineligible_maternal_grandfathers).to include rud
        end
        it "includes individuals too old" do
          marcel.update_attributes(birth_date: Date.new(1834,4,17))
          expect(mia.ineligible_maternal_grandfathers).to include larry,marcel
        end
      end
    end

    describe "#ineligible_maternal_grandmothers"do
      it_behaves_like "including maternal grandmothers because of checks on pedigree"
      it_behaves_like "including individuals because of basic checks", :rud, :paul, :maternal_grandmother, :female

      context 'when has mother' do
        it "returns the same as mother.ineligible_mothers" do
          expect(paul.ineligible_maternal_grandmothers).to match_array paul.mother.ineligible_mothers
        end
      end
      context 'when does not have mother' do
        it "includes individuals too young (not born yet)" do
          expect(naomi.ineligible_maternal_grandmothers).to include maggie,barbara
        end
        it "includes individuals too young" do
          expect(maggie.ineligible_maternal_grandmothers).to include naomi,terry,irene
        end
        it "includes individuals too old" do
          rosa.update_attributes(birth_date: Date.new(183,10,6))
          expect(mia.ineligible_maternal_grandmothers).to include rosa
        end
      end
    end

    describe "#ineligible_siblings" do
      it_behaves_like "including siblings because of checks on pedigree"
      context "when receiver's parents are known" do
        it "includes individuals too young" do
          expect(debby.ineligible_siblings).to include mia,naomi,ned,terry,manuel,maggie,ruben and
          expect(emily.ineligible_siblings).to include manuel,naomi,maggie,ruben,mia
        end
        it "includes individuals too old" do
          expect(sue.ineligible_siblings).to include maggie,manuel,naomi,ned
        end
      end
      context "when receiver's parents are unknown" do
        it "includes individuals too young" do
          expect(larry.ineligible_siblings).to include mia,maggie,naomi,ned
        end
        it "includes individuals too old" do
          expect(naomi.ineligible_siblings).to include rosa,louise,larry and
          expect(mia.ineligible_siblings).to include alison,manuel,rosa,louise,larry,ned,marcel
        end
      end
    end

    describe "#ineligible_children" do
      it_behaves_like "including children because of checks on pedigree"
      it "includes individuals born before min fertility age" do
        expect(paul.ineligible_children).to include naomi,ned,maggie,alison
      end
      it "includes individuals born after death" do
        expect(irene.ineligible_children).to include mia,ruben
      end
      it "includes individuals born after max fertility age" do
        michelle.update_attributes(mother_id:nil)
        expect(debby.ineligible_children).to include mia,ruben and
        expect(alison.ineligible_children).to include mia,michelle and
        expect(tommy.ineligible_children).to include mia
      end
    end

  end

  context 'when ineligibility checks are turned off' do
  end

end
































