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
    let(:ciccio) {TestModel.create!(:name => "Ciccio", :sex => "M")}

    before(:each) do
      corrado.add_father(uccio)
      corrado.add_mother(tetta)
    end

    describe "corrado" do
      subject { corrado }

      context "when #add_sibling(stefano)" do
        
        before(:each) { corrado.add_siblings(stefano) }

        its(:siblings) { should include stefano }
        describe "stefano" do
          subject { stefano.reload }
          its(:siblings) { should include corrado }
        end

      end

      context "when #add_sibling(stefano) but something goes wrong while saving stefano" do

        before(:each) {stefano.always_fail!}

        specify { expect { corrado.add_siblings(stefano) }.to raise_error ActiveRecord::RecordInvalid }

        its(:siblings) do
          corrado.add_siblings(stefano) rescue true
          should_not include stefano
        end

        describe "stefano" do

          subject { stefano }
          its(:siblings) do
            corrado.add_siblings(stefano) rescue true
            should be_empty
          end

        end

      end

      context "when adding more than one sibling: #add_siblings(stefano,walter)" do
        before(:each) { corrado.add_siblings(stefano,walter) }

        its(:siblings) { should =~ [stefano,walter] }

        describe "stefano" do
          subject { stefano }
          its(:siblings) { should =~ [corrado,walter] }
        end

        describe "walter" do
          subject { walter }
          its(:siblings) { should =~ [corrado,stefano] }
        end

      end

      context "when trying to add an ancestor" do
        let(:narduccio) {TestModel.create!(:name => "Narduccio", :sex => "M", )}
        it "raises an IncompatibleRelationshipException" do
          corrado.add_paternal_grandfather(narduccio)
          expect { corrado.add_siblings(narduccio) }.to raise_error(Genealogy::IncompatibleRelationshipException)
        end
      end

      describe "adding half siblings" do
        
        context "when #add_siblings(walter, :father => ciccio )" do
          before(:each) {corrado.add_siblings(walter, :father => ciccio )}
          its(:half_siblings) do
             should =~ [walter]
          end
          its(:siblings) { should be_empty }
          describe "walter" do
            subject { walter }
            its(:father) { should == ciccio }
            its(:mother) { should == tetta }
          end
        end

        context "when #add_siblings(walter, :mother => gina )" do
          before(:each) {corrado.add_siblings(walter, :mother => gina )}
          its(:half_siblings) do
             should =~ [walter]
          end
          its(:siblings) { should be_empty }
          describe "walter" do
            subject { walter }
            its(:father) { should == uccio }
            its(:mother) { should == gina }
          end
        end

        context "when specify mother and father: #add_siblings(walter, :mother => gina, :father => ciccio )" do
          specify { expect { corrado.add_siblings(walter, :mother => gina, :father => ciccio ) }.to raise_error Genealogy::OptionException }
          describe "walter" do
            subject { walter }
            its(:parents) { should be_empty }
          end
        end

      end

    end


  end



end


