require 'spec_helper'

describe "*** Ineligible methods without considering ages ***", :ineligible do

  context 'when can replace parent' do
    before { @model = get_test_model({:current_spouse => true, :check_ages => false, :replace_parent => true }) }  

    context "when unreleted people exist" do
      include_context "unreleted people exist"

      describe "paso" do
        subject {paso}
        its(:ineligible_fathers) {is_expected.to match_array @model.females | [paso]}
        its(:ineligible_mothers) {is_expected.to match_array @model.males}
        its(:ineligible_paternal_grandfathers) {is_expected.to match_array @model.females | [paso]}
        its(:ineligible_paternal_grandmothers) {is_expected.to match_array @model.males}
        its(:ineligible_maternal_grandfathers) {is_expected.to match_array @model.females | [paso]}
        its(:ineligible_maternal_grandmothers) {is_expected.to match_array @model.males}
        its(:ineligible_children) {is_expected.to match_array [paso]}
        its(:ineligible_siblings) {is_expected.to match_array [paso]}
        its(:ineligible_current_spouses) {is_expected.to match_array @model.males}
        context "with rud as child" do
          before { rud.update_attributes(father_id: paso.id) }
          its(:ineligible_fathers) {is_expected.to match_array @model.females | [paso,rud]}
          its(:ineligible_mothers) {is_expected.to match_array @model.males}
          its(:ineligible_paternal_grandfathers) {is_expected.to match_array @model.females | [paso, rud]}
          its(:ineligible_paternal_grandmothers) {is_expected.to match_array @model.males}
          its(:ineligible_maternal_grandfathers) {is_expected.to match_array @model.females | [paso, rud]}
          its(:ineligible_maternal_grandmothers) {is_expected.to match_array @model.males}
          its(:ineligible_children) {is_expected.to match_array [paso,rud]}
          its(:ineligible_siblings) {is_expected.to match_array [paso,rud]}
          its(:ineligible_current_spouses) {is_expected.to match_array @model.males}
          context "and with jack as father" do
            before { paso.update_attributes(father_id: jack.id) }
            its(:ineligible_fathers) {is_expected.to be nil}
            its(:ineligible_mothers) {is_expected.to match_array @model.males}
            its(:ineligible_paternal_grandfathers) {is_expected.to match_array @model.females | [paso,rud,jack]}
            its(:ineligible_paternal_grandmothers) {is_expected.to match_array @model.males}
            its(:ineligible_maternal_grandfathers) {is_expected.to match_array @model.females | [paso,rud]}
            its(:ineligible_maternal_grandmothers) {is_expected.to match_array @model.males}
            its(:ineligible_siblings) {is_expected.to match_array [paso,rud,jack]}
            its(:ineligible_children) {is_expected.to match_array [paso,rud,jack]}
            its(:ineligible_current_spouses) {is_expected.to match_array @model.males}
            context "and with alison as mother" do
              before { paso.update_attributes(mother_id: alison.id) }
              its(:ineligible_mothers) {is_expected.to be nil}
              its(:ineligible_paternal_grandfathers) {is_expected.to match_array @model.females | [paso,rud,jack]}
              its(:ineligible_paternal_grandmothers) {is_expected.to match_array @model.males }
              its(:ineligible_maternal_grandfathers) {is_expected.to match_array @model.females | [paso,rud]}
              its(:ineligible_maternal_grandmothers) {is_expected.to match_array @model.males | [alison]}
              its(:ineligible_siblings) {is_expected.to match_array [paso,rud,jack,alison]}
              its(:ineligible_children) {is_expected.to match_array [paso,rud,jack,alison]}
              its(:ineligible_current_spouses) {is_expected.to match_array @model.males}
            end
          end
          context "and with alison as mother" do
            before { paso.update_attributes(mother_id: alison.id) }
            its(:ineligible_fathers) {is_expected.to match_array @model.females | [paso,rud]}
            its(:ineligible_mothers) {is_expected.to be nil}
            its(:ineligible_paternal_grandfathers) {is_expected.to match_array @model.females | [paso,rud]}
            its(:ineligible_paternal_grandmothers) {is_expected.to match_array @model.males}
            its(:ineligible_maternal_grandfathers) {is_expected.to match_array @model.females | [paso,rud]}
            its(:ineligible_maternal_grandmothers) {is_expected.to match_array @model.males | [alison]}
            its(:ineligible_siblings) {is_expected.to match_array [paso,rud,alison]}
            its(:ineligible_children) {is_expected.to match_array [paso,rud,alison]}
            its(:ineligible_current_spouses) {is_expected.to match_array @model.males}
            context "and with jack as father" do
              before { paso.update_attributes(father_id: jack.id) }
              its(:ineligible_fathers) {is_expected.to be nil}
              its(:ineligible_paternal_grandfathers) {is_expected.to match_array @model.females | [paso,rud,jack]}
              its(:ineligible_paternal_grandmothers) {is_expected.to match_array @model.males }
              its(:ineligible_maternal_grandfathers) {is_expected.to match_array @model.females | [paso,rud]}
              its(:ineligible_maternal_grandmothers) {is_expected.to match_array @model.males | [alison]}
              its(:ineligible_siblings) {is_expected.to match_array [paso,rud,jack,alison]}
              its(:ineligible_children) {is_expected.to match_array [paso,rud,jack,alison]}
              its(:ineligible_current_spouses) {is_expected.to match_array @model.males}
            end
          end
        end

      end

      describe "rud, an unreleted individual" do
        subject {rud}
        its(:ineligible_fathers) {is_expected.to match_array @model.females | [rud]}
        its(:ineligible_mothers) {is_expected.to match_array @model.males}
        its(:ineligible_paternal_grandfathers) {is_expected.to match_array @model.females | [rud]}
        its(:ineligible_paternal_grandmothers) {is_expected.to match_array @model.males}
        its(:ineligible_maternal_grandfathers) {is_expected.to match_array @model.females | [rud]}
        its(:ineligible_maternal_grandmothers) {is_expected.to match_array @model.males}
        its(:ineligible_children) {is_expected.to match_array [rud]}
        its(:ineligible_siblings) {is_expected.to match_array [rud]}
        context "with irene as mother" do
          before { rud.update_attributes(mother_id: irene.id) }
          its(:ineligible_fathers) {is_expected.to match_array @model.females | [rud]}
          its(:ineligible_mothers) {is_expected.to be nil}
          its(:ineligible_paternal_grandfathers) {is_expected.to match_array @model.females | [rud]}
          its(:ineligible_paternal_grandmothers) {is_expected.to match_array @model.males}
          its(:ineligible_maternal_grandfathers) {is_expected.to match_array @model.females | [rud]}
          its(:ineligible_maternal_grandmothers) {is_expected.to match_array @model.males | [irene]}
          its(:ineligible_siblings) {is_expected.to match_array [rud,irene]}
          its(:ineligible_children) {is_expected.to match_array [rud,irene]}
          context "and with mark and titty as maternal half siblings" do
            before { 
              mark.update_attributes(mother_id: irene.id)
              titty.update_attributes(mother_id: irene.id) 
            }
            its(:ineligible_fathers) {is_expected.to match_array @model.females | [rud]}
            its(:ineligible_paternal_grandfathers) {is_expected.to match_array @model.females | [rud, mark]}
            its(:ineligible_paternal_grandmothers) {is_expected.to match_array @model.males | [titty]} 
            its(:ineligible_maternal_grandfathers) {is_expected.to match_array @model.females | [rud, mark]}
            its(:ineligible_maternal_grandmothers) {is_expected.to match_array @model.males | [irene,titty]} 
            its(:ineligible_siblings) {is_expected.to match_array [rud,irene]}
            its(:ineligible_children) {is_expected.to match_array [rud,irene]}
            context "and with peter and steve as nephews" do
              before { 
                peter.update_attributes(mother_id: titty.id)
                steve.update_attributes(mother_id: titty.id) 
              }
              its(:ineligible_fathers) {is_expected.to match_array @model.females | [rud]}
              its(:ineligible_paternal_grandfathers) {is_expected.to match_array @model.females | [rud,mark]}
              its(:ineligible_paternal_grandmothers) {is_expected.to match_array @model.males | [titty]}
              its(:ineligible_maternal_grandfathers) {is_expected.to match_array @model.females | [rud,mark]}
              its(:ineligible_maternal_grandmothers) {is_expected.to match_array @model.males | [irene,titty]}
              its(:ineligible_siblings) {is_expected.to match_array [rud,irene,peter,steve]}
              its(:ineligible_children) {is_expected.to match_array [rud,irene]}
            end
          end
        end
      end

    end


    context "when releted people exist", :wip do
      include_context "releted people exist"

      describe "manuel" do
        subject { manuel }
        its(:ineligible_fathers) { is_expected.to match_array @model.females | [manuel,paul,julian,ruben,peter,steve] }
        its(:ineligible_mothers) { is_expected.to match_array @model.males | [beatrix,mary] }
        its(:ineligible_paternal_grandfathers) { is_expected.to match_array @model.females | [manuel,paul,julian,ruben,peter,steve] }
        its(:ineligible_children) { is_expected.to match_array [manuel,paul] | @model.all_with(:father) }
        its(:ineligible_siblings) { is_expected.to match_array [manuel,paul,julian,beatrix,ruben,peter,steve,mary] }
        context "when julian and beatrix has no father" do
          before do
            julian.update_attributes(father_id: nil)
            beatrix.update_attributes(father_id: nil)
          end
          its(:ineligible_children) { is_expected.to match_array [manuel,paul] | @model.all_with(:father) }
          its(:ineligible_siblings) { is_expected.to match_array [manuel,paul,ruben,peter,steve,mary] }       
          context "when manuel has emily as mother" do
            before do
              manuel.update_attributes(mother_id: emily.id)
            end
            its(:ineligible_siblings) { is_expected.to match_array [manuel,paul,ruben,peter,steve,mary,emily,luis,rosa] | @model.all_with(:mother) - [irene] }       
            its(:half_siblings) {is_expected.to match_array [irene]}       
          end

        end
      end

      describe "terry" do
        subject { terry }
        its(:ineligible_children) { is_expected.to match_array [terry,marcel] | @model.all_with(:mother) }
        its(:ineligible_siblings) { is_expected.to match_array [marcel,terry,paul,julian,beatrix,ruben,peter,steve,mary] | @model.all_with(:father)}
      end

      describe "mark" do
        subject { mark }
        its(:ineligible_children) { is_expected.to match_array [luis,rosa,larry,louise,bob,alison] | @model.all_with(:father) }
        its(:ineligible_siblings) { is_expected.to match_array [luis,rosa,larry,louise,bob,alison,ruben,terry] | @model.all_with(:parents)}
      end

      describe "paul"  do
        subject { paul }
        its(:ineligible_paternal_grandfathers) { is_expected.to match_array @model.females | [manuel,paul,julian,ruben,peter,steve] }
        its(:ineligible_children) { is_expected.to match_array [manuel,paul,terry,marcel] | @model.all_with(:father) }
      end

      describe "peter"  do
        subject { peter }
        its(:ineligible_siblings) { is_expected.to match_array [marcel,luis,rosa,larry,louise,bob,alison,manuel,terry] | @model.all_with(:parents)}
      end

      describe "beatrix"  do
        subject { beatrix }
        its(:ineligible_children) { is_expected.to match_array [ned,naomi,michelle,paul,manuel,terry,marcel] | @model.all_with(:mother)}
      end

      describe "debby" do
        subject { debby }
        its(:ineligible_children) { is_expected.to match_array [louise,bob] | @model.all_with(:mother) }
        its(:ineligible_siblings) { is_expected.to match_array [louise,bob,terry,ruben] | @model.all_with(:parents) }
      end

      context 'when titty has no mother' do
        before { titty.update_attributes(mother_id: nil) }
        describe "titty" do
          subject { titty }

          its(:ineligible_mothers) {  }

        end

        describe "ruben" do
          subject { ruben }
          its(:ineligible_mothers) { is_expected.to match_array @model.males}
          its(:ineligible_maternal_grandfathers) { is_expected.to match_array @model.females | [ruben,peter,steve,julian]}
          its(:ineligible_children) { is_expected.to match_array [ruben,manuel,paul,terry,marcel] | @model.all_with(:father) }
        end
      end

    end

  end

  context 'when cannot replace parent (default)' do
    before { @model = get_test_model({:current_spouse => true, :check_ages => false }) }  
    context "when releted people exist" do
      include_context "releted people exist"

      describe "manuel" do
        subject { manuel }
        its(:ineligible_fathers) { is_expected.to match_array @model.females | [manuel,paul,julian,ruben,peter,steve,charlie, jack, john, mark, paso, rud, sam, tommy] }
      end

      describe "mia" do
        subject { mia }
        its(:ineligible_fathers) { is_expected.to match_array @model.females | [sam, charlie] }
      end

      describe "sue" do
        subject { sue }
        its(:ineligible_maternal_grandfathers) { is_expected.to match_array @model.females | [sam, charlie ] }
      end


    end

  end
end
