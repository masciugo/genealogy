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
      corrado.add_father(uccio)
      corrado.add_mother(tetta)
      corrado.add_siblings([stefano])
      walter.add_father(uccio)
      walter.add_mother(gina)
      corrado.add_paternal_grandfather(narduccio)
      corrado.add_paternal_grandmother(maria)
      corrado.add_maternal_grandfather(antonio)
      corrado.add_maternal_grandmother(assunta)
      alessandro.add_father(stefano)
      alessandro.add_mother(manu)
    end

    describe "corrado" do
      subject {corrado}
      its(:parents) {should =~ [tetta,uccio]}
      its(:siblings) {pending}
    end

    describe "offspring" do

      describe "tetta #offspring" do
        subject {tetta.offspring}
        specify { should =~ [corrado,stefano] }
        specify { should_not include walter }
      end

      describe "uccio #offspring" do
        subject {uccio.offspring}
        specify { should =~ [corrado,stefano,walter] }
      end

      describe "gina #offspring" do
        subject {gina.offspring}
        specify { should =~ [walter] }
        specify { should_not include corrado,stefano }
      end

    end

    describe "siblings" do

      describe "corrado #siblings" do
        subject { corrado.siblings }
        specify { should =~ [stefano] }
        specify { should_not include walter,corrado }
      end

      describe "walter #siblings" do
        subject { walter.siblings }
        specify { should be_empty }
      end

      describe "corrado #half_siblings" do
        subject {corrado.half_siblings}
        specify { should =~ [walter] }
        specify { should_not include stefano }
      end

      describe "dylan (whose both parents are nil) siblings" do
        subject { narduccio.siblings }
        specify { should be_nil }
      end

    end

    describe "descendants" do

      { :uccio => [:corrado, :stefano, :alessandro, :walter], 
        :stefano => [:alessandro], 
        :antonio => [:tetta,:corrado,:stefano,:alessandro] 
      }.each do |origin,descendants|
        describe "#{origin}#descendants" do
          subject { eval(origin.to_s).descendants }
          specify { should =~ descendants.map{|d| eval(d.to_s)} }
        end

      end

    end

    describe "ancestors" do

      { :alessandro => [:stefano,:manu,:uccio,:narduccio,:maria,:tetta,:antonio,:assunta], 
        :corrado => [:uccio,:narduccio,:maria,:tetta,:antonio,:assunta],
        :narduccio => [] 
      }.each do |origin,ancestors|
        describe "#{origin}#ancestors" do
          subject { eval(origin.to_s).ancestors }
          specify { should =~ ancestors.map{|d| eval(d.to_s)} }
        end
      end

    end
  end

end