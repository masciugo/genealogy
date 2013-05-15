require 'spec_helper'

module AddingChildrenSpec
  extend GenealogyTestModel

  describe "adding children" do

    before(:all) do
      AddingChildrenSpec.define_test_model_class({})
    end

    let(:uccio) {TestModel.create!(:name => "Uccio", :sex => "M")}
    let(:tetta) {TestModel.create!(:name => "Tetta", :sex => "F")}
    let(:corrado) {TestModel.create!(:name => "Corrado", :sex => "M")}
    let(:stefano) {TestModel.create!(:name => "Stefano", :sex => "M")}
    
    describe "tetta", :wip => true do
      subject { tetta }
      
      context "when #add_children(corrado)" do
        before(:each) { tetta.add_children(corrado) }
        describe "corrado" do
          subject { corrado }
          context "when is saved" do
            before(:each) { corrado.save! }
            its('reload.mother') { should ==(tetta) }
          end
        end
      end
      
      context "when #add_children([corrado,stefano])" do
        before(:each) { tetta.add_children([corrado,stefano]) }
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
    end
  end
end