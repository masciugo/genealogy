require 'spec_helper'
  
module Genealogy
  describe "model without spouse" do

    let!(:model){Genealogy.set_test_model(TestModel2)}
    
    describe "creation" do 

      let(:corrado) {model.new(:name => "Corrado")}

      it "should have blank parents" do
        corrado.save!
        corrado.father.should be(nil)
        corrado.mother.should be(nil)
      end

    end

    describe "parents linking" do

      context "when all individuals are new_record" do

        let(:corrado) {model.new(:name => "Corrado")}
        let(:uccio) {model.new(:name => "Uccio")}
        let(:tetta) {model.new(:name => "Tetta")}

        describe "using bang method" do

          it "should have a father named Uccio" do
            corrado.add_father!(:name => "Uccio")
            corrado.father.name.should == 'Uccio'
          end

          it "should have a mother named Tetta" do
            corrado.add_mother!(:name => "Tetta")
            corrado.mother.name.should == 'Tetta'
          end

        end

        describe "using no-bang method " do

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

      end

      context "when all individuals are existing" do

        let(:corrado) {model.create!(:name => "Corrado")}
        let(:uccio) {model.create!(:name => "Uccio")}
        let(:tetta) {model.create!(:name => "Tetta")}

        describe "using bang method" do

          it "corrado should have tetta as mother" do
            corrado.add_mother!(tetta)
            corrado.reload.mother.should == tetta
          end

          it "corrado should have uccio as father" do
            corrado.add_father!(uccio)
            corrado.reload.father.should == uccio
          end

        end

        describe "using no-bang method" do

          it "corrado should have tetta as mother" do
            corrado.add_mother(tetta)
            corrado.save!
            corrado.reload.mother.should == tetta
          end

          it "corrado should have uccio as father" do
            corrado.add_father(uccio)
            corrado.save!
            corrado.reload.father.should == uccio
          end

          it "corrado should not have tetta as mother if it's not saved" do
            corrado.add_mother(tetta)
            corrado.reload.mother.should_not == tetta
          end


        end

      end

    end

    describe "grandparents linking" do
      let(:corrado) {model.create!(:name => "Corrado")}
      let(:uccio) {model.create!(:name => "Uccio")}
      let(:narduccio) {model.create!(:name => "Narduccio")}
      let(:maria) {model.create!(:name => "Maria")}
      let(:tetta) {model.create!(:name => "Tetta")}
      let(:antonio) {model.create!(:name => "Antonio")}
      let(:assunta) {model.create!(:name => "Assunta")}

      describe "paternal lineage" do
        context "when all individuals are existing" do
          before(:each) do
            corrado.add_father!(uccio)
          end

          context "using bang method" do
            it "should have maria as paternal grandmother" do
              corrado.add_paternal_grandmother!(maria)
              corrado.reload.paternal_grandmother.should == maria
            end
            it "should have narduccio as paternal grandfather" do
              corrado.add_paternal_grandfather!(narduccio)
              corrado.reload.paternal_grandfather.should == narduccio
            end
          end
        end
      end

      describe "maternal lineage" do
        context "when all individuals are existing" do

          before(:each) do
            corrado.add_mother!(tetta)
          end

          context "using bang method" do
            it "should have assunta as maternal grandmother" do
              corrado.add_maternal_grandmother!(assunta)
              corrado.reload.maternal_grandmother.should == assunta
            end
            it "should have antonio as maternal grandfather" do
              corrado.add_maternal_grandfather!(antonio)
              corrado.reload.maternal_grandfather.should == antonio
            end
          end
        end
      end

    end

  end
end
