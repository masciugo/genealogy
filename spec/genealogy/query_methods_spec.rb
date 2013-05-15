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
      its(:paternal_grandfather) {should == narduccio}
      its(:paternal_grandmother) {should == maria}
      its(:maternal_grandfather) {should == antonio}
      its(:maternal_grandmother) {should == assunta}
      its(:grandparents) {should =~ [assunta,antonio,narduccio,maria]}
      its(:siblings) {pending}
      its(:offspring) {pending}
      its(:half_siblings) {pending}
      its(:descendants) {pending}
      its(:ancestors) {pending}
    end

    describe "stefano" do
      subject {stefano}
      its(:parents) {should =~ [tetta,uccio]}
      its(:paternal_grandfather) {should == narduccio}
      its(:paternal_grandmother) {should == maria}
      its(:maternal_grandfather) {should == antonio}
      its(:maternal_grandmother) {should == assunta}
      its(:siblings) {pending}
      its(:offspring) {pending}
      its(:half_siblings) {pending}
      its(:descendants) {pending}
      its(:ancestors) {pending}
    end


  end

end