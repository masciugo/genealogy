require 'spec_helper'

describe "*** Alter siblings methods ***", :done do

  context "when taking account validation (default options for has_parents)" do
    before { @model = get_test_model({}) }
  
    include_context 'unreleted people exist'

    context "when peter is son of paul and titty" do

      before { peter.update_attributes(father_id: paul.id, mother_id: titty.id) }

      describe "peter.add_siblings(steve)" do
        subject { peter.add_siblings(steve) }
        it { is_expected.to be true }
        describe "steve, peter" do
          it { subject and expect([peter,steve]).to be_siblings }
        end

        context "when steve is a peter's ancestor" do
          before { peter.add_paternal_grandfather(steve) }
          specify { expect { subject }.to raise_error(Genealogy::IncompatibleRelationshipException) }
        end

        context "when steve is already a peter's sibling" do
          before { steve.update_attributes(father_id: paul.id, mother_id: titty.id) }
          specify { expect { subject }.to raise_error(Genealogy::IncompatibleRelationshipException) }
        end
        
        context "when steve is invalid" do
          before { steve.mark_invalid! }
          specify { expect { subject }.to raise_error }
          describe "steve, peter" do
            it { 
              subject rescue true
              expect([peter,steve]).to_not be_siblings 
            }
          end

        end
      end

      describe "peter.add_sibling(steve)" do
        subject { peter.add_sibling(steve) }
        it { is_expected.to be true }
        describe "steve, peter" do
          it { subject and expect([peter,steve]).to be_siblings }
        end
      end

      context "steve is invalid" do
        before {steve.mark_invalid!}
        describe "peter.add_sibling(steve)" do
          subject {peter.add_siblings(steve) rescue true}
          specify { expect { peter.add_siblings(steve) }.to raise_error ActiveRecord::RecordInvalid }
          describe "steve, peter" do
            it { subject and expect([peter,steve]).to_not be_siblings }
          end
        end
      end

      describe "peter.add_siblings(steve,walter)" do
        subject { peter.add_siblings(steve,walter) }
        it { is_expected.to be true }
        describe "steve, peter, walter" do
          it { subject and expect([peter,steve,walter]).to be_siblings }
        end
      end


      shared_examples "a method which add paternal half siblings" do |*args|
        before { args.map!{|p| eval(p.to_s)} }
        it { is_expected.to be true }
        describe args.to_sentence do
          it { subject and expect(args).to be_paternal_half_siblings }
        end
      end

      describe "peter.add_siblings(julian,paso, :half => :father)" do
        subject { peter.add_siblings(julian,paso, :half => :father ) }
        it_behaves_like "a method which add paternal half siblings", :peter, :julian, :paso
      end

      describe "peter.add_paternal_half_siblings(julian,paso)" do
        subject {peter.add_paternal_half_siblings(julian,paso)}
        it_behaves_like "a method which add paternal half siblings", :peter, :julian, :paso
        context "when peter has no mother" do
          before { peter.update_attributes(mother_id: nil) }
          it_behaves_like "a method which add paternal half siblings", :peter, :julian, :paso
        end
      end

      describe "peter.add_paternal_half_sibling(julian) and #add_paternal_half_sibling(paso)" do
        subject do 
          peter.add_paternal_half_sibling(julian)
          peter.add_paternal_half_sibling(paso)
        end
        it_behaves_like "a method which add paternal half siblings", :peter, :julian, :paso
      end

      describe "peter.add_siblings(julian, :half => :father, :spouse => michelle )" do
        subject { peter.add_siblings(julian, :half => :father, :spouse => michelle) }
        it_behaves_like "a method which add paternal half siblings", :peter, :julian
        describe "julian's mother" do
          specify { subject and expect(julian.mother).to be michelle }
        end
      end

      describe "peter.add_siblings(julian, :half => :father, :spouse => paso )" do
        subject { peter.add_siblings(julian, :half => :father, :spouse => paso) }
        specify { expect { subject }.to raise_error Genealogy::IncompatibleRelationshipException }
        describe "julian's parents to be nil" do
          specify { (subject rescue true) and expect(julian.father).to be nil and expect(julian.mother).to be nil}
        end
      end

      context "when peter has steve and manuel as full sibling and julian and paso as paternal half sibling (mother maggie) and agata as maternal half sibling (father dylan)" do
        before {
          steve.update_attributes(father_id: paul.id, mother_id: titty.id)
          manuel.update_attributes(father_id: paul.id, mother_id: titty.id)
          paso.update_attributes(father_id: paul.id, mother_id: maggie.id)
          julian.update_attributes(father_id: paul.id, mother_id: maggie.id)
          agata.update_attributes(father_id: dylan.id, mother_id: titty.id)
        }

        describe "peter.remove_siblings" do
          subject { peter.remove_siblings }
          it { is_expected.to be true }
          describe "after removing" do
            before { subject  }
            it "steve and manuel has no parents" do
              expect(steve.reload.father).to eq nil and
              expect(steve.reload.mother).to eq nil and 
              expect(manuel.reload.father).to eq nil and
              expect(manuel.reload.mother).to eq nil
            end
            it "julian and paso are still paternal half sibling" do
              expect(julian.reload.father).to eq paul and
              expect(julian.reload.mother).to eq maggie and
              expect(paso.reload.father).to eq paul and
              expect(paso.reload.mother).to eq maggie 
            end
            it "agata is still maternal half sibling" do
              expect(agata.reload.father).to eq dylan and
              expect(agata.reload.mother).to eq titty 
            end
          end
        end

        describe "peter.remove_sibling(steve)" do
          subject { peter.remove_sibling(steve) }
          it { is_expected.to be true }
          describe "after removing" do
            before { subject  }
            it "steve has no parents" do
              expect(steve.reload.father).to eq nil and
              expect(steve.reload.mother).to eq nil
            end
          end
        end

        describe "peter.remove_sibling(julian)" do
          subject { peter.remove_sibling(julian) }
          it { is_expected.to be false }
          describe "after removing" do
            before { subject  }
            it "julian has still his parents" do
              expect(julian.reload.father).to eq paul and
              expect(julian.reload.mother).to eq maggie
            end
          end
        end

        shared_examples 'remove paternal half siblings' do
          it { is_expected.to be true }
          describe "after removing" do
            before { subject  }
            it "steve and manuel are still full siblings" do
              expect(steve.reload.father).to eq paul and
              expect(steve.reload.mother).to eq titty and 
              expect(manuel.reload.father).to eq paul and
              expect(manuel.reload.mother).to eq titty
            end
            it "julian and paso are not paternal half siblings" do
              expect(julian.reload.father).to eq nil and
              expect(paso.reload.father).to eq nil 
            end
            it "agata is still maternal half sibling" do
              expect(agata.reload.mother).to eq titty 
            end
          end
        end

        describe "peter.remove_siblings(:half => :father)" do
          subject { peter.remove_siblings(:half => :father) }
          it_behaves_like 'remove paternal half siblings'
        end

        describe "peter.remove_paternal_half_siblings" do
          subject { peter.remove_paternal_half_siblings }
          it_behaves_like "remove paternal half siblings"
        end

        describe "peter.remove_paternal_half_siblings(julian)" do
          subject { peter.remove_paternal_half_siblings(julian) }
          it { is_expected.to be true }
          describe "after removing" do
            before { subject }
            it "julian is not paternal half siblings" do
              expect(julian.reload.father).to eq nil
            end
            it "paso and agata are still paternal half siblings" do
              expect([peter,paso]).to be_paternal_half_siblings 
            end
          end
        end

        describe "peter.remove_paternal_half_siblings(steve)" do
          subject { peter.remove_paternal_half_siblings(steve) }
          it { is_expected.to be false }
          describe "after removing" do
            before { subject  }
            it "steve has still his parents" do
              expect(steve.reload.father).to eq paul and
              expect(steve.reload.mother).to eq titty
            end
          end
        end


        shared_examples 'remove maternal half siblings' do
          it { is_expected.to be true }
          describe "after removing" do
            before { subject  }
            it "steve and manuel are still full siblings" do
              expect(steve.reload.father).to eq paul and
              expect(steve.reload.mother).to eq titty and 
              expect(manuel.reload.father).to eq paul and
              expect(manuel.reload.mother).to eq titty
            end
            it "julian and paso are still paternal half siblings" do
              expect(julian.reload.father).to eq paul and
              expect(paso.reload.father).to eq paul 
            end
            it "agata is not maternal half sibling" do
              expect(agata.reload.mother).to eq nil 
            end
          end
        end

        describe "peter.remove_siblings(:half => :mother)" do
          subject { peter.remove_siblings(:half => :mother) }
          it_behaves_like 'remove maternal half siblings'
        end

        describe "peter.remove_maternal_half_siblings" do
          subject { peter.remove_maternal_half_siblings }
          it_behaves_like 'remove maternal half siblings'
        end

        describe "peter.remove_siblings(:half => :foo) " do
          specify { expect { peter.remove_siblings(:half => :foo) }.to raise_error ArgumentError }
        end

        describe "peter.remove_siblings(:half => :father, :affect_spouse => true ) " do
          subject { peter.remove_siblings(:half => :father, :affect_spouse => true  ) }
          it_behaves_like 'remove paternal half siblings'
          describe "after removing" do
            it "julian's mother is nil" do
              subject
              expect(julian.reload.mother).to be nil
            end
          end
        end

      end

    end



  end

  context "when ignoring validation (options for has_parents: {:perform_validation => false})" do
    before { @model = get_test_model({:perform_validation => false }) }

    include_context 'unreleted people exist'

    context "when peter is son of paul and titty and steve is invalid" do

      before { 
        peter.update_attributes(father_id: paul.id, mother_id: titty.id) 
        steve.mark_invalid!
      }

      describe "peter.add_siblings(steve)" do
        subject { peter.add_siblings(steve) }
        specify { expect { subject }.to_not raise_error }
        it { is_expected.to be true }
        describe "steve, peter" do
          it { subject and expect([peter,steve]).to be_siblings }
        end
      end

      context "when peter has steve and manuel as full sibling and julian and paso as paternal half sibling (mother maggie) and agata as maternal half sibling (father dylan)" do
        before { 
          steve.update_attribute(:father_id, paul.id) 
          steve.update_attribute(:mother_id, titty.id) 
        }

        describe "peter.remove_siblings" do
          subject { peter.remove_siblings }
          specify { expect { subject }.to_not raise_error }
          it { is_expected.to be true }
          describe "after removing" do
            before { subject  }
            it "steve has no parents" do
              expect(steve.reload.father).to eq nil and
              expect(steve.reload.mother).to eq nil
            end
          end
        end

      end


    end


  end

end

