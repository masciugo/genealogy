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
    
    describe "peter son of paul and titty" do

      before(:each) do
        peter.add_father(paul)
        peter.add_mother(titty)
      end

      subject { peter.reload }

      shared_examples "adding steve to peter as sibling" do
        its(:siblings) { should include steve }
        describe "steve" do
          subject { steve.reload }
          its(:siblings) { should include peter }
        end
      end

      describe "#add_siblings(steve)" do
        before(:each) { peter.add_siblings(steve) }
        it_should_behave_like "adding steve to peter as sibling"
      end

      describe "#add_sibling(steve)" do
        before(:each) { peter.add_sibling(steve) }
        it_should_behave_like "adding steve to peter as sibling"
      end

      describe "#add_siblings(steve) returned value", :wip do
        
        specify { expect(peter.add_siblings(steve)).to be true }
      
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

        its(:siblings) { should match_array [steve,walter] }

        describe "steve" do
          subject { steve.reload }
          its(:siblings) { should match_array [peter,walter] }
        end

        describe "walter" do
          subject { walter.reload  }
          its(:siblings) { should match_array [peter,steve] }
        end

      end

      context "when manuel is a peter's ancestor" do
        before(:each) { peter.add_paternal_grandfather(manuel) }
        describe "#add_paternal_grandfather(manuel)" do
          specify { expect { peter.add_siblings(manuel) }.to raise_error(Genealogy::IncompatibleRelationshipException) }
        end
      end

      shared_examples "adding julian and paso to peter as paternal half siblings" do
        its(:half_siblings) do
           should match_array [julian,paso]
        end
        its(:siblings) { should be_empty }
        describe "julian" do
          subject { julian }
          its(:father) { should == paul }
          its(:mother) { should be_nil}
        end
      end

      describe "#add_siblings(julian,paso, :half => :father)" do
        before(:each) {peter.add_siblings(julian,paso, :half => :father )}
        it_should_behave_like "adding julian and paso to peter as paternal half siblings"
      end

      describe "#add_paternal_half_siblings(julian,paso)" do
        before(:each) {peter.add_paternal_half_siblings(julian,paso)}
        it_should_behave_like "adding julian and paso to peter as paternal half siblings"
      end

      describe "#add_paternal_half_sibling(julian) and #add_paternal_half_sibling(paso)" do
        before(:each) do 
          peter.add_paternal_half_sibling(julian)
          peter.add_paternal_half_sibling(paso)
        end
        it_should_behave_like "adding julian and paso to peter as paternal half siblings"
      end

      context "when he has no mother" do
        before(:each) do
          peter.remove_mother
          peter.add_paternal_half_siblings(julian,paso)
        end
        it_should_behave_like "adding julian and paso to peter as paternal half siblings"
      end

      describe "#add_siblings(julian, :half => :father, :spouse => michelle )" do
        before(:each) {peter.add_siblings(julian, :half => :father, :spouse => michelle )}
        its(:half_siblings) do
           should match_array [julian]
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
           should match_array [mary]
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
          its(:parents) { should match_array [nil,nil] }
        end
      end

      context "when he has steve and manuel as full sibling and julian and paso as paternal half sibling and agata as maternal half sibling" do

        before(:each) do
          peter.add_siblings(steve,manuel)
          peter.add_siblings(julian,paso, :half => :father, :spouse => michelle )
          peter.add_siblings(agata, :half => :mother )
        end
        
        shared_examples "removing all siblings" do
          its(:siblings) { should be_empty }
          its(:half_siblings) { should match_array [julian,agata,paso] }
          its(:parents) { should match_array [paul,titty] }
          describe "steve" do
            subject { steve.reload }
            its(:siblings) { should be_empty }
            its(:mother) { should be_nil }
          end
        end

        describe "#remove_siblings" do
          before(:each) { peter.remove_siblings }
          it_should_behave_like "removing all siblings"
        end

        describe "#remove_sibling(steve) and #remove_sibling(manuel)" do
          before(:each) do
            peter.remove_sibling(steve)
            peter.remove_sibling(manuel)
          end
          it_should_behave_like "removing all siblings"
        end

        describe "#remove_siblings returned value" do
          specify { expect(peter.remove_siblings).to be true }
        end

        shared_examples "removing all paternal half siblings" do
          its(:siblings) { should match_array [steve, manuel] }
          its(:half_siblings) { should match_array [agata] }
          its(:parents) { should match_array [paul,titty] }
          describe "julian" do
            subject{ julian.reload }
            its(:father) { should be_nil }
            its(:mother) { should == michelle }
          end
        end

        describe "#remove_siblings(:half => :father)" do
          before(:each) { peter.remove_siblings(:half => :father ) }
          it_should_behave_like "removing all paternal half siblings"
        end

        describe "#remove_paternal_half_siblings" do
          before(:each) { peter.remove_paternal_half_siblings }
          it_should_behave_like "removing all paternal half siblings"
        end

        describe "#remove_paternal_half_siblings(julian)" do
          before(:each) { peter.remove_paternal_half_siblings(julian) }
          its(:half_siblings) { should match_array [agata,paso] }
        end

        describe "#remove_paternal_half_siblings(manuel) returned value" do
          specify { expect(peter.remove_paternal_half_siblings(manuel)).to be false }
        end

        describe "#remove_maternal_half_siblings" do
          before(:each) { peter.remove_maternal_half_siblings }
          its(:half_siblings) { should match_array [julian,paso] }
        end

        describe "#remove_siblings(:half => :mother) " do
          before(:each) do
            peter.remove_siblings(:half => :mother )
          end
          its(:siblings) { should match_array [steve, manuel] }
          its(:half_siblings) { should match_array [julian,paso] }
          its(:parents) { should match_array [paul,titty] }
        end

        describe "#remove_siblings(:half => :foo) " do
          specify { expect { peter.remove_siblings(:half => :foo) }.to raise_error Genealogy::WrongOptionException }
        end


        describe "#remove_siblings(:half => :father, :affect_spouse => true ) " do
          before(:each) { peter.remove_siblings(:half => :father, :affect_spouse => true  ) }
          describe "julian" do
            subject {julian.reload}
            its(:parents) { should match_array [nil,nil] }
          end
        end

        describe "#remove_siblings(steve)" do
          before(:each) { peter.remove_siblings(steve) }
          its(:siblings) { should match_array [manuel] }
          describe "steve" do
            subject {steve.reload}
            its(:parents) { should match_array [nil,nil] }
          end
        end

        describe "#remove_sibling(steve, :half => :father )" do
          before(:each) { peter.remove_siblings(steve, :half => :father) }
          its(:siblings) { should match_array [steve, manuel] }
        end

      end

    end

  end



end


