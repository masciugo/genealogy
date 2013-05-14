require 'spec_helper'

module AddingSiblingsSpec
  extend GenealogyTestModel

  describe "adding siblings" do

    before(:all) do
      AddingSiblingsSpec.define_test_model_class({})
    end

    let(:uccio) {TestModel.create!(:name => "Uccio", :sex => "M")}
    let(:tetta) {TestModel.create!(:name => "Tetta", :sex => "F")}
    let(:gina) {TestModel.create!(:name => "Gina", :sex => "F")}
    let(:stefano) {TestModel.create!(:name => "Stefano", :sex => "M")}
    let(:corrado) {TestModel.create!(:name => "Corrado", :sex => "M")}
    let(:walter) {TestModel.create!(:name => "Walter", :sex => "M")}
    let(:dylan) {TestModel.create!(:name => "Dylan", :sex => "M")}

    before(:each) do
      corrado.add_father!(uccio)
      corrado.add_mother!(tetta)
    end

    describe "#add_siblings!" do

      context "when add_sibling! stefano to corrado" do
        before(:each) do
          corrado.add_siblings!(stefano)
        end

        describe "corrado siblings" do
          subject { corrado.siblings }
          specify {should include stefano}
        end

        describe "stefano siblings" do
          subject { stefano.siblings }
          specify {should include corrado}
        end

      end

      context "when add_sibling! stefano to corrado but something goes wrong while saving stefano" do

        before(:each) do
          stefano.always_fail_validation = true
        end

        specify { expect { corrado.add_siblings!(stefano) }.to raise_error ActiveRecord::RecordInvalid }

        describe "corrado siblings" do
          subject { corrado.siblings }
          specify { expect { corrado.add_siblings!(stefano) }.to raise_error ActiveRecord::RecordInvalid and corrado.reload.siblings.should_not include stefano }
        end

        describe "stefano siblings" do
          subject { stefano.siblings }
          specify { expect { corrado.add_siblings!(stefano) }.to raise_error ActiveRecord::RecordInvalid and stefano.reload.siblings.should be_nil}
        end

      end

      context "when adding more than one sibling" do
        before(:each) do
          corrado.add_siblings!([stefano,walter])
        end

        describe "corrado siblings" do
          subject { corrado.siblings }
          specify {should include stefano,walter}
        end

        describe "stefano siblings" do
          subject { stefano.siblings }
          specify {should include corrado,walter}
        end

        describe "walter siblings" do
          subject { walter.siblings }
          specify {should include corrado,stefano}
        end

      end

      context "when trying to add an ancestor" do
        let(:narduccio) {TestModel.create!(:name => "Narduccio", :sex => "M", )}
        subject{ corrado }
        it "raises an IncompatibleRelationshipException" do
          subject.add_paternal_grandfather!(narduccio)
          expect { subject.add_siblings!([narduccio]) }.to raise_error(Genealogy::IncompatibleRelationshipException)
        end
      end
    end

    describe "#add_siblings" do
      
      describe "result" do

        it "must be true" do
          corrado.add_siblings(stefano).should be_true
        end

        context "when adding more than one sibling with success" do

          it "must be true" do
            corrado.add_siblings([stefano,walter]).should be_true
          end
          
        end

      end

      context "when add_sibling stefano to corrado" do

        before(:each) do
          corrado.add_siblings(stefano)
        end

        context "and stefano is saved" do

          before(:each) do
            stefano.save!
          end

          describe "corrado siblings" do
            subject { corrado.reload.siblings }
            specify {should include stefano}
          end

          describe "stefano siblings" do
            subject { stefano.reload.siblings }
            specify {should include corrado}
          end

        end

        context "and stefano is not saved" do

          describe "corrado siblings" do
            subject { corrado.reload.siblings }
            specify {should_not include stefano}
          end

          describe "stefano siblings" do
            subject { stefano.reload.siblings }
            specify {should be_nil}
          end

        end

      end

      context "when add_sibling to (whose both parents are nil)" do

        specify { expect { dylan.add_siblings(stefano) }.to raise_error Genealogy::LineageGapException }

      end

    end

  end



end


