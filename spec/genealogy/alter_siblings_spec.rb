require 'spec_helper'

module AlterSiblingsSpec
  extend GenealogyTestModel

  describe "*** Alter siblings methods ***" do
    
    before(:all) do
      AlterSiblingsSpec.define_test_model_class({})
    end

    let(:paul) {TestModel.create!(:name => "paul", :sex => "M")}
    let(:titty) {TestModel.create!(:name => "titty", :sex => "F")}
    let(:steve) {TestModel.create!(:name => "steve", :sex => "M")}
    let(:peter) {TestModel.create!(:name => "peter", :sex => "M")}
    let(:walter) {TestModel.create!(:name => "walter", :sex => "M")}
    let(:manuel) {TestModel.create!(:name => "manuel", :sex => "M")}
    let(:paso) {TestModel.create!(:name => "paso", :sex => "M")}
    let(:julian) {TestModel.create!(:name => "julian", :sex => "M")}
    let(:mary) {TestModel.create!(:name => "mary", :sex => "F")}
    let(:barbara) {TestModel.create!(:name => "barbara", :sex => "F")}
    let(:michelle) {TestModel.create!(:name => "michelle", :sex => "F")}
    let(:agata) {TestModel.create!(:name => "agata", :sex => "F")}
    
    before(:each) do
      peter.add_father(paul)
      peter.add_mother(titty)
    end

    describe "peter son of paul and titty" do
      subject { peter.reload }

      describe "#add_sibling(steve)" do
        
        before(:each) { peter.add_siblings(steve) }

        its(:siblings) { should include steve }
        describe "steve" do
          subject { steve.reload }
          its(:siblings) { should include peter }
        end

      end

      describe "#add_siblings(steve) returned value" do
        
        specify { expect(peter.add_siblings(steve)).to be_true }
      
      end

      context "steve is invalid" do
        before(:each) {steve.mark_invalid!}

        describe "#add_sibling(steve)" do

          before(:each) {peter.add_siblings(steve) rescue true}

          specify { expect { peter.add_siblings(steve) }.to raise_error ActiveRecord::RecordInvalid }

          its(:siblings) {should_not include steve}

          describe "steve" do
            subject { steve.reload }
            its(:siblings) {should be_empty}
          end

        end
      end

      context "#add_siblings(steve,walter)" do
        before(:each) { peter.add_siblings(steve,walter) }

        its(:siblings) { should =~ [steve,walter] }

        describe "steve" do
          subject { steve.reload }
          its(:siblings) { should =~ [peter,walter] }
        end

        describe "walter" do
          subject { walter.reload  }
          its(:siblings) { should =~ [peter,steve] }
        end

      end

      context "when manuel is a peter's ancestor" do
        before(:each) { peter.add_paternal_grandfather(manuel) }
        describe "#add_paternal_grandfather(manuel)" do
          specify { expect { peter.add_siblings(manuel) }.to raise_error(Genealogy::IncompatibleRelationshipException) }
        end
      end

      shared_examples "adding julian to peter as paternal half sibling" do
        its(:half_siblings) do
           should =~ [julian]
        end
        its(:siblings) { should be_empty }
        describe "julian" do
          subject { julian }
          its(:father) { should == paul }
          its(:mother) { should be_nil}
        end
      end

      describe "#add_siblings(julian, :half => :father)" do
        before(:each) {peter.add_siblings(julian, :half => :father )}
        it_should_behave_like "adding julian to peter as paternal half sibling"
      end

      describe "#add_paternal_half_siblings(julian)" do
        before(:each) {peter.add_paternal_half_siblings(julian)}
        it_should_behave_like "adding julian to peter as paternal half sibling"
      end

      describe "#add_siblings(julian, :half => :father, :spouse => michelle )" do
        before(:each) {peter.add_siblings(julian, :half => :father, :spouse => michelle )}
        its(:half_siblings) do
           should =~ [julian]
        end
        its(:siblings) { should be_empty }
        describe "julian" do
          subject { julian }
          its(:father) { should == paul }
          its(:mother) { should == michelle }
        end
      end

      describe "#add_siblings(mary, :half => :father, :spouse => barbara )" do
        before(:each) {peter.add_siblings(mary, :half => :father, :spouse => barbara )}
        its(:half_siblings) do
           should =~ [mary]
        end
        its(:siblings) { should be_empty }
        describe "mary" do
          subject { mary }
          its(:father) { should == paul }
          its(:mother) { should == barbara }
        end
      end

      describe "#add_siblings(mary, :spouse => paso )" do
        specify { expect { peter.add_siblings(mary, :half => :father, :spouse => paso ) }.to raise_error Genealogy::WrongSexException }
        describe "mary" do
          subject { mary }
          its(:parents) { should be_empty }
        end
      end

      context "when he has steve and manuel as full sibling and julian and paso as paternal half sibling and agata as maternal half sibling" do

        before(:each) do
          peter.add_siblings(steve,manuel)
          peter.add_siblings(julian,paso, :half => :father, :spouse => michelle )
          peter.add_siblings(agata, :half => :mother )
        end
        
        describe "#remove_siblings" do
          before(:each) { peter.remove_siblings }
          its(:siblings) { should be_empty }
          its(:half_siblings) { should =~ [julian,agata,paso] }
          its(:parents) { should =~ [paul,titty] }
          describe "steve" do
            subject { steve.reload }
            its(:siblings) { should be_empty }
            its(:mother) { should be_nil }
          end
        end

        describe "#remove_siblings returned value" do
          specify { expect(peter.remove_siblings).to be_true }
        end

        describe "#remove_siblings(:half => :father)" do
          before(:each) { peter.remove_siblings(:half => :father ) }
          its(:siblings) { should =~ [steve, manuel] }
          its(:half_siblings) { should =~ [agata] }
          its(:parents) { should =~ [paul,titty] }
          describe "julian" do
            subject{ julian.reload }
            its(:father) { should be_nil }
            its(:mother) { should == michelle }
          end
        end

        describe "#remove_paternal_half_siblings" do
          before(:each) { peter.remove_paternal_half_siblings }
          its(:siblings) { should =~ [steve, manuel] }
          its(:half_siblings) { should =~ [agata] }
          its(:parents) { should =~ [paul,titty] }
          describe "julian" do
            subject{ julian.reload }
            its(:father) { should be_nil }
            its(:mother) { should == michelle }
          end
        end

        describe "#remove_paternal_half_siblings(julian)" do
          before(:each) { peter.remove_paternal_half_siblings(julian) }
          its(:half_siblings) { should =~ [agata,paso] }
        end

        describe "#remove_paternal_half_siblings(manuel) returned value" do
          specify { expect(peter.remove_paternal_half_siblings(manuel)).to be_false }
        end

        describe "#remove_maternal_half_siblings" do
          before(:each) { peter.remove_maternal_half_siblings }
          its(:half_siblings) { should =~ [julian,paso] }
        end

        describe "#remove_siblings(:half => :mother) " do
          before(:each) do
            peter.remove_siblings(:half => :mother )
          end
          its(:siblings) { should =~ [steve, manuel] }
          its(:half_siblings) { should =~ [julian,paso] }
          its(:parents) { should =~ [paul,titty] }
        end

        describe "#remove_siblings(:half => :foo) " do
          specify { expect { peter.remove_siblings(:half => :foo) }.to raise_error Genealogy::WrongOptionException }
        end


        describe "#remove_siblings(:half => :father, :affect_spouse => true ) " do
          before(:each) { peter.remove_siblings(:half => :father, :affect_spouse => true  ) }
          describe "julian" do
            subject {julian.reload}
            its(:parents) { should be_empty }
          end
        end

        describe "#remove_sibling(steve)" do
          before(:each) { peter.remove_siblings(steve) }
          its(:siblings) { should =~ [manuel] }
          describe "steve" do
            subject {steve.reload}
            its(:parents) { should be_empty }
          end
        end

        describe "#remove_sibling(steve, :half => :father )" do
          before(:each) { peter.remove_siblings(steve, :half => :father) }
          its(:siblings) { should =~ [steve, manuel] }
        end

      end

    end

  end



end


