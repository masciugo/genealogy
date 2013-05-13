require 'spec_helper'

module AddingSpouseSpec
  extend GenealogyTestModel
  
  describe "adding spouse" do

    before(:all) do
      AddingSpouseSpec.define_test_model_class({:spouse => true})
    end

    subject {TestModel.create!(:name => "Corrado", :sex => "M")}
    let(:nicole) {TestModel.create!(:name => "Nicole", :sex => "F")}
    let(:karcio) {TestModel.create!(:name => "Karcio", :sex => "M")}

    describe "#add_spouse! (bang method)" do

      it "has nicole as spouse" do
        subject.add_spouse!(nicole)
        subject.reload.spouse.should == nicole
      end

      it "nicole has subject as spouse" do
        subject.add_spouse!(nicole)
        nicole.reload.spouse.should == subject
      end

      it "raises an WrongSexException when adding a spouse with same sex" do
        expect { subject.add_spouse!(karcio) }.to raise_error(Genealogy::WrongSexException)
      end

      context "when something goes wrong during adding" do
        it "has no spouse" do
          subject.always_fail_validation = true
          expect { subject.add_spouse!(nicole) }.to raise_error and 
          subject.reload.spouse.should be(nil) and 
          nicole.reload.spouse.should be(nil)
        end
      end

    end

    describe "#add_spouse (no bang method)" do

      context "without saving" do
        it "has no spouse" do
          subject.add_spouse(nicole)
          subject.reload.spouse.should be(nil)
        end
      end

      context "with saving" do
        it "has nicole as spouse" do
          subject.add_spouse(nicole)
          subject.save!
          subject.reload.spouse.should == nicole
        end
      end

    end

    describe "remove_spouse methods" do

      before(:each) do
        subject.add_spouse!(nicole)
      end

      describe "#remove_spouse" do
        context "without saving" do
          it "has still nicole as spouse" do
            subject.remove_spouse
            subject.reload.spouse.should == nicole
          end
        end
        context "with saving" do
          it "has no spouse" do
            subject.remove_spouse
            subject.save!
            subject.reload.spouse.should be(nil)
          end
        end
      end
      describe "#remove_spouse!" do
        it "has no spouse" do
          subject.remove_spouse!
          subject.reload.spouse.should be(nil)
        end
        context "when something goes wrong during removeing" do
          it "has still nicole as spouse" do
            subject.always_fail_validation = true
            expect { subject.remove_spouse! }.to raise_error and 
            subject.reload.spouse.should == nicole and 
            nicole.reload.spouse.should == subject
          end
        end
      end

    end

  end

end