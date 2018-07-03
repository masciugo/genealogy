require 'spec_helper'

shared_examples 'raising error and not affecting the trio' do |error,trio|
  specify { expect { subject }.to error ? raise_error(error) : raise_error}
  specify {
    subject rescue nil
    expect(trio.map{|sym| send(sym) if sym }).to remain_a_trio
  }
end


describe "*** Alter siblings methods ***", :done, :alter_s do

  context "when taking account validation (default options for has_parents)" do
    before { @model = get_test_model({}) }

    include_context 'unreleted people exist'

    describe "#add_siblings" do
      context 'when receiver has not parents' do
        subject { peter.add_siblings(steve) }
        context 'when argument has already the parents' do
          before { steve.update_attributes(father_id: paul.id, mother_id: titty.id) }
          it_behaves_like "raising error and not affecting the trio", Genealogy::LineageGapException, [:steve,:paul,:titty]
        end
        context 'when argument has only one parent' do
          before { steve.update_attributes(father_id: paul.id) }
          it_behaves_like "raising error and not affecting the trio", Genealogy::LineageGapException, [:steve,:paul,nil]
        end
        context 'when argument has not parents' do
          it_behaves_like "raising error and not affecting the trio", Genealogy::LineageGapException, [:steve,nil,nil]
        end
      end

      context "when receiver has parents" do

        before { peter.update_attributes(father_id: paul.id, mother_id: titty.id) }

        subject { peter.add_siblings(steve) }
        it { is_expected.to be true }
        it "argument and receiver become siblings" do
          subject
          expect([peter,steve]).to be_siblings
        end

        context 'when adding multiple siblings' do
          subject { peter.add_siblings(steve,julian) }
          it { is_expected.to be true }
          it "arguments and receiver become siblings" do
            subject
            expect([peter,steve]).to be_siblings and
            expect([peter,julian]).to be_siblings
          end

        end

        context "when argument is a receiver's ancestor" do
          before { peter.add_paternal_grandfather(steve) }
          it_behaves_like "raising error and not affecting the trio", Genealogy::IncompatibleRelationshipException, [:steve,nil,nil]
        end

        context "when argument is already a receiver's sibling" do
          before { steve.update_attributes(father_id: paul.id, mother_id: titty.id) }
          it_behaves_like "raising error and not affecting the trio", Genealogy::IncompatibleRelationshipException, [:steve,:paul,:titty]
        end

        context "when argument is invalid" do
          before { steve.mark_invalid! }
          it_behaves_like "raising error and not affecting the trio", nil, [:steve,nil,nil]
        end

        shared_examples "a method which add paternal half siblings" do |*args|
          before { args.map!{|p| eval(p.to_s)} }
          it { is_expected.to be true }
          it "involved individuals become paternal half siblings" do
            subject
            expect(args).to be_paternal_half_siblings
          end
        end

        context "when specify option half: :father" do
          subject { peter.add_siblings(julian, half: :father ) }
          it_behaves_like "a method which add paternal half siblings", :peter, :julian
        end


        context "when specify option half: :father and :spouse" do
          subject { peter.add_siblings(julian, half: :father, spouse: michelle) }
          it_behaves_like "a method which add paternal half siblings", :peter, :julian do
            it "updates argument's mother with provided spouse" do
              subject
              expect(julian.mother).to be michelle
            end
          end
        end

        describe "when specify option half: :father and an ineligible :spouse )" do
          subject { peter.add_siblings(julian, half: :father, spouse: paso) }
          it_behaves_like "raising error and not affecting the trio", Genealogy::IncompatibleRelationshipException, [:julian,nil,nil]
        end

      end

    end

    describe "#remove_siblings" do

      subject { peter.remove_siblings }

      context 'when receiver does not have siblings' do
        it { is_expected.to be false }
      end
      context 'when receiver has some full siblings, paternal and maternal half siblings ' do
        include_context "connect people" do
          before {
            sue.update_attributes(father_id: paul.id, mother_id: titty.id) # extra full sibling
            rud.update_attributes(father_id: nil, mother_id: titty.id) # extra maternal half sibling
          }
        end
        it { is_expected.to be true }
        it "makes receiver to not have full siblings" do
          subject
          expect([peter,steve,sue]).not_to be_siblings
        end
        it "makes receiver to keep paternal half siblings" do
          subject
          expect([peter,ruben,julian,mary]).to be_paternal_half_siblings
        end
        it "makes receiver to keep maternal half siblings" do
          subject
          expect([peter,rud]).to be_maternal_half_siblings
        end
        context 'when specify a sibling as argument' do
          context 'when that sibling is a full sibling' do
            subject { peter.remove_siblings(steve) }
            it { is_expected.to be true }
            it "makes receiver to remove that sibling and keep the others" do
              subject
              expect([peter,steve]).not_to be_siblings and
              expect([peter,sue]).to be_siblings
            end
          end
          context 'when that sibling is an half sibling' do
            subject { peter.remove_siblings(julian) }
            it { is_expected.to be false }
            it "does not update anything" do
              subject
              expect([peter,sue,steve]).to be_siblings and
              expect([peter,julian,mary,ruben]).to be_paternal_half_siblings and
              expect([peter,rud]).to be_maternal_half_siblings
            end
          end
        end
        context 'when specify option half: :father' do
          before { peter.remove_siblings(half: :father) }
          it "makes receiver to keep full siblings" do
            expect([peter,steve,sue]).to be_siblings
          end
          it "makes receiver to not have paternal half siblings" do
            expect([peter,ruben,julian,mary]).not_to be_paternal_half_siblings
          end
          it "makes receiver to keep maternal half siblings" do
            expect([peter,rud]).to be_maternal_half_siblings
          end
        end
        context 'when specify option half: :mother' do
          before { peter.remove_siblings(half: :mother) }
          it "makes receiver to keep full siblings" do
            expect([peter,steve,sue]).to be_siblings
          end
          it "makes receiver to keep paternal half siblings" do
            expect([peter,ruben,julian,mary]).to be_paternal_half_siblings
          end
          it "makes receiver to not have maternal half siblings" do
            expect([peter,rud]).not_to be_maternal_half_siblings
          end
        end
        context "when specify unexpected value for :half option" do
          specify { expect { peter.remove_siblings(half: :foo) }.to raise_error ArgumentError }
        end
        context "when specify option half: :father and remove_other_parent: true" do
          before { peter.remove_siblings(half: :father, remove_other_parent: true) }
          it "makes receiver to not have paternal half siblings" do
            expect([peter,ruben,julian,mary]).not_to be_paternal_half_siblings
          end
          it "makes all ex paternal half siblings to not have a mother" do
            expect( [ruben,julian,mary].map(&:reload).map(&:mother).compact).to be_empty
          end
        end
      end

    end

    describe '#add_paternal_half_siblings' do
      context 'when receiver has parents' do
        before { peter.update_attributes(father_id: paul.id, mother_id: titty.id) }
        subject { peter.add_paternal_half_siblings(steve) }
        it { is_expected.to be true }
        it "argument and receiver become half siblings" do
          subject
          expect(peter.father).to eq(steve.father)
        end
      end
    end

    describe '#add_maternal_half_siblings' do
      context 'when receiver has parents' do
        before { peter.update_attributes(father_id: paul.id, mother_id: titty.id) }
        subject { peter.add_maternal_half_siblings(steve) }
        it { is_expected.to be true }
        it "argument and receiver become half siblings" do
          subject
          expect(peter.mother).to eq(steve.mother)
        end
      end
    end

    describe '#remove_paternal_half_siblings' do
      context 'when receiver has some full siblings, paternal and maternal half siblings ' do
        include_context "connect people"
        it 'removes all paternal half siblings' do
          peter.remove_paternal_half_siblings
          expect(peter.paternal_half_siblings).to be_empty
        end
        context 'when specify a sibling as argument' do
          it 'removes it keepeing their mother' do
            peter.remove_paternal_half_siblings(beatrix)
            expect(peter.paternal_half_siblings).to match_array([julian, mary, ruben])
          end
        end
         context 'when specify a sibling as argument and remove_other_parent: true' do
          it 'removes their mother too' do
            peter.remove_paternal_half_siblings(beatrix, remove_other_parent: true)
            expect(beatrix.mother).to be_nil
          end
        end
      end
    end

    describe '#remove_maternal_half_siblings' do
      context 'when receiver has some full siblings, maternal and maternal half siblings ' do
        include_context "connect people"
        it 'removes all maternal half siblings' do
          jack.remove_maternal_half_siblings
          expect(jack.maternal_half_siblings).to be_empty
        end
        context 'when specify a sibling as argument' do
          it 'removes it keepeing their father' do
            jack.remove_maternal_half_siblings(tommy)
            expect(jack.maternal_half_siblings).to be_empty
          end
        end
         context 'when specify a sibling as argument and remove_other_parent: true' do
          it 'removes their father too' do
            jack.remove_maternal_half_siblings(tommy, remove_other_parent: true)
            expect(tommy.father).to be_nil
          end
        end
      end
    end

  end

  context 'when ignoring ineligibility (options for has_parents: {ineligibility: false})' do
    before { @model = get_test_model({ineligibility: false }) }

    include_context "pedigree exists"

    describe "#add_siblings" do

      context "when argument is a receiver's ancestor" do
        subject { peter.add_siblings(manuel) }
        specify { expect { subject }.not_to raise_error }
        it "argument and receiver become siblings" do
          subject
          expect([peter,manuel]).to be_siblings
        end
      end

      context "when argument is already a receiver's sibling" do
        subject { peter.add_siblings(steve) }
        specify { expect { subject }.not_to raise_error }
        it "argument and receiver are still siblings" do
          subject
          expect([peter,steve]).to be_siblings
        end
      end
    end

  end

  context "when ignoring validation (options for has_parents: {perform_validation: false})" do
    before { @model = get_test_model({perform_validation: false }) }

    context "when receiver becomes invalid" do

      describe "#add_siblings" do
        include_context 'unreleted people exist' do
          before {
            peter.update_attributes(father_id: paul.id, mother_id: titty.id)
            steve.mark_invalid!
          }
        end
        subject { peter.add_siblings(steve) }
        specify { expect { subject }.not_to raise_error }
        it "argument and receiver become siblings" do
          subject
          expect([peter,steve]).to be_siblings
        end
      end

      describe "#remove_siblings" do
        include_context "pedigree exists" do
          before { steve.mark_invalid! }
        end
        subject { peter.remove_siblings }
        specify { expect { subject }.not_to raise_error }
        it "makes receiver to not have full siblings" do
          subject
          expect([peter,steve,sue]).not_to be_siblings
        end
      end

    end

  end

end

