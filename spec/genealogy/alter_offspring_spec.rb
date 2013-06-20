require 'spec_helper'

module AlterOffspringSpec
  extend GenealogyTestModel

  describe "*** Alter offspring methods ***"  do
      
    before(:all) do
      AlterOffspringSpec.define_test_model_class({})
    end

    let(:titty) {TestModel.create!(:name => "titty", :sex => "F")}
    let(:peter) {TestModel.create!(:name => "peter", :sex => "M")}
    let(:steve) {TestModel.create!(:name => "steve", :sex => "M")}
    let(:paul) {TestModel.create!(:name => "paul", :sex => "M")}
    let(:michelle) {TestModel.create!(:name => "michelle", :sex => "F")}
    let(:maggie) {TestModel.create!(:name => "maggie", :sex => "F")}
    let(:julian) {TestModel.create!(:name => "julian", :sex => "M")}
    let(:john) {TestModel.create!(:name => "john", :sex => "M")}
    let(:dylan) {TestModel.create!(:name => "dylan", :sex => "M")}

    describe "paul" do
      subject { paul }

      describe "#add_offspring(peter)" do
        
        context "when all is ok" do

          shared_examples "adding peter to paul as child" do
            its(:offspring) { should =~ [peter] }
            describe "peter" do
              subject { peter.reload }
              its('mother') { should be_nil }
              its('father') { should == paul }
            end
          end

          describe "#add_offspring(peter)" do
            before(:each) { paul.add_offspring(peter) }
            it_should_behave_like "adding peter to paul as child"
          end

          describe "#add_child(peter)" do
            before(:each) { paul.add_child(peter) }
            it_should_behave_like "adding peter to paul as child"
          end

        end

        context "when peter is an ancestor" do
          before(:each) { paul.add_father(peter) }
          specify { expect { paul.add_offspring(peter) }.to raise_error(Genealogy::IncompatibleRelationshipException)}
        end

        context "when paul has undefined sex" do
          before(:each) { paul.sex = nil }
          specify { expect { paul.add_offspring(peter) }.to raise_error(Genealogy::WrongSexException) }
        end

      end

      describe "#add_offspring(peter,steve)" do
        
        context "when peter and steve are valid" do
          before(:each) { paul.add_offspring(peter,steve) }
          its(:offspring) { should =~ [peter,steve] }
          describe "peter" do
            subject { peter }
            its(:father) { should be(paul) }
            its(:mother) { should be_nil }
          end
          describe "steve" do
            subject { steve }
            its(:father) { should be(paul) }
            its(:mother) { should be_nil }
          end
        end

        context "when steve is invalid" do
          before(:each) { steve.mark_invalid! }
          specify { expect { paul.add_offspring(peter,steve) }.to raise_error }
          its(:offspring) do
            paul.add_offspring(peter,steve) rescue true
            should be_empty
          end
        end

      end

      describe "#add_offspring(julian, :spouse => michelle)" do
        before(:each) { paul.add_offspring(julian, :spouse => michelle) }
        its(:offspring) { should =~ [julian] }
        describe "michelle" do
          subject { michelle }
          its(:offspring) { should =~ [julian] }
        end
      end

      describe "#add_offspring(peter, :spouse => john)" do
        specify { expect { paul.add_offspring(peter, :spouse => john) }.to raise_error(Genealogy::WrongSexException) }
      end
      
      context "when already has two children with titty (steve and peter) and one with michelle (julian) and a last one with an unknown spouse (dylan)" do
        before(:each) do
          paul.add_offspring(peter,steve, :spouse => titty)
          paul.add_offspring(julian, :spouse => michelle)
          paul.add_offspring(dylan)
        end

        describe "#remove_offspring returned value" do
          specify { paul.remove_offspring.should be_true }
        end

        describe "#remove_offspring" do
          context "when offspring are all valid" do
            before(:each) { paul.remove_offspring }
            its(:offspring) { should be_empty }
            describe "titty" do
              subject {titty}
              its(:offspring) { should include steve,peter }
            end
          end
          context "steve is invalid" do
            before(:each) { steve.mark_invalid! }
            specify { expect { paul.remove_offspring }.to raise_error }
            its(:offspring) do
              paul.remove_offspring rescue true
              should =~ [steve,peter,julian,dylan]
            end
          end
        end

        describe "#remove_offspring(:affect_spouse => true)" do
          before(:each) { paul.remove_offspring(:affect_spouse => true) }
          its(:offspring) {should_not include steve,peter}
          describe "titty" do
            subject {titty}
            its(:offspring) { should_not include steve,peter }
          end
          describe "michelle" do
            subject {michelle}
            its(:offspring) { should_not include julian }
          end
        end

        describe "#remove_offspring(:spouse => titty)" do
          before(:each) { paul.remove_offspring(:spouse => titty) }
          its(:offspring) {should_not include steve,peter}
          describe "titty" do
            subject {titty}
            its(:offspring) { should include steve,peter }
          end
          describe "michelle" do
            subject {michelle}
            its(:offspring) { should include julian }
          end
        end

        describe "#remove_offspring(:spouse => titty, :affect_spouse => true)" do
          before(:each) { paul.remove_offspring(:spouse => titty, :affect_spouse => true) }
          its(:offspring) {should_not include steve,peter}
          describe "titty" do
            subject {titty}
            its(:offspring) { should_not include steve,peter }
          end
        end

        describe "#remove_offspring(:spouse => maggie)" do
          its(:offspring) do
            paul.remove_offspring(:spouse => maggie)
            should =~ [steve,peter,julian,dylan]
          end
          describe "result" do
            specify { paul.remove_offspring(:spouse => maggie).should be_false }
          end
        end

        context "when specify a spouse with the same sex" do
          describe "#remove_offspring(:spouse => john)" do
            specify { expect { paul.remove_offspring(:spouse => john) }.to raise_error(Genealogy::WrongSexException) }
          end
        end


      end

          
    end

  end
end