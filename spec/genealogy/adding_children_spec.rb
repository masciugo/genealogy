require 'spec_helper'

module AddingChildrenSpec
  extend GenealogyTestModel

  describe "adding children" do

    before(:all) do
      AddingChildrenSpec.define_test_model_class({})
    end

    let(:tetta) {TestModel.create!(:name => "Tetta", :sex => "F")}
    let(:corrado) {TestModel.create!(:name => "Corrado", :sex => "M")}
    
    describe "tetta" do
      subject { tetta }
      
      context "when #add_offspring(corrado)" do
        before(:each) { tetta.add_offspring(corrado) }
        its(:offspring) { should =~ [corrado] }
        describe "corrado" do
          subject { corrado.reload }
          its('mother') { should == tetta }
          its('father') { should be_nil }
        end
      end
      
      context "when #add_offspring(corrado,stefano)" do
        let(:stefano) {TestModel.create!(:name => "Stefano", :sex => "M")}
        
        context "when corrado and stefano are valid" do
          before(:each) { tetta.add_offspring(corrado,stefano) }
          its(:offspring) { should =~ [corrado,stefano] }
          describe "corrado" do
            subject { corrado }
            its(:mother) { should be(tetta) }
            its(:father) { should be_nil }
          end
          describe "stefano" do
            subject { stefano }
            its(:mother) { should be(tetta) }
            its(:father) { should be_nil }
          end
        end

        context "when stefano is invalid" do
          before(:each) { stefano.always_fail! }
          specify { expect { tetta.add_offspring(corrado,stefano) }.to raise_error }
          its(:offspring) do
            tetta.add_offspring(corrado,stefano) rescue true
            should be_empty
          end
        end

      end

      context "when #add_offspring(antonio) and antonio is an ancestor" do
        let(:antonio) {TestModel.create!(:name => "Antonio", :sex => "M")}
        before(:each) { tetta.add_father(antonio) }
        specify { expect { tetta.add_offspring(antonio) }.to raise_error(Genealogy::IncompatibleRelationshipException)}
      end

      context "when #add_offspring(corrado) but tetta has undefined sex" do
        before(:each) { tetta.sex = nil }
        specify { expect { tetta.add_offspring(corrado) }.to raise_error(Genealogy::WrongSexException) }
      end

      context "when #add_offspring(corrado, :father => luigi)" do
        let(:luigi) {TestModel.create!(:name => "Luigi", :sex => "M")}
        before(:each) { tetta.add_offspring(corrado, :father => luigi) }
        its(:offspring) { should =~ [corrado] }
        describe "luigi" do
          subject { luigi }
          its(:offspring) { should =~ [corrado] }
        end
      end

      context "when trying to add_offspring to a female specifying mother #add_offspring(corrado, :mother => gina)" do
        let(:gina) {TestModel.create!(:name => "Gina", :sex => "F")}
        specify { expect { tetta.add_offspring(corrado, :mother => gina) }.to raise_error(Genealogy::OptionException) }
      end


    end
  end
end