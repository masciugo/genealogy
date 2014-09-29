require 'spec_helper'

module AlterParentsSpec
  extend GenealogyTestModel

  describe "*** Alter parents methods ***" do

    before(:all) do
      AlterParentsSpec.define_test_model_class({})
    end

    let(:peter) {TestModel.create!(:name => "peter", :sex => "M")}
    let(:paul) {TestModel.create!(:name => "paul", :sex => "M")}
    let(:titty) {TestModel.create!(:name => "titty", :sex => "F")}

    describe "peter" do
      subject{ peter }

      describe "#add_father(Object.new)" do
        specify { expect { peter.add_father(Object.new) }.to raise_error(Genealogy::IncompatibleObjectException) }
      end

      describe "#add_father(peter)" do
        specify { expect { peter.add_father(Object.new) }.to raise_error(Genealogy::IncompatibleObjectException) }
      end

      describe "#add_father(titty)" do
        specify { expect { peter.add_father(titty) }.to raise_error(Genealogy::WrongSexException) }
      end

      describe "#add_parents(paul,titty)" do

        its(:parents) do
          peter.add_parents(paul,titty)
          peter.reload
          should match_array [paul,titty]
        end

        context "when peter is invalid" do
          before(:each) do
            peter.mark_invalid!
          end
          specify { expect { peter.add_parents(paul,titty) }.to raise_error }
          its(:parents) do
            peter.add_parents(paul,titty) rescue true
            peter.reload
            should match_array [nil,nil]
          end
        end

      end

      context "when has paul as father" do

        before(:each) do
          peter.add_father(paul)
        end

        describe "#remove_father" do

          it "has no father" do
            peter.remove_father
            peter.reload.father.should be_nil
          end

        end

        context "and has titty as mother" do

          before(:each) do
            peter.add_mother(titty)
          end

          describe "#remove_parents" do
            its(:parents) do
              peter.remove_parents
              should match_array [nil,nil]
            end
          end

        end

        context "and #add_father(nil)" do

          its(:father) do
            peter.add_father(nil)
            should be_nil
          end

        end

        context "and #add_parents(nil,nil)" do

          its(:parents) do
            peter.add_parents(nil,nil)
            should match_array [nil,nil]
          end

        end

      end

    end

  end

end