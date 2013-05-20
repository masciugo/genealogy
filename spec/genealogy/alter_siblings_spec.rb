require 'spec_helper'

module AlterSiblingsSpec
  extend GenealogyTestModel

  describe "siblings methods applied to corrado:" do
    subject { corrado }

    before(:all) do
      AlterSiblingsSpec.define_test_model_class({})
    end

    let(:uccio) {TestModel.create!(:name => "Uccio", :sex => "M")}
    let(:tetta) {TestModel.create!(:name => "Tetta", :sex => "F")}
    let(:gina) {TestModel.create!(:name => "Gina", :sex => "F")}
    let(:stefano) {TestModel.create!(:name => "Stefano", :sex => "M")}
    let(:corrado) {TestModel.create!(:name => "Corrado", :sex => "M")}
    let(:walter) {TestModel.create!(:name => "Walter", :sex => "M")}
    let(:ciccio) {TestModel.create!(:name => "Ciccio", :sex => "M")}
    let(:agata) {TestModel.create!(:name => "Agata", :sex => "F")}

    before(:each) do
      corrado.add_father(uccio)
      corrado.add_mother(tetta)
    end

    describe "#add_sibling(stefano)" do
      
      before(:each) { corrado.add_siblings(stefano) }

      its(:siblings) { should include stefano }
      describe "stefano" do
        subject { stefano.reload }
        its(:siblings) { should include corrado }
      end

    end

    describe "#add_sibling(stefano) but something goes wrong while saving stefano" do

      before(:each) {stefano.mark_invalid!}

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

    context "when adding half siblings" do
      
      describe "#add_siblings(walter, :half => :mother, :spouse => ciccio )" do
        before(:each) {corrado.add_siblings(walter, :half => :mother, :spouse => ciccio )}
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

      describe "#add_siblings(walter, :half => :father, :spouse => gina )" do
        before(:each) {corrado.add_siblings(walter, :half => :father, :spouse => gina )}
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

      describe "#add_siblings(walter, :half => :father)" do
        before(:each) {corrado.add_siblings(walter, :half => :father )}
        its(:half_siblings) do
           should =~ [walter]
        end
        its(:siblings) { should be_empty }
        describe "walter" do
          subject { walter }
          its(:father) { should == uccio }
          its(:mother) { should be_nil}
        end
      end

      describe "when specify a spouse with the same sex: corrado.add_siblings(walter, :spouse => ciccio )" do
        specify { expect { corrado.add_siblings(walter, :half => :father, :spouse => ciccio ) }.to raise_error Genealogy::WrongSexException }
        describe "walter" do
          subject { walter }
          its(:parents) { should be_empty }
        end
      end

    end

    describe "when he has stefano as full sibling and walter as paternal halfsibling and ciccio as maternal half sibling" do

      before(:each) do
        corrado.add_siblings(stefano)
        corrado.add_siblings(walter, :half => :father, :spouse => gina )
        corrado.add_siblings(agata, :half => :mother )
      end
      
      describe "#remove_siblings" do
        before(:each) do
          corrado.remove_siblings
          corrado.reload
        end
        its(:siblings) { should be_empty }
        its(:half_siblings) { should =~ [walter,agata] }
        describe "stefano" do
          subject { stefano.reload }
          its(:siblings) { should be_empty }
          its(:mother) { should be_nil }
        end
      end

      describe "#remove_siblings(:half => :father) " do
        before(:each) do
          corrado.remove_siblings(:half => :father )
        end
        its(:siblings) { should be_empty }
        its(:half_siblings) { should =~ [stefano,agata] }
        its(:mother) { should be(tetta) }
      end

      describe "#remove_siblings(:half => :mother) " do
        before(:each) do
          corrado.remove_siblings(:half => :mother )
        end
        its(:siblings) { should be_empty }
        its(:half_siblings) { should =~ [stefano,walter] }
        its(:father) { should be(uccio) }
      end

      describe "#remove_siblings(:half => :father, :affect_spouse => true ) " do
        before(:each) do
          corrado.remove_siblings(:half => :father, :affect_spouse => true  )
        end
        its(:siblings) { should be_empty }
        its(:half_siblings) { should =~ [agata] }
        describe "stefano" do
          subject {stefano.reload}
          its(:parents) { should be_empty }
        end
        describe "walter" do
          subject {walter.reload}
          its(:parents) { should be_empty }
        end
      end

    end

  end



end


