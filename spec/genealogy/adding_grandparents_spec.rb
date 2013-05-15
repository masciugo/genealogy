require 'spec_helper'

module AddingGrandparentsSpec
  extend GenealogyTestModel

  describe "corrado" do
    
    before(:all) do
      AddingGrandparentsSpec.define_test_model_class({})
    end

    subject(:corrado) {TestModel.create!(:name => "Corrado", :sex => "M")}
    
    let(:uccio) {TestModel.create!(:name => "Uccio", :sex => "M", )}
    let(:narduccio) {TestModel.create!(:name => "Narduccio", :sex => "M", )}
    let(:maria) {TestModel.create!(:name => "Maria", :sex => "F", )}
    let(:tetta) {TestModel.create!(:name => "Tetta", :sex => "F", )}
    let(:antonio) {TestModel.create!(:name => "Antonio", :sex => "M", )}
    let(:assunta) {TestModel.create!(:name => "Assunta", :sex => "F", )}
    let(:stefano) {TestModel.create!(:name => "Stefano", :sex => "M", )}

    context "when has no father and #add_paternal_grandfather(narduccio)" do
      specify { expect { corrado.add_paternal_grandfather(narduccio) }.to raise_error(Genealogy::LineageGapException)}
    end

    context "when has uccio and tetta as parents and stefano as sibling" do
      before(:each) do
        corrado.add_father(uccio)
        corrado.add_mother(tetta)
        corrado.add_siblings(stefano)
      end
      
      its(:father) {should == uccio}

      context "when #add_paternal_grandfather(narduccio)" do

        before(:each) { corrado.add_paternal_grandfather(narduccio) }
        its('reload.paternal_grandfather') {should == narduccio}
        
        describe "stefano" do
          subject {stefano}
          its('reload.paternal_grandfather') {should == narduccio}
        end
        
      end

      context "when add_paternal_grandfather(maria)" do
        specify { expect { corrado.add_paternal_grandfather(maria)}.to raise_error(Genealogy::WrongSexException) }
      end

      context "when add_paternal_grandfather(Object.new)" do
        specify { expect { corrado.add_paternal_grandfather(Object.new) }.to raise_error(Genealogy::IncompatibleObjectException) }
      end

      context "when add_paternal_grandfather(corrado)" do
        specify { expect { corrado.add_paternal_grandfather(corrado) }.to raise_error(Genealogy::IncompatibleRelationshipException) }
      end

      context "when #add_paternal_grandmother(maria)" do

        before(:each) { corrado.add_paternal_grandmother(maria) }
        its('reload.paternal_grandmother') {should == maria}

      end

      context "when add_paternal_grandmother(narduccio)" do
        specify { expect { corrado.add_paternal_grandmother(narduccio) }.to raise_error(Genealogy::WrongSexException) }
      end

      context "when has narduccio e maria as paternal grandparents" do
        before(:each) do
          corrado.add_paternal_grandfather(narduccio)
          corrado.add_paternal_grandmother(maria)
        end

        context "and #remove_parental_grandfather" do
          before(:each) do
            corrado.remove_paternal_grandfather
          end
          its('reload.paternal_grandmother') {should == maria}
          its('reload.paternal_grandfather') {should be_nil}

          describe "stefano" do
            subject {stefano}
            its('reload.paternal_grandmother') {should == maria}
            its('reload.paternal_grandfather') {should be_nil}
          end
        end

      end
    end

  end

end
