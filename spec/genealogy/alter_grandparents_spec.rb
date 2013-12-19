require 'spec_helper'

module AlterGrandparentsSpec
  extend GenealogyTestModel

  describe "*** Alter grandparents methods ***" do

    before(:all) do
      AlterGrandparentsSpec.define_test_model_class({})
    end

    let(:paul) {TestModel.create!(:name => "paul", :sex => "M", )}
    let(:manuel) {TestModel.create!(:name => "manuel", :sex => "M", )}
    let(:terry) {TestModel.create!(:name => "terry", :sex => "F", )}
    let(:titty) {TestModel.create!(:name => "titty", :sex => "F", )}
    let(:paso) {TestModel.create!(:name => "paso", :sex => "M", )}
    let(:irene) {TestModel.create!(:name => "irene", :sex => "F", )}
    let(:steve) {TestModel.create!(:name => "steve", :sex => "M", )}
    let(:peter) {TestModel.create!(:name => "peter", :sex => "M")}

    describe "peter" do
      subject{ peter.reload }

      context "when has no father" do

        describe "#add_paternal_grandfather(manuel)" do
          specify { expect { peter.add_paternal_grandfather(manuel) }.to raise_error(Genealogy::LineageGapException)}
        end
      end

      context "when has paul and titty as parents and steve as sibling" do
        
        before(:each) do
          peter.add_father(paul)
          peter.add_mother(titty)
          peter.add_siblings(steve)
        end
        
        describe "##add_paternal_grandfather(manuel)" do

          before(:each) { peter.add_paternal_grandfather(manuel) }
          its('paternal_grandfather') {should == manuel}
          
          describe "steve" do
            subject {steve}
            its('paternal_grandfather') {should == manuel}
          end
          
        end

        describe "#add_paternal_grandfather(terry)" do
          specify { expect { peter.add_paternal_grandfather(terry)}.to raise_error(Genealogy::WrongSexException) }
        end

        describe "#add_paternal_grandfather(Object.new)" do
          specify { expect { peter.add_paternal_grandfather(Object.new) }.to raise_error(Genealogy::IncompatibleObjectException) }
        end

        describe "#add_paternal_grandfather(peter)" do
          specify { expect { peter.add_paternal_grandfather(peter) }.to raise_error(Genealogy::IncompatibleRelationshipException) }
        end

        describe "#add_paternal_grandmother(terry)" do

          before(:each) { peter.add_paternal_grandmother(terry) }
          its('paternal_grandmother') {should == terry}

        end

        describe "#add_paternal_grandmother(manuel)" do
          specify { expect { peter.add_paternal_grandmother(manuel) }.to raise_error(Genealogy::WrongSexException) }
        end

        describe "#add_grandparents(manuel,terry,paso,irene)" do
          
          its(:grandparents) do
            peter.add_grandparents(manuel,terry,paso,irene)
            should match_array [manuel,terry,paso,irene]
          end
        
        end

        describe "#add_grandparents(manuel,nil,paso,nil)" do
          
          its(:grandparents) do
            peter.add_grandparents(manuel,nil,paso,nil)
            should match_array [manuel,nil,paso,nil]
          end

        end

        describe "#add_paternal_grandparents(manuel,terry)" do
          
          its(:grandparents) do
            peter.add_paternal_grandparents(manuel,terry)
            should match_array [manuel,terry,nil,nil]
          end

        end

        describe "#add_maternal_grandparents(manuel,terry)" do
          
          its(:grandparents) do
            peter.add_maternal_grandparents(manuel,terry)
            should match_array [nil,nil,manuel,terry]
          end

        end


        describe "when has manuel and terry as paternal grandparents and paso and irene as maternal grandparents" do
          before(:each) do
            peter.add_grandparents(manuel,terry,paso,irene)
          end

          describe "#remove_parental_grandfather" do
            before(:each) do
              peter.remove_paternal_grandfather
            end
            its('paternal_grandmother') {should == terry}
            its('paternal_grandfather') {should be_nil}

            describe "steve" do
              subject {steve}
              its('paternal_grandmother') {should == terry}
              its('paternal_grandfather') {should be_nil}
            end
          end

          describe "#remove_grandparents" do
            its(:grandparents) do
              peter.remove_grandparents
              should match_array [nil,nil,nil,nil]
            end
          end



        end
      end

    end

  end

end

