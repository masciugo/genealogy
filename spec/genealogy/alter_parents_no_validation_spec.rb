require 'spec_helper'

module AlterParentsNoValidationSpec
  extend GenealogyTestModel

  describe "*** Alter parents methods defining model with options {:perform_validation => false } ***" do

    before(:all) do
      AlterParentsNoValidationSpec.define_test_model_class({:perform_validation => false })
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
          specify { expect { peter.add_parents(paul,titty) }.to_not raise_error }
          its(:parents) do
            peter.add_parents(paul,titty)
            peter.reload
            should match_array [paul,titty]
          end
        end


      end

      context "when has paul as father and peter is invalid" do

        before(:each) do
          peter.add_father(paul)
          peter.mark_invalid!
        end

        describe "#remove_father" do

          it "has no father" do
            peter.remove_father
            peter.reload.father.should be_nil
          end

        end


      end

    end



  end


end