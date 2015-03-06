require 'spec_helper'

shared_context 'paul and titty are spouses to each other' do
  before do
    paul.update_attribute(:current_spouse_id, titty.id)
    titty.update_attribute(:current_spouse_id, paul.id)
  end
end


describe "*** Alter current_spouse methods ***", :done, :spouse do

  context "when current spouse tracking not enabled" do
    before {  @model = get_test_model }
    include_context 'unreleted people exist'
    describe "#add_current_spouse" do
      specify { expect { paul.add_current_spouse(titty) }.to raise_error(Genealogy::FeatureNotEnabled)}
    end
    describe "#remove_current_spouse" do
      specify { expect { paul.remove_current_spouse }.to raise_error(Genealogy::FeatureNotEnabled)}
    end
  end

  context "when enabling current spouse traking and taking account validation and ineligibility by pedigree (options for has_parents: {:current_spouse => true})" do

    before { @model = get_test_model({:current_spouse => true}) }      

    include_context 'unreleted people exist'  
    
    describe "#add_current_spouse" do
      subject { paul.add_current_spouse(titty) }
      it { is_expected.to build_the_couple(paul,titty) }
      context "when receiver becomes invalid" do
        before { paul.mark_invalid! }
        specify { expect { subject  }.to raise_error }
        it 'receiver and argument remain singles' do
          subject rescue nil
          expect(paul).to remain_single and expect(john).to remain_single
        end
      end
      context "when argument becomes invalid" do
        before { titty.mark_invalid! }
        specify { expect { subject  }.to raise_error }
        it 'receiver and argument remain singles' do
          subject rescue nil
          expect(paul).to remain_single and expect(john).to remain_single
        end
      end
      it_behaves_like 'raising error because of semantically wrong argument', :paul, :add_current_spouse do
        describe "when argument is male" do
          subject { paul.add_current_spouse(john) }
          specify { expect { subject }.to raise_error(Genealogy::IncompatibleRelationshipException) }
          it 'receiver and argument remain singles' do
            subject rescue nil
            expect(paul).to remain_single and expect(john).to remain_single
          end
        end
      end
    end

    describe "#remove_current_spouse" do

      include_context 'paul and titty are spouses to each other'
      subject { paul.remove_current_spouse }
      it 'receiver and argument become singles' do
        subject
        expect(paul).to be_single and expect(titty).to be_single
      end
      context "when receiver becomes invalid" do
        before { paul.mark_invalid! }
        specify { expect { subject }.to raise_error }
        it 'receiver and argument remain a couple' do
          subject rescue nil
          expect([paul,titty]).to remain_a_couple
        end
      end 

    end

  end

  context 'when ignoring ineligibility (options for has_parents: {:current_spouse => true, :ineligibility => false})' do
    before { @model = get_test_model({:current_spouse => true, :ineligibility => false }) }

    include_context "pedigree exists"

    describe "#add_current_spouse" do
      context 'when current spouse is already set' do
        subject { paul.add_current_spouse(titty) }
        specify { expect { subject }.not_to raise_error }
        it "updates the current spouse" do
          subject rescue nil
          expect([paul,titty]).to be_a_couple
        end
      end
      context 'when argument is an ineligible individual, for example a male' do
        subject { paul.add_current_spouse(rud) }
        specify { expect { subject }.not_to raise_error }
        it "updates the current spouse" do
          subject rescue nil
          expect([paul,rud]).to be_a_couple
        end
      end
    end

  end

  context "when ignoring validation (options for has_parents: {:current_spouse => true, :perform_validation => false})" do

    before(:context) do
      @model = get_test_model({:current_spouse => true, :perform_validation => false})
    end

    include_context 'unreleted people exist'  
          
    context "when receiver becomes invalid" do
      
      before { paul.mark_invalid! }
          
      describe "#add_current_spouse" do
        subject { paul.add_current_spouse(titty) }
        specify { expect { subject }.not_to raise_error }
        it { is_expected.to build_the_couple(paul,titty) }
      end

      describe "#remove_current_spouse" do
        include_context 'paul and titty are spouses to each other'
        subject { paul.remove_current_spouse }
        specify { expect { subject }.not_to raise_error }
        it 'receiver and argument become singles' do
          subject
          expect(paul).to be_single and expect(titty).to be_single
        end
      end

    end

  end

end

