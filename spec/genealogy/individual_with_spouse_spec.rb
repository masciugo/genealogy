require 'spec_helper'
  
module Genealogy
  describe "model with spouse" do

    let!(:model){Genealogy.set_test_model(TestModel3,:spouse => true)}

    describe "creation" do

      let(:corrado) {model.new(:name => "Corrado")}

      it "should have blank spouse" do
        corrado.save!
        corrado.spouse.should be(nil)
      end

    end

    describe "spouse linking" do

      context "when all individuals are new_record" do

        let(:corrado) {model.new(:name => "Corrado")}
        let(:nicole) {model.new(:name => "Nicole")}

        describe "using bang method" do

          it "should have spouse named Nicole" do
            corrado.add_spouse!(:name => "Nicole")
            corrado.reload.spouse.name.should == 'Nicole'
          end

        end

        describe "using no-bang method " do

          it "should have spouse named Nicole" do
            corrado.add_spouse(:name => "Nicole")
            corrado.save!
            corrado.reload.spouse.name.should == 'Nicole'
          end

        end

      end

      context "when all individuals are existing" do

        let(:corrado) {model.create!(:name => "Corrado")}
        let(:nicole) {model.create!(:name => "Nicole")}

        describe "using bang method" do

          it "corrado should have nicole as spouse" do
            corrado.add_spouse!(nicole)
            corrado.reload.spouse.should == nicole
          end

        end

        describe "using no-bang method" do

          it "corrado should have nicole as spouse" do
            corrado.add_spouse(nicole)
            corrado.save!
            corrado.reload.spouse.should == nicole
          end

          it "corrado should not have nicole as spouse if it's not saved" do
            corrado.add_spouse(nicole)
            corrado.reload.spouse.should_not == nicole
          end


        end

      end

    end

  end
end
