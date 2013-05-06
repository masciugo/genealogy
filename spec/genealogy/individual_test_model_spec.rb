require 'spec_helper'

load_schema

module Genealogy
  describe Individual do
    describe "creation" do
      before(:all) do
        reset_individual_class
        Individual.has_parents :spouse => true
        Individual.table_name = "individuals_with_spouse"
      end

      let(:corrado) {Individual.new(:name => "Corrado")}

      it "should have blank parents and spouse" do
        corrado.save!
        corrado.father.should be(nil)
        corrado.mother.should be(nil)
        corrado.spouse.should be(nil)
      end

      it "should have foo methods" do
        corrado.foo.should == 'InstanceMethods#foo'
        corrado.class.foo.should == 'ClassMethods#foo'
      end

    end

    describe "parents and spouse linking" do

      before(:all) do
        reset_individual_class
        Individual.has_parents :spouse => true
        Individual.table_name = "individuals_with_spouse"
      end    

      context "when all individuals are new_record" do

        let(:corrado) {Individual.new(:name => "Corrado")}
        let(:uccio) {Individual.new(:name => "Uccio")}
        let(:tetta) {Individual.new(:name => "Tetta")}
        let(:nicole) {Individual.new(:name => "Nicole")}

        describe "using bang method" do

          it "should have a father named Uccio" do
            corrado.add_father!(:name => "Uccio")
            corrado.reload.father.name.should == 'Uccio'
          end

          it "should have a mother named Tetta" do
            corrado.add_mother!(:name => "Tetta")
            corrado.reload.mother.name.should == 'Tetta'
          end

          it "should have spouse named Nicole" do
            corrado.add_spouse!(:name => "Nicole")
            corrado.reload.spouse.name.should == 'Nicole'
          end

        end

        describe "using no-bang method " do

          it "should have a father named Uccio" do
            corrado.add_father(:name => "Uccio")
            corrado.save!
            corrado.reload.father.name.should == 'Uccio'
          end

          it "should have a mother named Tetta" do
            corrado.add_mother(:name => "Tetta")
            corrado.save!
            corrado.reload.mother.name.should == 'Tetta'
          end

          it "should have spouse named Nicole" do
            corrado.add_spouse(:name => "Nicole")
            corrado.save!
            corrado.reload.spouse.name.should == 'Nicole'
          end

        end

      end

      context "when all individuals are existing" do

        let(:corrado) {Individual.create!(:name => "Corrado")}
        let(:uccio) {Individual.create!(:name => "Uccio")}
        let(:tetta) {Individual.create!(:name => "Tetta")}
        let(:nicole) {Individual.create!(:name => "Nicole")}

        describe "using bang method" do

          it "corrado should have tetta as mother" do
            corrado.add_mother!(tetta)
            corrado.reload.mother.should === tetta
          end

          it "corrado should have uccio as father" do
            corrado.add_father!(uccio)
            corrado.reload.father.should === uccio
          end

          it "corrado should have nicole as spouse" do
            corrado.add_spouse!(nicole)
            corrado.reload.spouse.should === nicole
          end

        end

        describe "using no-bang method" do

          it "corrado should have tetta as mother" do
            corrado.add_mother(tetta)
            corrado.save!
            corrado.reload.mother.should === tetta
          end

          it "corrado should have uccio as father" do
            corrado.add_father(uccio)
            corrado.save!
            corrado.reload.father.should === uccio
          end

          it "corrado should have nicole as spouse" do
            corrado.add_spouse(nicole)
            corrado.save!
            corrado.reload.spouse.should === nicole
          end

          it "corrado should not have tetta as mother if it's not saved" do
            corrado.add_mother(tetta)
            corrado.reload.mother.should_not === tetta
          end


        end

      end

    end

    describe "grandparents linking" do
      let(:corrado) {Individual.create!(:name => "Corrado")}
      let(:uccio) {Individual.create!(:name => "Uccio")}
      let(:narduccio) {Individual.create!(:name => "Narduccio")}
      let(:maria) {Individual.create!(:name => "Maria")}
      let(:tetta) {Individual.create!(:name => "Tetta")}
      let(:antonio) {Individual.create!(:name => "Antonio")}
      let(:assunta) {Individual.create!(:name => "Assunta")}


      describe "paternal" do
        context "when all individuals are existing" do
          before(:each) do
            corrado.add_father!(uccio)
          end

          context "using bang method" do
            it "should have maria as paternal grandmother" do
              corrado.add_paternal_grandmother!(maria)
              corrado.reload.paternal_grandmother.should === maria
            end
            it "should have narduccio as paternal grandfather" do
              corrado.add_paternal_grandfather!(narduccio)
              corrado.reload.paternal_grandfather.should === narduccio
            end
          end
        end
      end

      describe "maternal" do
        context "when all individuals are existing" do

          before(:each) do
            corrado.add_mother!(tetta)
          end

          context "using bang method" do
            it "should have assunta as maternal grandmother" do
              corrado.add_maternal_grandmother!(assunta)
              corrado.reload.maternal_grandmother.should === assunta
            end
            it "should have antonio as maternal grandfather" do
              corrado.add_maternal_grandfather!(antonio)
              corrado.reload.maternal_grandfather.should === antonio
            end
          end
        end
      end

    end
  end
end
