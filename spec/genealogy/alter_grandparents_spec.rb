require 'spec_helper'

describe "*** Alter grandparents methods ***", :done, :alter_gp  do

  context "when taking account validation and ineligibility by pedigree (default)" do
    before { @model = get_test_model({}) }
  
    include_context 'unreleted people exist'

    describe "#add_paternal_grandfather" do
      context "when receiver has not father" do
        specify { expect { peter.add_paternal_grandfather(manuel) }.to raise_error(Genealogy::LineageGapException)}
      end
      context "when receiver has father" do
        before { peter.update_attributes(father_id: paul.id) }
        subject { peter.add_paternal_grandfather(manuel) }
        it { is_expected.to be true }
        it { is_expected.to build_the_trio(paul, manuel, nil) }
        context 'when argument is nil' do
          subject { peter.add_paternal_grandfather(nil) }
          it_behaves_like "removing the relative", :peter, :paternal_grandfather
        end
        context "when father becomes invalid" do
          before { paul.mark_invalid! }
          specify { expect { subject }.to raise_error }
          describe "resulting trios" do
            subject { peter.add_paternal_grandfather(manuel) rescue true }
            specify { is_expected.to keep_the_trio(paul, nil, nil) }
          end
        end
        it_behaves_like 'raising error because of semantically wrong argument', :peter, :add_paternal_grandfather do
          context "when argument is a female" do
            specify { expect { peter.add_paternal_grandfather(michelle) }.to raise_error(Genealogy::IncompatibleRelationshipException) }
          end
          context "when argument is an ineligible individual, for example the father" do
            specify { expect { peter.add_paternal_grandfather(paul) }.to raise_error(Genealogy::IncompatibleRelationshipException) }
          end
        end
      end
    end

    describe "#add_paternal_grandmother" do
      context "when receiver has not father" do
        specify { expect { peter.add_paternal_grandmother(manuel) }.to raise_error(Genealogy::LineageGapException)}
      end
      context "when receiver has father" do
        before { peter.update_attributes(father_id: paul.id) }
        subject { peter.add_paternal_grandmother(terry) }
        it { is_expected.to be true }
        it { is_expected.to build_the_trio(paul, nil, terry) }
        context 'when argument is nil' do
          subject { peter.add_paternal_grandmother(nil) }
          it_behaves_like "removing the relative", :peter, :paternal_grandmother
        end
        context "when father becomes invalid" do
          before { paul.mark_invalid! }
          specify { expect { subject }.to raise_error }
          describe "resulting trios" do
            subject { peter.add_paternal_grandmother(terry) rescue true }
            specify { is_expected.to keep_the_trio(paul, nil, nil) }
          end
        end
        it_behaves_like 'raising error because of semantically wrong argument', :peter, :add_paternal_grandmother do
          context "when argument is a male" do
            specify { expect { peter.add_paternal_grandmother(manuel) }.to raise_error(Genealogy::IncompatibleRelationshipException) }
          end
          context "when argument is an ineligible individual, for example the father" do
            specify { expect { peter.add_paternal_grandmother(paul) }.to raise_error(Genealogy::IncompatibleRelationshipException) }
          end
        end
      end
    end

    describe "#add_maternal_grandfather" do
      pending 'analogical to #add_paternal_grandfather'
    end

    describe "#add_maternal_grandmother" do
      pending 'analogical to #add_paternal_grandmother'
    end

    describe "#add_paternal_grandparents" do
      context "when receiver has not father" do
        specify { expect { peter.add_paternal_grandparents(manuel,terry) }.to raise_error(Genealogy::LineageGapException)}
        it "does not affect receiver grandparents" do
          peter.add_paternal_grandparents(manuel,terry) rescue nil
          expect(peter.paternal_grandparents).to be nil
        end
      end
      context "when receiver has father" do
        before { peter.update_attributes(father_id: paul.id) }
        subject { peter.add_paternal_grandparents(manuel,terry) }
        it { is_expected.to be true }
        it { is_expected.to build_the_trio(paul, manuel, terry) }
        context 'when the last arguments is nil' do
          subject { peter.add_paternal_grandparents(manuel,nil) }
          it_behaves_like "removing the relative", :peter, :paternal_grandmother
          it "assign paternal grandfather" do
            subject
            expect(peter.paternal_grandfather).to be manuel
          end
        end
        context 'when both arguments are nil' do
          subject { peter.add_paternal_grandparents(nil,nil) }
          it_behaves_like "removing the relative", :peter, :paternal_grandfather
          it_behaves_like "removing the relative", :peter, :paternal_grandmother
        end
        context 'when arguments are swapped' do
          specify { expect { peter.add_paternal_grandparents(terry,manuel)  }.to raise_error(Genealogy::IncompatibleRelationshipException) }
        end
      end
    end

    describe "#add_maternal_grandparents" do
      pending 'analogical to #add_paternal_grandparents'
    end

    describe "#add_grandparents" do
      context "when receiver has both parents" do
        before { peter.update_attributes(father_id: paul.id, mother_id: titty.id) }
        subject { peter.add_grandparents(manuel,terry,paso,irene) }
        it { is_expected.to be true }
        it { is_expected.to build_the_trio(paul, manuel, terry, "father with his parents") }
        it { is_expected.to build_the_trio(titty, paso, irene, "mother with her parents") }
        context 'when some arguments are nil' do
          subject { peter.add_grandparents(manuel,nil,paso,nil) }
          it_behaves_like "removing the relative", :peter, :paternal_grandmother
          it_behaves_like "removing the relative", :peter, :maternal_grandmother
          it "assign paternal and maternal grandfather" do
            subject
            expect(peter.paternal_grandfather).to be manuel and
            expect(peter.maternal_grandfather).to be paso
          end
        end
      end
    end

    describe "#remove_paternal_grandfather" do
      include_context 'connect people'
      subject { peter.remove_paternal_grandfather }
      it { is_expected.to be true }
      it { is_expected.to build_the_trio(paul, nil, terry, "father with his parents") }
      it { is_expected.to keep_the_trio(titty, paso, irene, "mother with her parents") }
    end

    describe "#remove_grandparents"  do
      include_context 'connect people'
      subject { peter.remove_grandparents }
      it { is_expected.to be true }
      it { is_expected.to build_the_trio(paul, nil, nil, "father with his parents") }
      it { is_expected.to build_the_trio(titty, nil, nil, "mother with her parents") }
    end

  end


  context 'when ignoring ineligibility (options for has_parents: {:ineligibility => false})' do
    before { @model = get_test_model({:ineligibility => false }) }

    include_context "pedigree exists"

    describe "#add_paternal_grandfather" do
      context 'when father is already set' do
        specify { expect { peter.add_paternal_grandfather(rud) }.to_not raise_error }
        it "updates the paternal grandfather" do
          peter.add_paternal_grandfather(rud)
          expect(peter.paternal_grandfather).to eq rud
        end
      end
      context 'when argument is an ineligible individual, for example a descendant' do
        specify { expect { terry.add_paternal_grandfather(steve) }.to_not raise_error }
        it "updates the paternal grandfather" do
          terry.add_paternal_grandfather(steve)
          expect(terry.paternal_grandfather).to eq steve
        end
      end
    end

  end

  context "when ignoring validation (options for has_parents: {:perform_validation => false})" do
    before { @model = get_test_model({:perform_validation => false }) }

    context "when receiver's father becomes invalid" do

      describe "#add_paternal_grandfather" do
        include_context 'unreleted people exist'
        subject { peter.add_paternal_grandfather(manuel) }
        before { 
          paul.mark_invalid!
          peter.update_attributes(father_id: paul.id) 
        }
        specify { expect { subject }.to_not raise_error }
        it { is_expected.to build_the_trio(peter, paul, nil) }
      end

      describe "#remove_paternal_grandfather" do
        include_context "pedigree exists"
        before { paul.mark_invalid! }
        subject { peter.remove_paternal_grandfather }
        specify { expect { subject }.to_not raise_error }
        it { is_expected.to build_the_trio(paul, nil, terry) }
      end

    end


  end


end



