require 'spec_helper'

module AlterOffspringSpec
  extend GenealogyTestModel

  describe "offspring methods applied to tetta: "  do
    subject { tetta }
      
    before(:all) do
      AlterOffspringSpec.define_test_model_class({})
    end

    let(:tetta) {TestModel.create!(:name => "Tetta", :sex => "F")}
    let(:corrado) {TestModel.create!(:name => "Corrado", :sex => "M")}
    let(:stefano) {TestModel.create!(:name => "Stefano", :sex => "M")}
    let(:walter) {TestModel.create!(:name => "Walter", :sex => "M")}
    let(:ciccio) {TestModel.create!(:name => "Ciccio", :sex => "M")}
    let(:uccio) {TestModel.create!(:name => "Uccio", :sex => "M")}
    let(:dylan) {TestModel.create!(:name => "Dylan", :sex => "M")}
    let(:gina) {TestModel.create!(:name => "Gina", :sex => "F")}

    describe "#add_offspring(corrado)" do
      
      context "when all is ok" do
        before(:each) { tetta.add_offspring(corrado) }
        its(:offspring) { should =~ [corrado] }
        describe "corrado" do
          subject { corrado.reload }
          its('mother') { should == tetta }
          its('father') { should be_nil }
        end
      end

      context "when corrado is an ancestor" do
        before(:each) { tetta.add_father(corrado) }
        specify { expect { tetta.add_offspring(corrado) }.to raise_error(Genealogy::IncompatibleRelationshipException)}
      end

      context "when tetta has undefined sex" do
        before(:each) { tetta.sex = nil }
        specify { expect { tetta.add_offspring(corrado) }.to raise_error(Genealogy::WrongSexException) }
      end

    end
    
    describe "#add_offspring(corrado,stefano)" do
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
        before(:each) { stefano.mark_invalid! }
        specify { expect { tetta.add_offspring(corrado,stefano) }.to raise_error }
        its(:offspring) do
          tetta.add_offspring(corrado,stefano) rescue true
          should be_empty
        end
      end

    end

    describe "#add_offspring(corrado, :spouse => luigi)" do
      let(:luigi) {TestModel.create!(:name => "Luigi", :sex => "M")}
      before(:each) { tetta.add_offspring(corrado, :spouse => luigi) }
      its(:offspring) { should =~ [corrado] }
      describe "luigi" do
        subject { luigi }
        its(:offspring) { should =~ [corrado] }
      end
    end

    context "when trying to add_offspring to a female specifying a female spouse" do
      let(:gina) {TestModel.create!(:name => "Gina", :sex => "F")}
      describe "#add_offspring(corrado, :spouse => gina)" do
        specify { expect { tetta.add_offspring(corrado, :spouse => gina) }.to raise_error(Genealogy::WrongSexException) }
      end
    end

    context "when already has two children with uccio (stefano and corrado) and one with ciccio (walter) and a last one with an unknown spouse (dylan)" do
      before(:each) do
        tetta.add_offspring(corrado,stefano, :spouse => uccio)
        tetta.add_offspring(walter, :spouse => ciccio)
        tetta.add_offspring(dylan)
      end

      describe "#remove_offspring returned value" do
        specify { tetta.remove_offspring.should be_true }
      end

      describe "#remove_offspring" do
        context "when offspring are all valid" do
          before(:each) { tetta.remove_offspring }
          its(:offspring) { should be_empty }
          describe "uccio" do
            subject {uccio}
            its(:offspring) { should =~ [stefano,corrado] }
          end
        end
        context "stefano is invalid" do
          before(:each) { stefano.mark_invalid! }
          specify { expect { tetta.remove_offspring }.to raise_error }
          its(:offspring) do
            tetta.remove_offspring rescue true
            should =~ [stefano,corrado,walter,dylan]
          end
        end
      end

      describe "#remove_offspring(:affect_spouse => true)" do
        before(:each) { tetta.remove_offspring(:affect_spouse => true) }
        its(:offspring) {should_not include stefano,corrado}
        describe "uccio" do
          subject {uccio}
          its(:offspring) { should_not include stefano,corrado }
        end
        describe "ciccio" do
          subject {ciccio}
          its(:offspring) { should_not include walter }
        end
      end

      describe "#remove_offspring(:spouse => uccio)" do
        before(:each) { tetta.remove_offspring(:spouse => uccio) }
        its(:offspring) {should_not include stefano,corrado}
        describe "uccio" do
          subject {uccio}
          its(:offspring) { should include stefano,corrado }
        end
      end

      describe "#remove_offspring(:spouse => uccio, :affect_spouse => true)" do
        before(:each) { tetta.remove_offspring(:spouse => uccio, :affect_spouse => true) }
        its(:offspring) {should_not include stefano,corrado}
        describe "uccio" do
          subject {uccio}
          its(:offspring) { should_not include stefano,corrado }
        end
      end

      describe "#remove_offspring(:spouse => walter)" do
        its(:offspring) do
          tetta.remove_offspring(:spouse => walter)
          should =~ [stefano,corrado,walter,dylan]
        end
        describe "result" do
          specify { tetta.remove_offspring(:spouse => walter).should be_false }
        end
      end

      context "when specify a spouse with the same sex" do
        describe "#remove_offspring(:spouse => gina)" do
          specify { expect { tetta.remove_offspring(:spouse => gina) }.to raise_error(Genealogy::WrongSexException) }
        end
      end


    end
  end
end