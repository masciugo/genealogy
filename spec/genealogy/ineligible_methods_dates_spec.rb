require 'spec_helper'

# default ages in use:
#   min_male_procreation_age: 12,
#   max_male_procreation_age: 75,
#   min_female_procreation_age: 9,
#   max_female_procreation_age: 50,
#   max_male_life_expectancy: 110,
#   max_female_life_expectancy: 110


describe "*** Ineligible methods ***", :ineligible_dates do
  before { @model = get_test_model({:current_spouse => true }) }
  include_context "unreleted people exist with dates"

  describe "louise" do
    subject {louise}
    its(:birth) {is_expected.to eq Date.new(1874,4,10)}
    its(:death) {is_expected.to eq Date.new(1930,8,7)}
    its(:life_range) { is_expected.to eq Date.new(1874,4,10)..Date.new(1930,8,7) }
    its(:fertility_range) { is_expected.to eq Date.new(1874+9,4,10)..Date.new(1874+50,4,10) }
    its(:father_birth_range) { is_expected.to eq Date.new(1874-75,4,10)..Date.new(1874-12,4,10) }
    its(:mother_birth_range) { is_expected.to eq Date.new(1874-50,4,10)..Date.new(1874-9,4,10) }
  end
  describe "barbara" do
    subject {barbara}
    its(:birth) {is_expected.to eq Date.new(1974,12,10)}
    its(:death) {is_expected.to be nil}
    its(:life_range) { is_expected.to eq Date.new(1974,12,10)..Date.new(1974+110,12,10) }
    its(:fertility_range) { is_expected.to eq Date.new(1974+9,12,10)..Date.new(1974+50,12,10) }
    its(:father_birth_range) { is_expected.to eq Date.new(1974-75,12,10)..Date.new(1974-12,12,10) }
    its(:mother_birth_range) { is_expected.to eq Date.new(1974-50,12,10)..Date.new(1974-9,12,10) }
  end
  describe "luis" do
    subject {luis}
    its(:birth) {is_expected.to be nil}
    its(:death) {is_expected.to be nil}
    its(:life_range) { is_expected.to be nil }
    its(:fertility_range) { is_expected.to be nil }
    its(:father_birth_range) { is_expected.to be nil }
    its(:mother_birth_range) { is_expected.to be nil }
  end
  describe "paul", :cin do
    subject {paul}
    its(:birth) {is_expected.to eq Date.new(1970,3,3)}
    its(:death) {is_expected.to be nil}
    its(:ineligible_mothers) {is_expected.to match_array @model.males + [michelle,mia,barbara,beatrix,mary,sue,emily,debby,louise,rosa] }

  end
  describe "titty", :cin do
    subject {titty}
    its(:birth) {is_expected.to be nil}
    its(:death) {is_expected.to eq Date.new(2010,8,6)}
    its(:ineligible_fathers) {is_expected.to match_array @model.females + [larry,julian,peter,steve,sam,charlie]}
    its(:ineligible_mothers) {is_expected.to match_array @model.males + [titty,beatrix,mary] }
    its(:ineligible_maternal_grandfathers) {is_expected.to match_array @model.females + [julian,ruben,peter,steve,sam,charlie]}
  end

  describe "paso" do
    subject { paso }
    its(:ineligible_fathers) {is_expected.to match_array @model.females + [manuel,paso,john,paul,rud,mark,ruben,julian,peter,steve,sam,charlie,larry] }
    its(:ineligible_mothers) {is_expected.to match_array @model.males + [terry,naomi,maggie,barbara,michelle,mia,sue,beatrix,mary,rosa,louise,irene,emily] }
  end

  describe "mia", :cin do
    subject { mia }
    its(:ineligible_children) {is_expected.to match_array [mia,barbara,mark,rud,paul,michelle,maggie,john,paso,irene,manuel,terry,naomi,ned,alison,jack,debby,tommy,emily,marcel,bob,louise,larry,rosa,luis] }
    its(:ineligible_mothers) {is_expected.to match_array @model.males + [mia,michelle,beatrix,mary,sue,maggie,irene,emily,debby,alison,rosa,louise] }
    
  end

end
