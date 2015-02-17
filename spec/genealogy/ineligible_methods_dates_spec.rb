require 'spec_helper'

describe "*** Ineligible methods ***", :ineligible_dates do
  before { @model = get_test_model({:current_spouse => true }) }
  include_context "unreleted people exist with dates"

  describe "louise" do
    subject {louise}
    its(:birth) {is_expected.to eq Date.new(1874,4,10)}
    # its(:death) {is_expected.to eq Date.new(1994,03,10)}
  end
  describe "paul" do
    subject {paul}
    its(:birth) {is_expected.to eq Date.new(1970,3,3)}
    # its(:death) {is_expected.to be nil}
  end
  describe "titty" do
    subject {titty}
    its(:birth) {is_expected.to be nil}
    its(:death) {is_expected.to eq Date.new(2010,8,6)}
    its(:ineligible_fathers) {is_expected.to match_array @model.females }
    its(:ineligible_mothers) {is_expected.to match_array @model.males + [titty] }
  end

  describe "paso" do
    subject { paso }
    its(:ineligible_fathers) {is_expected.to match_array @model.females + [manuel,paso,john,paul,rud,mark,ruben,julian,peter,steve,sam,charlie,larry] }
    its(:ineligible_mothers) {is_expected.to match_array @model.males + [terry,naomi,maggie,barbara,michelle,mia,sue,beatrix,mary,rosa,louise] }
  end
end
