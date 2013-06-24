require 'spec_helper'

module AlterCurrentSpouseSpec
  extend GenealogyTestModel
  
  describe "*** Alter current_spouse methods ***" do

    before(:all) do
      AlterCurrentSpouseSpec.define_test_model_class({:current_spouse => true})
    end

    let(:paul) {TestModel.create!(:name => "paul", :sex => "M")}
    let(:titty) {TestModel.create!(:name => "titty", :sex => "F")}
    let(:john) {TestModel.create!(:name => "john", :sex => "M")}

    describe "paul" do
      subject {paul.reload}
      
      describe "#add_current_spouse(titty)" do

        context "when all is ok" do
          before(:each) {paul.add_current_spouse(titty)}
          its(:current_spouse) { should == titty }
          describe "titty" do
            subject {titty.reload}
            its(:current_spouse) { should == paul }
          end
        end

        context "paul is invalid" do
          before(:each) do
            paul.mark_invalid!
            paul.add_current_spouse(titty) rescue true
          end
          specify { expect { paul.add_current_spouse(titty) }.to raise_error }
          its(:current_spouse) { should be_nil }
          describe "titty" do
            subject {titty.reload}
            its(:current_spouse) { should be_nil }
          end
        end

      end

      describe "#paul.add_current_spouse(john)" do
        specify { expect { paul.add_current_spouse(john) }.to raise_error(Genealogy::WrongSexException) }
      end

      context "when has titty as current_spouse" do

        before(:each) {paul.add_current_spouse(titty)}

        describe "#remove_current_spouse" do
          
          context "when all is ok" do
            before(:each) {paul.remove_current_spouse}
            its(:current_spouse) { should be_nil }
            describe "titty" do
              subject {titty.reload}
              its(:current_spouse) { should be_nil }
            end
          end

          context "when paul is invalid" do
            before(:each) do
              paul.mark_invalid!
              paul.remove_current_spouse rescue true
            end
            its(:current_spouse) { should == titty }
            describe "titty" do
              subject {titty.reload}
              its(:current_spouse) { should == paul }
            end
          end

        end
      end

    end

  end

end