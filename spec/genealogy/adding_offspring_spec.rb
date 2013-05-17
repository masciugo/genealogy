require 'spec_helper'

module AddingOffspringSpec
  extend GenealogyTestModel

  describe "tetta"  do
    subject { tetta }
      
    before(:all) do
      AddingOffspringSpec.define_test_model_class({})
    end

    let(:tetta) {TestModel.create!(:name => "Tetta", :sex => "F")}
    let(:corrado) {TestModel.create!(:name => "Corrado", :sex => "M")}
    let(:stefano) {TestModel.create!(:name => "Stefano", :sex => "M")}
    let(:walter) {TestModel.create!(:name => "Walter", :sex => "M")}
    let(:ciccio) {TestModel.create!(:name => "Ciccio", :sex => "M")}
    let(:uccio) {TestModel.create!(:name => "Uccio", :sex => "M")}
    let(:dylan) {TestModel.create!(:name => "Dylan", :sex => "M")}
    let(:gina) {TestModel.create!(:name => "Gina", :sex => "F")}

    describe "adding offspring" do
      
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
          before(:each) { stefano.mark_invalid! }
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
        before(:each) { tetta.add_offspring(corrado, :with => luigi) }
        its(:offspring) { should =~ [corrado] }
        describe "luigi" do
          subject { luigi }
          its(:offspring) { should =~ [corrado] }
        end
      end

      context "when trying to add_offspring to a female specifying mother #add_offspring(corrado, :mother => gina)" do
        let(:gina) {TestModel.create!(:name => "Gina", :sex => "F")}
        specify { expect { tetta.add_offspring(corrado, :with => gina) }.to raise_error(Genealogy::WrongSexException) }
      end

    end

    describe "removing offspring" do
      before(:each) do
        tetta.add_offspring(corrado,stefano, :with => uccio)
        tetta.add_offspring(walter, :with => ciccio)
        tetta.add_offspring(dylan)
      end

      describe "tetta.remove_offspring result" do
        specify { tetta.remove_offspring.should be_true }
      end

      context "when tetta.remove_offspring" do
        before(:each) { tetta.remove_offspring }
        its(:offspring) { should be_empty }
        describe "uccio" do
          subject {uccio}
          its(:offspring) { should =~ [stefano,corrado] }
        end
      end

      context "when tetta.remove_offspring but stefano is invalid" do
        before(:each) { stefano.mark_invalid! }
        specify { expect { tetta.remove_offspring }.to raise_error }
        its(:offspring) do
          tetta.remove_offspring rescue true
          should =~ [stefano,corrado,walter,dylan]
        end
      end

      context "when tetta.remove_offspring(:with => uccio)" do
        before(:each) { tetta.remove_offspring(:with => uccio) }
        its(:offspring) {should =~ [walter,dylan]}
        describe "uccio" do
          subject {uccio}
          its(:offspring) { should =~ [stefano,corrado] }
        end
      end

      context "when tetta.remove_offspring(:with => gina)" do
        specify { expect { tetta.remove_offspring(:with => gina) }.to raise_error(Genealogy::WrongSexException) }
      end

      context "when tetta.remove_offspring(:with => uccio, :affect_with => true)" do
        before(:each) { tetta.remove_offspring(:with => uccio, :affect_with => true) }
        its(:offspring) {should_not include stefano,corrado}
        describe "uccio" do
          subject {uccio}
          its(:offspring) { should_not include stefano,corrado }
        end
      end

      context "when tetta.remove_offspring(:affect_with => true)" do
        before(:each) { tetta.remove_offspring(:affect_with => true) }
        its(:offspring) {should_not include stefano,corrado}
        describe "uccio" do
          subject {uccio}
          its(:offspring) { should include stefano,corrado }
        end
      end

      context "when tetta.remove_offspring(:with => walter)" do
        its(:offspring) do
          tetta.remove_offspring(:with => walter)
          should =~ [stefano,corrado,walter,dylan]
        end
        describe "result" do
          specify { tetta.remove_offspring(:with => walter).should be_false }
        end
      end

    end
  end
end