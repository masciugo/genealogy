require 'spec_helper'

shared_context 'paul has some children' do
  before do
    peter.update(father_id: paul.id, mother_id: titty.id)
    steve.update(father_id: paul.id, mother_id: titty.id)
    julian.update(father_id: paul.id, mother_id: michelle.id)
    ruben.update(father_id: paul.id)
  end
end


describe "*** Alter children methods ***", :done, :alter_c  do

  context "when taking account validation (default options for has_parents)" do
    before { @model = get_test_model({}) }

    include_context 'unreleted people exist'

    describe "#add_children" do

      context "when passing one child" do
        subject { paul.add_children(peter) }
        it { is_expected.to be true }
        it "updates child's parent, keeping the other unaffected" do
          subject
          expect([peter, paul, nil]).to be_a_trio
        end
      end

      it_behaves_like 'raising error because of semantically wrong argument', :paul, :add_children

      context "when passing more children" do
        subject { paul.add_children(peter,steve) }
        it { is_expected.to be true }
        it "updates children's parent, keeping the other unaffected" do
          subject
          expect([peter, paul, nil]).to be_a_trio and
          expect([steve, paul, nil]).to be_a_trio
        end

        context "when one child is invalid" do
          before { steve.mark_invalid! }
          subject { paul.add_children(peter,steve) }
          specify { expect { subject }.to raise_error(ActiveRecord::RecordInvalid) }
          it "children remain unaffected" do
            subject rescue nil
            expect([peter, nil, nil]).to be_a_trio and
            expect([steve, nil, nil]).to be_a_trio
          end
        end

      end

      context 'when child argument already has parent' do
        before { peter.update_attribute(:father_id, rud.id) }
        specify { expect { paul.add_children(peter) }.to raise_error(Genealogy::IncompatibleRelationshipException)}
      end

      context "when child argument is an ancestor" do
        before { paul.update_attribute(:father_id, peter.id) }
        specify { expect { paul.add_children(peter) }.to raise_error(Genealogy::IncompatibleRelationshipException)}
      end

      context "when has undefined sex" do
        before { paul.sex = nil }
        specify { expect { paul.add_children(peter) }.to raise_error(Genealogy::SexError) }
      end

      context "when specify spouse too" do
        subject { paul.add_children(julian, spouse: michelle) }
        it { is_expected.to build_the_trio(julian, paul, michelle) }
        context "when spouse is ineligible" do
          specify { expect { paul.add_children(peter, spouse: john) }.to raise_error(Genealogy::IncompatibleRelationshipException) }
          specify { expect { paul.add_children(michelle,spouse: michelle) }.to raise_error(Genealogy::IncompatibleRelationshipException)}
        end
      end

    end

    describe "#remove_children" do
      include_context 'paul has some children'
      subject { paul.remove_children }
      it { is_expected.to be true }
      it "make all children lose father but keeping mother" do
        subject
        expect([peter, nil, titty]).to be_a_trio and
        expect([steve, nil, titty]).to be_a_trio and
        expect([julian, nil, michelle]).to be_a_trio and
        expect([ruben, nil, nil]).to be_a_trio
      end
      context 'when specify to affect the other parent removing them' do
        it "make all children lose both parents" do
          paul.remove_children(remove_other_parent: true)
          expect([peter, nil, nil]).to be_a_trio and
          expect([steve, nil, nil]).to be_a_trio and
          expect([julian, nil, nil]).to be_a_trio and
          expect([ruben, nil, nil]).to be_a_trio
        end
      end
      context 'when specify spouse' do
        it "make only children with that spouse lose father but keeping mother" do
          paul.remove_children(spouse: titty)
          expect([peter, nil, titty]).to be_a_trio and
          expect([steve, nil, titty]).to be_a_trio and
          expect([julian, paul, michelle]).to be_a_trio and
          expect([ruben, paul, nil]).to be_a_trio
        end
      end
      context 'when specify spouse and to affect the other parent removing them' do
        it "make only children with that spouse lose both parents" do
          paul.remove_children(spouse: titty, remove_other_parent: true)
          expect([peter, nil, nil]).to be_a_trio and
          expect([steve, nil, nil]).to be_a_trio and
          expect([julian, paul, michelle]).to be_a_trio and
          expect([ruben, paul, nil]).to be_a_trio
        end
      end
      context 'when specify a spouse with whom receiver has not children' do
        it "children remain unaffected" do
          paul.remove_children(spouse: maggie)
          expect([peter, paul, titty]).to be_a_trio and
          expect([steve, paul, titty]).to be_a_trio and
          expect([julian, paul, michelle]).to be_a_trio and
          expect([ruben, paul, nil]).to be_a_trio
        end
      end
      context "when specify a spouse with the same sex" do
        specify { expect { paul.remove_children(spouse: john) }.to raise_error(Genealogy::SexError) }
      end
      context "when one child is invalid" do
        before { steve.mark_invalid! }
        subject { paul.remove_children }
        specify { expect { subject }.to raise_error(ActiveRecord::RecordInvalid) }
        it "children remain unaffected" do
          subject rescue nil
          expect([peter, paul, titty]).to be_a_trio and
          expect([steve, paul, titty]).to be_a_trio and
          expect([julian, paul, michelle]).to be_a_trio and
          expect([ruben, paul, nil]).to be_a_trio
        end
      end

    end

  end

  context 'when ignoring ineligibility (options for has_parents: {ineligibility: false})' do
    before { @model = get_test_model({ineligibility: false }) }

    include_context "pedigree exists"

    describe "#add_children" do
      context 'when child argument already has parent' do
        before { peter.update_attribute(:father_id, rud.id) }
        subject { paul.add_children(peter) }
        specify { expect { subject }.not_to raise_error }
        it { is_expected.to be true }
        it "updates child's parent" do
          subject
          expect(peter.father).to eq paul
        end
      end

      context "when child argument is an ancestor" do
        subject { paul.add_children(manuel) }
        specify { expect { subject }.not_to raise_error }
        it { is_expected.to be true }
        it "updates child's parent" do
          subject
          expect(manuel.father).to eq paul
        end
      end
    end

  end

  context "when ignoring validation (options for has_parents: {perform_validation: false})" do
    before { @model = get_test_model({perform_validation: false }) }

    include_context 'unreleted people exist'

    context 'when one child becomes invalid' do

      describe "#add_children" do
        before { steve.mark_invalid! }
        subject { paul.add_children(peter,steve) }
        specify { expect { subject }.not_to raise_error }
        it "updates children's parent, keeping the other unaffected" do
          subject
          expect([peter, paul, nil]).to be_a_trio and
          expect([steve, paul, nil]).to be_a_trio
        end
      end

      describe "#remove_children" do
        include_context 'paul has some children'
        before { steve.mark_invalid! }
        subject { paul.remove_children }
        specify { expect { subject }.not_to raise_error }
        it "make all children lose father but keeping mother" do
          subject
          expect([peter, nil, titty]).to be_a_trio and
          expect([steve, nil, titty]).to be_a_trio and
          expect([julian, nil, michelle]).to be_a_trio and
          expect([ruben, nil, nil]).to be_a_trio
        end
      end

    end

  end

end
