require 'spec_helper'

shared_context "manuel and terry are paternal grandparents and paso and irene are maternal grandparents" do
  before {
    peter.father.update_attributes(father_id: manuel.id, mother_id: terry.id) 
    peter.mother.update_attributes(father_id: paso.id, mother_id: irene.id) 
  }
end

describe "*** Alter grandparents methods ***", :done, :alter_gp  do

  context "when taking account validation (default options for has_parents)" do
    before { @model = get_test_model({}) }
  
    include_context 'unreleted people exist'

    context "when has no father" do
      describe "peter.add_paternal_grandfather(manuel)" do
        specify { expect { peter.add_paternal_grandfather(manuel) }.to raise_error(Genealogy::LineageGapException)}
      end
    end
    context "when has paul and titty as parents" do
      before { peter.update_attributes(father_id: paul.id, mother_id: titty.id) }

      describe "peter.add_paternal_grandfather(manuel)" do
        subject { peter.add_paternal_grandfather(manuel) }
        it { is_expected.to be true }
        it { is_expected.to build_the_trio(paul, manuel, nil) }

        context "when paul becomes invalid" do
          before { paul.mark_invalid! }
          specify { expect { subject }.to raise_error }
          describe "resulting trios" do
            subject { peter.add_paternal_grandfather(manuel) rescue true }
            specify { is_expected.to keep_the_trio(paul, nil, nil) }
          end
        end
  
      end

      it_behaves_like 'not accepting a semantically wrong argument', :peter, :add_paternal_grandfather do
        describe "peter.add_paternal_grandfather(michelle)" do
          specify { expect { peter.add_paternal_grandfather(michelle) }.to raise_error(Genealogy::IncompatibleRelationshipException) }
        end
        describe "peter.add_paternal_grandfather(paul)" do
          specify { expect { peter.add_paternal_grandfather(paul) }.to raise_error(Genealogy::IncompatibleRelationshipException) }
        end
      end

      describe "peter.add_paternal_grandmother(terry)" do
        subject { peter.add_paternal_grandmother(terry) }
        it { is_expected.to be true }
        it { is_expected.to build_the_trio(paul, nil, terry) }
      end

      it_behaves_like 'not accepting a semantically wrong argument', :peter, :add_paternal_grandmother do
        describe "peter.add_paternal_grandmother(manuel)" do
          specify { expect { peter.add_paternal_grandmother(manuel) }.to raise_error(Genealogy::IncompatibleRelationshipException) }
        end
      end

      describe "peter.add_grandparents(manuel,terry,paso,irene)" do
        subject { peter.add_grandparents(manuel,terry,paso,irene) }
        it { is_expected.to be true }
        it { is_expected.to build_the_trio(paul, manuel, terry) }
        it { is_expected.to build_the_trio(titty, paso, irene) }
      end

      describe "peter.add_grandparents(manuel,nil,paso,nil)" do
        subject { peter.add_grandparents(manuel,nil,paso,nil) }
        it { is_expected.to be true }
        it { is_expected.to build_the_trio(paul, manuel, nil) }
        it { is_expected.to build_the_trio(titty, paso, nil) }
      end

      it_behaves_like 'not accepting a semantically wrong argument', :peter, :add_grandparents, [:terry, :manuel, :paso, :irene]

      describe "peter.add_paternal_grandparents(manuel,terry)" do
        subject { peter.add_paternal_grandparents(manuel,terry) }
        it { is_expected.to be true }
        it { is_expected.to build_the_trio(paul, manuel, terry) }
      end

      it_behaves_like 'not accepting a semantically wrong argument', :peter, :add_paternal_grandparents, [:terry, :paso]

      describe "peter.add_maternal_grandparents(paso,irene)" do
        subject { peter.add_maternal_grandparents(paso,irene) }
        it { is_expected.to be true }
        it { is_expected.to build_the_trio(titty, paso, irene) }
      end

      it_behaves_like 'not accepting a semantically wrong argument', :peter, :add_maternal_grandparents, [:terry, :paso]

      describe "when has manuel and terry as paternal grandparents and paso and irene as maternal grandparents" do

        include_context "manuel and terry are paternal grandparents and paso and irene are maternal grandparents"

        describe "peter.remove_paternal_grandfather" do
          subject { peter.remove_paternal_grandfather }
          it { is_expected.to be true }
          it { is_expected.to build_the_trio(paul, nil, terry) }
        end

        describe "peter.remove_grandparents" do
          subject { peter.remove_grandparents }
          it { is_expected.to be true }
          it { is_expected.to build_the_trio(paul, nil, nil) }
          it { is_expected.to build_the_trio(terry, nil, nil) }
        end

      end
    end

  end

  context "when ignoring validation (options for has_parents: {:perform_validation => false})" do
    before { @model = get_test_model({:perform_validation => false }) }

    include_context 'unreleted people exist'

    context "when has paul and titty as parents" do
      before { peter.update_attributes(father_id: paul.id, mother_id: titty.id) }
      context "when paul becomes invalid" do
        before { paul.mark_invalid! }
        describe "peter.add_paternal_grandfather(manuel)" do
          subject { peter.add_paternal_grandfather(manuel) }
          it { is_expected.to be true }
          it { is_expected.to build_the_trio(paul, manuel, nil) }
        end
      end

    end
  end

end



