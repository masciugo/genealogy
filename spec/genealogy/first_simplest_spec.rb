require 'spec_helper'

load_schema

module Genealogy
  describe "linking brand new simplest individuals" do
    
    let(:corrado) {SimplestIndividual.new(:name => "Corrado")}
    let(:uccio) {SimplestIndividual.new(:name => "Uccio")}
    let(:tetta) {SimplestIndividual.new(:name => "Tetta")}

    it "should have blank parents" do
      corrado.save!
      corrado.father.should be(nil)
      corrado.mother.should be(nil)
    end

    it "should have foo methods" do
      corrado.foo.should == 'InstanceMethods#foo'
      corrado.class.foo.should == 'ClassMethods#foo'
    end

    it "should have a father named Uccio" do
      corrado.add_father(:name => "Uccio")
      corrado.save!
      corrado.father.name.should == 'Uccio'
    end

    it "should have a mother named Tetta" do
      corrado.add_mother(:name => "Tetta")
      corrado.save!
      corrado.mother.name.should == 'Tetta'
    end

  end

  describe "linking existing simplest individuals" do

    let(:corrado) {SimplestIndividual.create!(:name => "Corrado")}
    let(:uccio) {SimplestIndividual.create!(:name => "Uccio")}
    let(:tetta) {SimplestIndividual.create!(:name => "Tetta")}

    it "corrado should have tetta as mother" do
      corrado.add_mother!(tetta)
      corrado.reload.mother.should === tetta
    end

    it "corrado should have uccio as father" do
      corrado.add_father!(uccio)
      debugger; sleep 0
      corrado.reload.father.should === uccio
    end
  end
end
