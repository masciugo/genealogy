require 'spec_helper'

describe "*** Ineligible methods ***", :wip, :ineligible do

  before { @model = get_test_model({:current_spouse => true}) }
  include_context "unreleted people exist"

  # describe "#birth and #death" do
  #   context "when both are defined (birth 12-05-1925 and death 10-03-1994)" do
  #     subject {louise}
  #     its(:birth) {is_expected.to eq Date.new(1925,05,12)}
  #     its(:death) {is_expected.to eq Date.new(1994,03,10)}
  #   end
  #   context "when only date of birth is defined (12-05-1925)" do
  #     subject {paul}
  #     its(:birth) {is_expected.to eq Date.new(1925,05,12)}
  #     its(:death) {is_expected.to be nil}
  #   end
  #   context "when only date of death is defined (10-03-1994)" do
  #     subject {titty}
  #     its(:birth) {is_expected.to be nil}
  #     its(:death) {is_expected.to eq Date.new(1994,03,10)}
  #   end
  # end

  describe "walter, a new unreleted individual" do
    subject {walter}
    its(:ineligible_fathers) {is_expected.to match_array @model.females + [walter]}
    its(:ineligible_mothers) {is_expected.to match_array @model.males}
    its(:ineligible_paternal_grandfathers) {is_expected.to match_array @model.females + [walter]}
    its(:ineligible_paternal_grandmothers) {is_expected.to match_array @model.males}
    its(:ineligible_maternal_grandfathers) {is_expected.to match_array @model.females + [walter]}
    its(:ineligible_maternal_grandmothers) {is_expected.to match_array @model.males}
    its(:ineligible_children) {is_expected.to match_array [walter]}
    its(:ineligible_siblings) {is_expected.to match_array [walter]}
    context "with nick as child" do
      before { nick.update_attributes(father_id: walter.id) }
      its(:ineligible_fathers) {is_expected.to match_array @model.females + [walter,nick]}
      its(:ineligible_mothers) {is_expected.to match_array @model.males}
      its(:ineligible_paternal_grandfathers) {is_expected.to match_array @model.females + [walter, nick]}
      its(:ineligible_paternal_grandmothers) {is_expected.to match_array @model.males}
      its(:ineligible_maternal_grandfathers) {is_expected.to match_array @model.females + [walter, nick]}
      its(:ineligible_maternal_grandmothers) {is_expected.to match_array @model.males}
      its(:ineligible_children) {is_expected.to match_array [walter,nick]}
      its(:ineligible_siblings) {is_expected.to match_array [walter,nick]}
      context "and with tommy as father" do
        before { walter.update_attributes(father_id: tommy.id) }
        its(:ineligible_fathers) {is_expected.to match_array @model.all}
        its(:ineligible_mothers) {is_expected.to match_array @model.males}
        its(:ineligible_paternal_grandfathers) {is_expected.to match_array @model.females + [walter,nick,tommy]}
        its(:ineligible_paternal_grandmothers) {is_expected.to match_array @model.males}
        its(:ineligible_maternal_grandfathers) {is_expected.to match_array @model.females + [walter,nick]}
        its(:ineligible_maternal_grandmothers) {is_expected.to match_array @model.males}
        its(:ineligible_siblings) {is_expected.to match_array [walter,nick,tommy]}
        its(:ineligible_children) {is_expected.to match_array [walter,nick,tommy]}
        context "and with emily as mother" do
          before { walter.update_attributes(mother_id: emily.id) }
          its(:ineligible_mothers) {is_expected.to match_array @model.all}
          its(:ineligible_paternal_grandfathers) {is_expected.to match_array @model.females + [walter,nick,tommy]}
          its(:ineligible_paternal_grandmothers) {is_expected.to match_array @model.males }
          its(:ineligible_maternal_grandfathers) {is_expected.to match_array @model.females + [walter,nick]}
          its(:ineligible_maternal_grandmothers) {is_expected.to match_array @model.males + [emily]}
          its(:ineligible_siblings) {is_expected.to match_array [walter,nick,tommy,emily]}
          its(:ineligible_children) {is_expected.to match_array [walter,nick,tommy,emily]}
        end
      end
      context "and with emily as mother" do
        before { walter.update_attributes(mother_id: emily.id) }
        its(:ineligible_fathers) {is_expected.to match_array @model.females + [walter,nick]}
        its(:ineligible_mothers) {is_expected.to match_array @model.all}
        its(:ineligible_paternal_grandfathers) {is_expected.to match_array @model.females + [walter,nick]}
        its(:ineligible_paternal_grandmothers) {is_expected.to match_array @model.males}
        its(:ineligible_maternal_grandfathers) {is_expected.to match_array @model.females + [walter,nick]}
        its(:ineligible_maternal_grandmothers) {is_expected.to match_array @model.males + [emily]}
        its(:ineligible_siblings) {is_expected.to match_array [walter,nick,emily]}
        its(:ineligible_children) {is_expected.to match_array [walter,nick,emily]}
        context "and with tommy as father" do
          before { walter.update_attributes(father_id: tommy.id) }
          its(:ineligible_fathers) {is_expected.to match_array @model.all}
          its(:ineligible_paternal_grandfathers) {is_expected.to match_array @model.females + [walter,nick,tommy]}
          its(:ineligible_paternal_grandmothers) {is_expected.to match_array @model.males }
          its(:ineligible_maternal_grandfathers) {is_expected.to match_array @model.females + [walter,nick]}
          its(:ineligible_maternal_grandmothers) {is_expected.to match_array @model.males + [emily]}
          its(:ineligible_siblings) {is_expected.to match_array [walter,nick,tommy,emily]}
          its(:ineligible_children) {is_expected.to match_array [walter,nick,tommy,emily]}
        end
      end
    end

  end
end
