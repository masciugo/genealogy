require 'spec_helper'

module AlterCurrentSpouseNoValidationSpec
  extend GenealogyTestModel

  describe "*** Alter current_spouse methods defining model with option :perform_validation => false  ***" do

    before(:all) do
      AlterCurrentSpouseNoValidationSpec.define_test_model_class({:current_spouse => true, :perform_validation => false})
    end

    let(:paul) {TestModel.create!(:name => "paul", :sex => "M")}
    let(:titty) {TestModel.create!(:name => "titty", :sex => "F")}
    let(:john) {TestModel.create!(:name => "john", :sex => "M")}

    describe "paul" do
      subject {paul.reload}

      describe "#add_current_spouse(titty)" do

        context "paul is invalid" do
          before(:each) do
            paul.mark_invalid!
            paul.add_current_spouse(titty)
          end
          specify { expect { paul.add_current_spouse(titty) }.to_not raise_error }
          its(:current_spouse) { should == titty }
          describe "titty" do
            subject {titty.reload}
            its(:current_spouse) { should == paul }
          end
        end

      end

      describe "#paul.add_current_spouse(john)" do
        specify { expect { paul.add_current_spouse(john) }.to raise_error(Genealogy::WrongSexException) }
      end

      context "when has titty as current_spouse" do

        before(:each) {paul.add_current_spouse(titty)}

        describe "#remove_current_spouse" do

          context "when paul is invalid" do
            before(:each) do
              paul.mark_invalid!
              paul.remove_current_spouse
            end
            its(:current_spouse) { should be_nil }
            describe "titty" do
              subject {titty.reload}
              its(:current_spouse) { should be_nil }
            end
          end

        end
      end

    end

  end

end