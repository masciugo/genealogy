require 'spec_helper'

describe "*** Ineligible methods ***", :ineligible do
  before { @model = get_test_model({:current_spouse => true, :check_ages => false}) }
  context "when unreleted people exist" do
    include_context "unreleted people exist"

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
      # its(:ineligible_current_spouses) {}
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
        # its(:ineligible_current_spouses) {}
        context "and with tommy as father" do
          before { walter.update_attributes(father_id: tommy.id) }
          its(:ineligible_fathers) {is_expected.to be nil}
          its(:ineligible_mothers) {is_expected.to match_array @model.males}
          its(:ineligible_paternal_grandfathers) {is_expected.to match_array @model.females + [walter,nick,tommy]}
          its(:ineligible_paternal_grandmothers) {is_expected.to match_array @model.males}
          its(:ineligible_maternal_grandfathers) {is_expected.to match_array @model.females + [walter,nick]}
          its(:ineligible_maternal_grandmothers) {is_expected.to match_array @model.males}
          its(:ineligible_siblings) {is_expected.to match_array [walter,nick,tommy]}
          its(:ineligible_children) {is_expected.to match_array [walter,nick,tommy]}
          # its(:ineligible_current_spouses) {}
          context "and with emily as mother" do
            before { walter.update_attributes(mother_id: emily.id) }
            its(:ineligible_mothers) {is_expected.to be nil}
            its(:ineligible_paternal_grandfathers) {is_expected.to match_array @model.females + [walter,nick,tommy]}
            its(:ineligible_paternal_grandmothers) {is_expected.to match_array @model.males }
            its(:ineligible_maternal_grandfathers) {is_expected.to match_array @model.females + [walter,nick]}
            its(:ineligible_maternal_grandmothers) {is_expected.to match_array @model.males + [emily]}
            its(:ineligible_siblings) {is_expected.to match_array [walter,nick,tommy,emily]}
            its(:ineligible_children) {is_expected.to match_array [walter,nick,tommy,emily]}
            # its(:ineligible_current_spouses) {}
          end
        end
        context "and with emily as mother" do
          before { walter.update_attributes(mother_id: emily.id) }
          its(:ineligible_fathers) {is_expected.to match_array @model.females + [walter,nick]}
          its(:ineligible_mothers) {is_expected.to be nil}
          its(:ineligible_paternal_grandfathers) {is_expected.to match_array @model.females + [walter,nick]}
          its(:ineligible_paternal_grandmothers) {is_expected.to match_array @model.males}
          its(:ineligible_maternal_grandfathers) {is_expected.to match_array @model.females + [walter,nick]}
          its(:ineligible_maternal_grandmothers) {is_expected.to match_array @model.males + [emily]}
          its(:ineligible_siblings) {is_expected.to match_array [walter,nick,emily]}
          its(:ineligible_children) {is_expected.to match_array [walter,nick,emily]}
          # its(:ineligible_current_spouses) {}
          context "and with tommy as father" do
            before { walter.update_attributes(father_id: tommy.id) }
            its(:ineligible_fathers) {is_expected.to be nil}
            its(:ineligible_paternal_grandfathers) {is_expected.to match_array @model.females + [walter,nick,tommy]}
            its(:ineligible_paternal_grandmothers) {is_expected.to match_array @model.males }
            its(:ineligible_maternal_grandfathers) {is_expected.to match_array @model.females + [walter,nick]}
            its(:ineligible_maternal_grandmothers) {is_expected.to match_array @model.males + [emily]}
            its(:ineligible_siblings) {is_expected.to match_array [walter,nick,tommy,emily]}
            its(:ineligible_children) {is_expected.to match_array [walter,nick,tommy,emily]}
            # its(:ineligible_current_spouses) {}
          end
        end
      end

    end
  end


  context "when releted people exist", :wip do
    include_context "releted people exist"

    describe "walter, child of alison" do
      subject {walter}
      before { walter.update_attributes(father_id: jack.id, mother_id: alison.id) }
      # inelegible fathers sono tutte le femmine, se stesso (walter), i siblings maschi di walter, tutti gli antenati maschi dei siblings di walter, tutto i discendenti maschi dei siblings di walter
      # its(:ineligible_fathers) { is_expected.to match_array @model.females + [walter, jack, bob, paso, john, rud, mark, sam, steve, peter] }
      # its(:ineligible_sons) { is_expected.to match_array @model.females + [walter, paso, john, jack, bob] }
    end

  end
end
