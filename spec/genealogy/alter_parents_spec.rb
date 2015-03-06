require 'spec_helper'

describe "*** Alter parents methods ***", :done, :alter_p  do

  context "when taking account validation and ineligibility by pedigree (default)" do
    before { @model = get_test_model({}) }
  
    include_context 'unreleted people exist'

    describe "#add_father" do
      subject { peter.add_father(paul) }
      it { is_expected.to be true }
      it { is_expected.to build_the_trio(peter, paul, nil) }
      context 'when argument is nil' do
        subject { peter.add_father(nil) }
        it_behaves_like "removing the relative", :peter, :father
      end
      it_behaves_like 'raising error because of semantically wrong argument', :peter, :add_father do
        context 'when passing a female' do
          specify { expect { peter.add_father(titty) }.to raise_error(Genealogy::IncompatibleRelationshipException) }
        end
        context 'when passing an ineligible individual, for example a descendant' do
          before { 
            paul.update_attributes(father_id: manuel.id) 
            julian.update_attributes(father_id: paul.id) 
          }
          specify { expect { manuel.add_father(julian) }.to raise_error Genealogy::IncompatibleRelationshipException }
        end
      end
      context 'when father is already set' do
        before { peter.update_attributes(father_id: paul.id) }
        specify { expect { peter.add_father(paso) }.to raise_error Genealogy::IncompatibleRelationshipException }
      end
    end

    describe "#add_mother" do
      subject { peter.add_mother(titty) }
      it { is_expected.to be true }
      it { is_expected.to build_the_trio(peter, nil, titty) }
      context 'when argument is nil' do
        subject { peter.add_mother(nil) }
        it_behaves_like "removing the relative", :peter, :mother
      end
      it_behaves_like 'raising error because of semantically wrong argument', :peter, :add_mother do
        context 'when argument is male' do
          specify { expect { peter.add_mother(john) }.to raise_error(Genealogy::IncompatibleRelationshipException) }
        end
        context 'when mother is already set' do
          before { peter.update_attributes(mother_id: titty.id) }
          specify { expect { peter.add_mother(titty) }.to raise_error Genealogy::IncompatibleRelationshipException }
        end
        context 'when argument is an ineligible individual, for example a descendant' do
          before { 
            paul.update_attributes(father_id: manuel.id) 
            beatrix.update_attributes(father_id: paul.id) 
          }
          specify { expect { manuel.add_mother(beatrix) }.to raise_error Genealogy::IncompatibleRelationshipException }
        end
      end
      context 'when mother is already set' do
        before { peter.update_attributes(mother_id: titty.id) }
        specify { expect { peter.add_mother(irene) }.to raise_error Genealogy::IncompatibleRelationshipException }
      end
    end

    describe "#add_parents" do
      subject { peter.add_parents(paul,titty) }
      it { is_expected.to be true }
      it { is_expected.to build_the_trio(peter, paul, titty) }
      context 'when the last arguments is nil' do
        subject { peter.add_parents(paul,nil) }
        it_behaves_like "removing the relative", :peter, :mother
        it "assign father" do
          subject
          expect(peter.father).to be paul
        end
      end
      context 'when both arguments are nil' do
        subject { peter.add_parents(nil,nil) }
        it_behaves_like "removing the relative", :peter, :father
        it_behaves_like "removing the relative", :peter, :mother
      end
      context 'when arguments are swapped' do
        specify { expect { peter.add_parents(titty,paul)  }.to raise_error(Genealogy::IncompatibleRelationshipException) }
      end
      context "when receiver becomes invalid" do
        before { peter.mark_invalid! }
        specify { expect { peter.add_parents(paul,titty) }.to raise_error }
        describe "resulting trios" do
          subject { peter.add_parents(paul,titty) rescue true }
          it { is_expected.to keep_the_trio(peter, nil, nil) }
        end
      end
    end

    describe "#remove_father" do
      include_context "connect people"
      subject { peter.remove_father }
      it { is_expected.to be true }
      it { is_expected.to build_the_trio(peter, nil, titty) }
    end

    describe "#remove_mother" do
      include_context "connect people"
      subject { peter.remove_mother }
      it { is_expected.to be true }
      it { is_expected.to build_the_trio(peter, paul, nil) }
    end

    describe "#remove_parents" do
      include_context "connect people"
      subject { peter.remove_parents }
      it { is_expected.to be true }
      it { is_expected.to build_the_trio(peter, nil, nil) }
      context "when receiver becomes invalid" do
        before { peter.mark_invalid! }
        specify { expect { peter.remove_parents }.to raise_error }
        describe "resulting trios" do
          subject { peter.remove_parents rescue true }
          it { is_expected.to keep_the_trio(peter, paul, titty) }
        end
      end
    end

  end

  context 'when ignoring ineligibility (options for has_parents: {:ineligibility => false})' do
    before { @model = get_test_model({:ineligibility => false }) }

    include_context "pedigree exists"

    describe "#add_father" do
      context 'when father is already set' do
        specify { expect { peter.add_father(rud) }.to_not raise_error }
        it "updates the father" do
          peter.add_father(rud)
          expect(peter.father).to eq rud
        end
      end
      context 'when argument is an ineligible individual, for example a descendant' do
        specify { expect { terry.add_mother(beatrix) }.to_not raise_error }
        it "updates the mother" do
          terry.add_mother(beatrix)
          expect(terry.mother).to eq beatrix
        end
      end
    end

  end

  context "when ignoring validation (options for has_parents: {:perform_validation => false})" do
    before { @model = get_test_model({:perform_validation => false }) }

    context "when receiver becomes invalid" do

      describe "#add_parents" do
        include_context 'unreleted people exist'
        before { peter.mark_invalid! }
        subject { peter.add_parents(paul,titty) }
        specify { expect { subject }.to_not raise_error }
        it { is_expected.to build_the_trio(peter, paul, titty) }
      end

      describe "#remove_parents" do
        include_context "pedigree exists"
        before { paul.mark_invalid! }
        subject { peter.remove_parents }
        specify { expect { subject }.to_not raise_error }
        it { is_expected.to build_the_trio(peter, nil, nil) }
      end

    end

  end

end

