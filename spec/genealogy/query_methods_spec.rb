require 'spec_helper'

module QueryMethodsSpec
  extend GenealogyTestModel
  
  describe "query methods" do

    before(:all) do
      QueryMethodsSpec.define_test_model_class({:spouse => true })
    end

    let(:uccio) {TestModel.create!(:name => "Uccio", :sex => "M", )}
    let(:narduccio) {TestModel.create!(:name => "Narduccio", :sex => "M", )}
    let(:maria) {TestModel.create!(:name => "Maria", :sex => "F", )}
    let(:tetta) {TestModel.create!(:name => "Tetta", :sex => "F", )}
    let(:antonio) {TestModel.create!(:name => "Antonio", :sex => "M", )}
    let(:assunta) {TestModel.create!(:name => "Assunta", :sex => "F", )}
    let(:gina) {TestModel.create!(:name => "Gina", :sex => "F")}
    let(:stefano) {TestModel.create!(:name => "Stefano", :sex => "M")}
    let(:corrado) {TestModel.create!(:name => "Corrado", :sex => "M")}
    let(:walter) {TestModel.create!(:name => "Walter", :sex => "M")}
    let(:manu) {TestModel.create!(:name => "Manu", :sex => "F")}
    let(:alessandro) {TestModel.create!(:name => "Alessandro", :sex => "M")}

    before(:each) do
      corrado.add_father!(uccio)
      corrado.add_mother!(tetta)
      corrado.add_siblings!([stefano])
      walter.add_father!(uccio)
      walter.add_mother!(gina)
      corrado.add_paternal_grandfather!(narduccio)
      corrado.add_paternal_grandmother!(maria)
      corrado.add_maternal_grandfather!(antonio)
      corrado.add_maternal_grandmother!(assunta)
      alessandro.add_father!(stefano)
      alessandro.add_mother!(manu)
    end

    describe "parents" do
      subject {corrado.parents}
      specify { should include tetta,uccio }
    end

    describe "offspring" do

      describe "tetta #offspring" do
        subject {tetta.offspring}
        specify { should include corrado,stefano }
        specify { should_not include walter }
      end

      describe "uccio #offspring" do
        subject {uccio.offspring}
        specify { should include corrado,stefano,walter }
      end

      describe "gina #offspring" do
        subject {gina.offspring}
        specify { should include walter }
        specify { should_not include corrado,stefano }
      end

    end

    describe "siblings" do

      describe "corrado #siblings" do
        subject { corrado.siblings }
        specify { should include stefano }
        specify { should_not include walter,corrado }
      end

      describe "walter #siblings" do
        subject { walter.siblings }
        specify { should be_empty }
      end

      describe "corrado #half_siblings" do
        subject {corrado.half_siblings}
        specify { should include walter }
        specify { should_not include stefano }
      end

      describe "dylan (whose both parents are nil) siblings" do
        subject { narduccio.siblings }
        specify { should be_nil }
      end

    end


    describe "descendants" do

      describe "uccio#descendants" do
        subject { uccio.descendants }
        specify { should include corrado,stefano,alessandro }
      end

    end

    describe "ancestors", :wip => true do

      describe "alessandro#ancestors" do
        subject { alessandro.ancestors }
        specify { should include stefano,manu,uccio,narduccio,maria,tetta,antonio,assunta }
      end
      describe "corrado#ancestors" do
        subject { alessandro.ancestors }
        specify { should include uccio,narduccio,maria,tetta }
      end
      describe "narduccio#ancestors" do
        subject { narduccio.ancestors }
        specify { should be_empty }
      end
    end
  end

end