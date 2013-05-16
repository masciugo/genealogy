require 'spec_helper'

module CinziaQueryMethodsSpec
  extend GenealogyTestModel
  
  describe "query methods", :cinzia => true  do

    before(:all) do
      CinziaQueryMethodsSpec.define_test_model_class({:spouse => true })
    end

    let!(:paolo) {TestModel.create!(:name => "Paolo Lodovico", :sex => "M", :father_id => pietro.id, :mother_id => teresa.id)}
    let!(:antonietta) {TestModel.create!(:name => "Antonietta", :sex => "F", :father_id => pasquale.id, :mother_id => irene.id)}
    let!(:benito) {TestModel.create!(:name => "Benito Pietro Pasquale", :sex => "M", :father_id => paolo.id, :mother_id => antonietta.id)}
    let!(:annamaria) {TestModel.create!(:name => "Annamaria", :sex => "F", :father_id => paolo.id, :mother_id => barbara.id)}
    let!(:barbara) {TestModel.create!(:name => "Barbara", :sex => "F", :father_id => giovanni.id, :mother_id => margherita.id)}
    let!(:pasquale) {TestModel.create!(:name => "Pasquale Antonio", :sex => "M", :father_id => gianbattista.id, :mother_id => luigia.id)}
    let!(:irene) {TestModel.create!(:name => "Irene Silvia Alfonsina", :sex => "F", :father_id => tommaso.id, :mother_id => celestina.id)}
    let!(:pietro) {TestModel.create!(:name => "Pietro", :sex => "M")}
    let!(:teresa) {TestModel.create!(:name => "Teresa", :sex => "F")}
    let!(:giovanni) {TestModel.create!(:name => "Giovanni", :sex => "M")}
    let!(:margherita) {TestModel.create!(:name => "Margherita", :sex => "F")}
    let!(:celestina) {TestModel.create!(:name => "Celestina", :sex => "F", :father_id => luigi.id, :mother_id => marina.id)}
    let!(:tommaso) {TestModel.create!(:name => "Tommaso", :sex => "M", :father_id => gianbattista.id, :mother_id => luigia.id)}
    let!(:luigi) {TestModel.create!(:name => "Luigi Stefano Antonio", :sex => "M")}
    let!(:marina) {TestModel.create!(:name => "Marina", :sex => "F")}
    let!(:gianbattista) {TestModel.create!(:name => "Gianbattista", :sex => "M")}
    let!(:luigia) {TestModel.create!(:name => "Luigia", :sex => "F")}

    describe "benito" do
      subject {benito}
      its(:parents) {should =~ [paolo,antonietta]}
      its(:paternal_grandfather) {should == pietro}
      its(:paternal_grandmother) {should == teresa}
      its(:maternal_grandfather) {should == pasquale}
      its(:maternal_grandmother) {should == irene}
      its(:grandparents) {should =~ [pietro,teresa,pasquale,irene]}
      its(:siblings) {should =~ []}
      its(:paternal_grandparents) {should =~ [pietro,tresa]}
      its(:maternal_grandparents) {should =~ [pasquale,irene]}
      its(:half_siblings) {should =~ [annamaria]}
      its(:ancestors) {should =~ [paolo,antonietta,pietro,teresa,pasquale,irene,tommaso,celestina,gianbattista,luigia,luigi,marina]}
    end

    describe "annamaria" do
      subject {annamaria}
      its(:parents) {should =~ [paolo,barbara]}
      its(:paternal_grandfather) {should == pietro}
      its(:paternal_grandmother) {should == teresa}
      its(:maternal_grandfather) {should == giovanni}
      its(:maternal_grandmother) {should == margherita}
      its(:paternal_grandparents) {should =~ [pietro,tresa]}
      its(:maternal_grandparents) {should =~ [giovanni,margherita]}
      its(:half_siblings) {should == [benito]}
      its(:descendants) {should == []}
      its(:ancestors) {should =~ [paolo,barbara,pietro,teresa,giovanni,margherita]}
    end

    describe "paolo" do
      subject {paolo}
      its(:parents) {should =~ [pietro,teresa]}
      its(:offspring) {should =~ [benito,annamaria]}
      its(:descendants) {should =~ [benito,annamaria]}
      its(:ancestors) {should =~ [pietro,teresa]}
    end

    describe "barbara" do
      subject {barbara}
      its(:offspring) {should =~ [annamaria]}
      its(:descendants) {should =~ [annamaria]}
    end
    
    describe "pasquale" do
      subject {pasquale}
      its(:offspring) {should =~ [antonietta]}
      its(:descendants) {should =~ [antonietta,benito]}
      its(:descendants) {should_not =~ [annamaria]}
      its(:siblings) {should =~ [tommaso]}
    end

    describe "luigia" do
      subject {luigia}
      its(:offspring) {should =~ [tommaso,pasquale]}
      its(:descendants) {should =~ [tommaso,pasquale,irene,antonietta,benito]}
      its(:descendants) {should_not =~ [annamaria]}
      its(:ancestors) {should =~ []}
      its(:offspring) {should_not =~ [irene]}
    end

  end

end