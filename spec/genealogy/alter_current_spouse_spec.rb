require 'spec_helper'

shared_context 'paul and titty are spouses to each other' do
  before do
    paul.update_attribute(:current_spouse_id, titty.id)
    titty.update_attribute(:current_spouse_id, paul.id)
  end
end



describe "*** Alter current_spouse methods ***", :done do

  context "when taking account validation (options for has_parents: {:current_spouse => true})" do

    before(:context) do
      @model = get_test_model({:current_spouse => true})
    end

    include_context 'unreleted people exist'  
    
    describe "paul.add_current_spouse(titty)" do
      subject { paul.add_current_spouse(titty) }
      it { is_expected.to build_the_couple(paul,titty) }
      context "when paul is invalid" do
        before { paul.mark_invalid! }
        specify { expect { paul.add_current_spouse(titty) }.to raise_error }
        it 'they remain singles' do
          paul.add_current_spouse(titty) rescue true
          expect(paul).to be_single and expect(titty).to be_single
        end
      end
    end
    it_behaves_like 'not accepting a semantically wrong argument', :paul, :add_current_spouse do
      describe "paul.add_current_spouse(john)" do
        specify { expect { paul.add_current_spouse(john) }.to raise_error(Genealogy::IncompatibleRelationshipException) }
        it 'they remain singles' do
          paul.add_current_spouse(john) rescue true
          expect(paul).to be_single and expect(john).to be_single
        end
      end
    end

    describe "paul.remove_current_spouse" do

      include_context 'paul and titty are spouses to each other'
      
      it 'they are singles' do
        paul.remove_current_spouse
        expect(paul).to be_single and expect(titty).to be_single
      end
      context "when paul is invalid" do
        before { paul.mark_invalid! }
        specify { expect { paul.remove_current_spouse }.to raise_error }
        it { 
          paul.remove_current_spouse rescue true
          expect([paul,titty]).to be_a_couple
        }
      end 

    end

  end

  context "when ignoring validation (options for has_parents: {:current_spouse => true, :perform_validation => false})" do

    before(:context) do
      @model = get_test_model({:current_spouse => true, :perform_validation => false})
    end

    include_context 'unreleted people exist'  
          
    context "when peter becomes invalid" do
      
      before { paul.mark_invalid! }
          
      describe "paul.add_current_spouse(titty)" do
        subject { paul.add_current_spouse(titty) }
        specify { expect { subject }.to_not raise_error }
        it { is_expected.to build_the_couple(paul,titty) }
      end

      describe "paul.remove_current_spouse" do
        include_context 'paul and titty are spouses to each other'
        specify { expect { paul.remove_current_spouse }.to_not raise_error }
        it { 
          paul.remove_current_spouse
          expect(paul).to be_single and expect(titty).to be_single
        }
      end

    end

  end

end

