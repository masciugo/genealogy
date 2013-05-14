require 'spec_helper'

module AddingParentsSpec
  extend GenealogyTestModel
  
  describe "adding father" do

    before(:all) do
      AddingParentsSpec.define_test_model_class({})
    end

    subject {TestModel.create!(:name => "Corrado", :sex => "M")}
    let(:uccio) {TestModel.create!(:name => "Uccio", :sex => "M")}

    describe "#add_father! (bang method)" do

      it "has uccio as father" do
        subject.add_father!(uccio)
        subject.reload
        subject.father.should == uccio
      end

      it "raises an IncompatibleObjectException when adding other class objects" do
        expect { subject.add_father!(Object.new) }.to raise_error(Genealogy::IncompatibleObjectException)
      end

      it "raises an IncompatibleRelationshipException when adding himself as father" do
        expect { subject.add_father!(subject) }.to raise_error(Genealogy::IncompatibleRelationshipException)
      end

      let(:tetta) {TestModel.create!(:name => "tetta", :sex => "F")}

      it "raises a WrongSexException when adding a female as father" do
        expect { subject.add_father!(tetta) }.to raise_error(Genealogy::WrongSexException)
      end

    end


    describe '#add_father (no bang method)' do

      context "without saving" do
        it "has no father" do
          subject.add_father(uccio)
          subject.reload.father.should be(nil)
        end
      end

      context "with saving" do
        it "has uccio as father" do
          subject.add_father(uccio)
          subject.save!
          subject.reload.father.should == uccio
        end
      end

    end

    describe "remove methods" do
      
      before(:each) do
        subject.add_father!(uccio)
      end

      describe "#remove_father! (bang method)" do

        it "has no father" do
          subject.remove_father!
          subject.reload.father.should be_nil
        end

      end


      describe '#remove_father (no bang method)' do

        context "without saving" do
          it "has uccio as father" do
            subject.remove_father
            subject.reload.father.should == uccio
          end
        end

        context "with saving" do
          it "has no father" do
            subject.remove_father
            subject.save!
            subject.reload.father.should be_nil
          end
        end

      end

    end

  end

end