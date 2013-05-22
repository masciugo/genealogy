require 'spec_helper'

module AlterSpouseSpec
  extend GenealogyTestModel
  
  describe "*** Alter spouse methods ***" do

    before(:all) do
      AlterSpouseSpec.define_test_model_class({:spouse => true})
    end

    let(:paul) {TestModel.create!(:name => "paul", :sex => "M")}
    let(:titty) {TestModel.create!(:name => "titty", :sex => "F")}
    let(:john) {TestModel.create!(:name => "john", :sex => "M")}

    describe "paul" do
      subject {paul.reload}
      
      describe "#add_spouse(titty)" do

        context "when all is ok" do
          before(:each) {paul.add_spouse(titty)}
          its(:spouse) { should == titty }
          describe "titty" do
            subject {titty.reload}
            its(:spouse) { should == paul }
          end
        end

        context "paul is invalid" do
          before(:each) do
            paul.mark_invalid!
            paul.add_spouse(titty) rescue true
          end
          specify { expect { paul.add_spouse(titty) }.to raise_error }
          its(:spouse) { should be_nil }
          describe "titty" do
            subject {titty.reload}
            its(:spouse) { should be_nil }
          end
        end

      end

      describe "#paul.add_spouse(john)" do
        specify { expect { paul.add_spouse(john) }.to raise_error(Genealogy::WrongSexException) }
      end

      context "when has titty as spouse" do

        before(:each) {paul.add_spouse(titty)}

        describe "#remove_spouse" do
          
          context "when all is ok" do
            before(:each) {paul.remove_spouse}
            its(:spouse) { should be_nil }
            describe "titty" do
              subject {titty.reload}
              its(:spouse) { should be_nil }
            end
          end

          context "when paul is invalid" do
            before(:each) do
              paul.mark_invalid!
              paul.remove_spouse rescue true
            end
            its(:spouse) { should == titty }
            describe "titty" do
              subject {titty.reload}
              its(:spouse) { should == paul }
            end
          end

        end
      end

    end

  end

end