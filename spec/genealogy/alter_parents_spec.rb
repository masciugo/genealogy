require 'spec_helper'

shared_context "paul and titty are peter's parents" do
  before { peter.update_attributes(father_id: paul.id, mother_id: titty.id) }
end


describe "*** Alter parents methods ***", :done, :alter_p  do

  context "when taking account validation (options for has_parents: {:current_spouse => true})" do
    before { @model = get_test_model({}) }
  
    include_context 'unreleted people exist'

    it_behaves_like 'not accepting a semantically wrong argument', :peter, :add_father do
      describe "peter.add_father(titty)" do
        specify { expect { peter.add_father(titty) }.to raise_error(Genealogy::IncompatibleRelationshipException) }
      end
    end

    describe "peter.add_father(paul)" do
      subject { peter.add_father(paul) }
      it { is_expected.to be true }
      it { is_expected.to build_the_trio(peter, paul, nil) }
    end

    it_behaves_like 'not accepting a semantically wrong argument', :peter, :add_mother do
      describe "peter.add_mother(john)" do
        specify { expect { peter.add_mother(john) }.to raise_error(Genealogy::IncompatibleRelationshipException) }
      end
    end

    describe "peter.add_mother(titty)" do
      subject { peter.add_mother(titty) }
      it { is_expected.to be true }
      it { is_expected.to build_the_trio(peter, nil, titty) }
    end

    describe "peter.add_parents(paul,titty)" do
      subject { peter.add_parents(paul,titty) }
      it { is_expected.to be true }
      it { is_expected.to build_the_trio(peter, paul, titty) }

      it_behaves_like 'not accepting a semantically wrong argument', :peter, :add_parents, [:titty, :paul]

      context "when peter becomes invalid" do
        before { peter.mark_invalid! }
        specify { expect { peter.add_parents(paul,titty) }.to raise_error }
        describe "resulting trios" do
          subject { peter.add_parents(paul,titty) rescue true }
          it { is_expected.to keep_the_trio(peter, nil, nil) }
        end
      end

    end

    context "when has paul and titty as parents" do

      include_context "paul and titty are peter's parents"

      describe "peter.remove_father" do
        subject { peter.remove_father }
        it { is_expected.to be true }
        it { is_expected.to build_the_trio(peter, nil, titty) }
      end

      describe "peter.remove_mother" do
        subject { peter.remove_mother }
        it { is_expected.to be true }
        it { is_expected.to build_the_trio(peter, paul, nil) }
      end

      describe "peter.remove_parents" do
        subject { peter.remove_parents }
        it { is_expected.to be true }
        it { is_expected.to build_the_trio(peter, nil, nil) }
      end

      context "when peter becomes invalid" do
        before { peter.mark_invalid! }
        specify { expect { peter.remove_parents }.to raise_error }
        describe "resulting trios" do
          subject { peter.remove_parents rescue true }
          it { is_expected.to keep_the_trio(peter, paul,titty) }
        end
      end

      describe "peter.add_parents(nil,nil)" do
        specify { expect(peter.add_parents(nil,nil)).to build_the_trio(peter, nil, nil)}
      end

      describe "peter.add_father(nil)" do
        specify { expect(peter.add_father(nil)).to build_the_trio(peter, nil, titty) }
      end

      describe "peter.add_mother(nil)" do
        specify { expect(peter.add_mother(nil)).to build_the_trio(peter, paul, nil) }
      end

    end
  end

  context "when ignoring validation (options for has_parents: {:perform_validation => false})" do
    before { @model = get_test_model({:perform_validation => false }) }

    include_context 'unreleted people exist'

    context "when peter becomes invalid" do

      before { peter.mark_invalid! }
          
      describe "peter.add_parents(paul,titty)" do
        subject { peter.add_parents(paul,titty) }
        specify { expect { peter.add_parents(paul,titty) }.to_not raise_error }
        it { is_expected.to build_the_trio(peter, paul, titty) }
      end

      context "when has paul and titty as parents" do

        include_context "paul and titty are peter's parents"

        describe "peter.remove_parents" do
          subject { peter.remove_parents }
          specify { expect { peter.remove_parents }.to_not raise_error }
          it { is_expected.to build_the_trio(peter, nil, nil) }
        end

      end
    end


  end

end

