require 'spec_helper'

describe "*** Util methods ***", :util do
  before { @model = get_test_model({current_spouse: true, ineligibility: :pedigree_and_dates, limit_ages: { min_male_procreation_age: 12, max_male_procreation_age: 75, min_female_procreation_age: 9, max_female_procreation_age: 50, max_male_life_expectancy: 110, max_female_life_expectancy: 110} }) }
  
  include_context 'unreleted people exist'
  include_context 'individuals have dates'

  describe "#birth" do
    subject { louise.birth }
    it { is_expected.to be_instance_of Date }
    it "returns birth" do
      is_expected.to eq Date.new(1874,4,10)
    end
  end

  describe "#death" do
    subject { louise.death }
    it { is_expected.to be_instance_of Date }
    it "returns death" do
      is_expected.to eq Date.new(1930,8,7)
    end
  end

  describe "#life_range" do
    context 'when birth is known' do
      subject { paul.life_range }
      it { is_expected.to be_instance_of Range }
      it "returns birth..(birth + max life expectancy)" do
        is_expected.to eq paul.birth..(paul.birth+paul.max_le)
      end
      context 'and death is known' do
        subject { louise.life_range }
        it { is_expected.to be_instance_of Range }
        it "returns birth..death" do
          is_expected.to eq louise.birth..louise.death
        end
      end
    end
    context 'when only death is known' do
      subject { titty.life_range }
      it { is_expected.to be_instance_of Range }
      it "returns (death - max life expectancy)..death" do
        is_expected.to eq (titty.death-titty.max_le)..titty.death
      end
    end
    context 'when are both unknown' do
      subject { luis.life_range }
      it { is_expected.to be nil }
    end
  end

  describe "#birth_range" do
    context 'when birth is known' do
      subject { naomi.birth_range }
      it { is_expected.to be_instance_of Range }
      it "returns as birth..birth" do
        is_expected.to eq naomi.birth..naomi.birth
      end
    end
    context 'when only death is known' do
      subject { titty.birth_range }
      it { is_expected.to be_instance_of Range }
      it "returns (death - max life expectancy)..death" do
        is_expected.to eq (titty.death-titty.max_le)..titty.death
      end
    end
    context 'when are both unknown' do
      subject { luis.life_range }
      it { is_expected.to be nil }
    end
  end

  describe "#fertility_range" do
    context 'when birth is known' do
      subject { paul.fertility_range }
      it { is_expected.to be_instance_of Range }
      it "returns (birth + min procreation age)..(birth + max procreation age)" do
        is_expected.to eq (paul.birth+paul.min_fpa)..(paul.birth+paul.max_fpa)
      end
      context 'when death is known' do
        context 'and happens prior to fertility period' do
          subject { mary.fertility_range }
          it { is_expected.to be false }
        end
        context 'and happens during fertility period' do
          subject { maggie.fertility_range }
          it { is_expected.to be_instance_of Range }
          it "returns (birth + min procreation age)..death" do
            is_expected.to eq (maggie.birth+maggie.min_fpa)..maggie.death
          end
        end
        context 'and happens after fertility period' do
          subject { louise.fertility_range }
          it { is_expected.to be_instance_of Range }
          it "returns (birth + min procreation age)..(birth + max procreation age)" do
            is_expected.to eq (louise.birth+louise.min_fpa)..(louise.birth+louise.max_fpa)
          end
        end
      end
    end
    context 'when only death is known' do
      subject { titty.fertility_range }
      it { is_expected.to be_instance_of Range }
      it "returns (death - max life expectancy + min procreation age)..death" do
        is_expected.to eq (titty.death-titty.max_le+titty.min_fpa)..(titty.death)
      end
    end
    context 'when are both unknown' do
      subject { luis.fertility_range }
      it { is_expected.to be nil }
    end
  end

  describe "#can_procreate_on?" do
    context "when argument is a date covered by receiver's fertility range" do
      subject { louise.can_procreate_on? Date.new(1885,8,6) }
      it { is_expected.to be true }
    end
    context "when argument is a date not covered by receiver's fertility range" do
      subject { louise.can_procreate_on? Date.new(1950,8,6) }
      it { is_expected.to be false }
    end
    context "when receiver's fertility range is unknown" do
      subject { luis.can_procreate_on? Date.new(1950,8,6) }
      it { is_expected.to be nil }
    end
  end

  describe "#can_procreate_during?" do
    context "when argument is a range of dates overlapping receiver's fertility range" do
      subject { louise.can_procreate_during? Date.new(1885,8,6)..Date.new(1960,8,6) }
      it { is_expected.to be true }
    end
    context "when argument is a range of dates not overlapping receiver's fertility range" do
      subject { louise.can_procreate_during? Date.new(1940,8,6)..Date.new(1960,8,6) }
      it { is_expected.to be false }
    end
    context "when receiver's fertility range is unknown" do
      subject { luis.can_procreate_during? Date.new(1840,8,6)..Date.new(1960,8,6) }
      it { is_expected.to be nil }
    end
  end

  describe "#father_birth_range" do
    context "when birth is known" do
      subject { louise.father_birth_range }
      it { is_expected.to be_instance_of Range }
      it "returns (birth - max male fertility procreation age)..(birth - min male fertility procreation age)" do
        is_expected.to eq (louise.birth-@model.max_male_procreation_age.years)..(louise.birth-@model.min_male_procreation_age.years)
      end
    end
    context "when exact birth is unknown but life range is estimable" do
      subject { titty.father_birth_range }
      it { is_expected.to be_instance_of Range }
      it "returns (begin of life range - max male fertility procreation age)..(end of life range - min male fertility procreation age)" do
        is_expected.to eq (titty.life_range.begin-@model.max_male_procreation_age.years)..(titty.life_range.end-@model.min_male_procreation_age.years)
      end
    end
    context "when receiver's life range is not estimable" do
      subject { luis.father_birth_range }
      it { is_expected.to be nil }
    end
    context "when actual father's birth is known" do
      it "covers father's birth" do
        expect(irene.father_birth_range).to cover(tommy.birth)
      end
    end
  end

  describe "#mother_birth_range" do
    context "when birth is known" do
      subject { louise.mother_birth_range }
      it { is_expected.to be_instance_of Range }
      it "returns (birth - max female fertility procreation age)..(birth - min female fertility procreation age)" do
        is_expected.to eq (louise.birth-@model.max_female_procreation_age.years)..(louise.birth-@model.min_female_procreation_age.years)
      end
    end
    context "when exact birth is unknown but life range is estimable" do
      subject { titty.mother_birth_range }
      it { is_expected.to be_instance_of Range }
      it "returns (begin of life range - max female fertility procreation age)..(end of life range - min female fertility procreation age)" do
        is_expected.to eq (titty.life_range.begin-@model.max_female_procreation_age.years)..(titty.life_range.end-@model.min_female_procreation_age.years)
      end
    end
    context "when receiver's life range is not estimable" do
      subject { luis.mother_birth_range }
      it { is_expected.to be nil }
    end
    context "when actual mother's birth is known" do
      it "covers mother's birth" do
        expect(irene.mother_birth_range).to cover(emily.birth)
      end
    end
  end


  describe "#father_fertility_range" do
    context "when receiver's father_birth_range is estimable" do
      subject { louise.father_fertility_range }
      it { is_expected.to be_instance_of Range }
      it "returns (begin of father's birth range + male's min procreation age)..(end of father's birth range + male's max procreation age)" do
        is_expected.to eq (louise.father_birth_range.begin+@model.min_male_procreation_age.years)..(louise.father_birth_range.end+@model.max_male_procreation_age.years)
      end
    end
    context "when receiver's father_birth_range is not estimable" do
      subject { luis.father_fertility_range }
      it { is_expected.to be nil }
    end
    context "when actual father exists and his fertility range is estimable" do
      it "covers father's fertility range" do
        expect(irene.father_fertility_range).to include(tommy.fertility_range)
      end
    end
  end

  describe "#mother_fertility_range" do
    context "when receiver's mother_birth_range is estimable" do
      subject { louise.mother_fertility_range }
      it { is_expected.to be_instance_of Range }
      it "returns (begin of mother's birth range + female's min procreation age)..(end of mother's birth range + female's max procreation age)" do
        is_expected.to eq (louise.mother_birth_range.begin+@model.min_female_procreation_age.years)..(louise.mother_birth_range.end+@model.max_female_procreation_age.years)
      end
    end
    context "when receiver's mother_birth_range is not estimable" do
      subject { luis.mother_fertility_range }
      it { is_expected.to be nil }
    end
    context "when actual mother exists and his fertility range is estimable" do
      it "covers mother's fertility range" do
        expect(irene.mother_fertility_range).to include(emily.fertility_range)
      end
    end
  end

  describe "#ssex" do
    context 'when receiver is male' do
      subject { paul.ssex }
      it { is_expected.to be :male }
    end
    context 'when receiver is female' do
      subject { titty.ssex }
      it { is_expected.to be :female }
    end
    context 'when receiver has sex unknown' do
      before { paul.sex = nil }
      specify { expect { paul.ssex }.to raise_error Genealogy::SexError }
    end
  end

  describe "#opposite_ssex" do
    context 'when receiver is male' do
      subject { paul.opposite_ssex }
      it { is_expected.to be :female }
    end
    context 'when receiver is female' do
      subject { titty.opposite_ssex }
      it { is_expected.to be :male }
    end
    context 'when receiver has sex unknown' do
      before { paul.sex = nil }
      specify { expect { paul.opposite_ssex }.to raise_error Genealogy::SexError }
    end
  end

end
