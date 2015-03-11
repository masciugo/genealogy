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
    context 'when birth and death are known' do
      subject { louise.life_range }
      it { is_expected.to be_instance_of Range }
      it "returns the life range" do
        is_expected.to eq Date.new(1874,4,10)..Date.new(1930,8,7)
      end
    end
    context 'when only birth is known' do
      subject { paul.life_range }
      it { is_expected.to be_instance_of Range }
      it "returns the life range" do
        is_expected.to eq Date.new(1970,3,3)..Date.new(1970+110,3,3)
      end
    end
    context 'when only death is known' do
      subject { titty.life_range }
      it { is_expected.to be_instance_of Range }
      it "returns the life range" do
        is_expected.to eq Date.new(2010-110,8,6)..Date.new(2010,8,6)
      end
    end
    context 'when are both unknown' do
      subject { luis.life_range }
      it { is_expected.to be nil }
    end
  end

  describe "#fertility_range" do
    context 'when birth and death are known' do
      subject { louise.fertility_range }
      it { is_expected.to be_instance_of Range }
      it "returns the fertility range" do
        is_expected.to eq Date.new(1874+9,4,10)..Date.new(1874+50,4,10)
      end
    end
    context 'when only birth is known' do
      subject { paul.fertility_range }
      it { is_expected.to be_instance_of Range }
      it "returns the fertility range" do
        is_expected.to eq Date.new(1970+12,3,3)..Date.new(1970+75,3,3)
      end
    end
    context 'when only death is known' do
      subject { titty.fertility_range }
      it { is_expected.to be_instance_of Range }
      it "returns the fertility range" do
        is_expected.to eq Date.new(2010-110+9,8,6)..Date.new(2010,8,6)
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
    context "when receiver's life range is estimable" do
      subject { louise.father_birth_range }
      it { is_expected.to be_instance_of Range }
      it { is_expected.to eq Date.new(1874-75,4,10)..Date.new(1874-12,4,10) }
    end
    context "when receiver's life range is not estimable" do
      subject { luis.father_birth_range }
      it { is_expected.to be nil }
    end
  end

  describe "#mother_birth_range" do
    context "when receiver's life range is estimable" do
      subject { louise.mother_birth_range }
      it { is_expected.to be_instance_of Range }
      it { is_expected.to eq Date.new(1874-50,4,10)..Date.new(1874-9,4,10) }
    end
    context "when receiver's life range is not estimable" do
      subject { luis.mother_birth_range }
      it { is_expected.to be nil }
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
