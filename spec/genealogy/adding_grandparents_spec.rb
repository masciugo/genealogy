require 'spec_helper'

module AddingGrandparentsSpec
  extend GenealogyTestModel

  describe "add grandparents methods" do
    
    before(:all) do
      AddingGrandparentsSpec.define_test_model_class({})
    end

    subject {TestModel.create!(:name => "Corrado", :sex => "M")}
    
    let(:uccio) {TestModel.create!(:name => "Uccio", :sex => "M", )}
    let(:narduccio) {TestModel.create!(:name => "Narduccio", :sex => "M", )}
    let(:maria) {TestModel.create!(:name => "Maria", :sex => "F", )}
    let(:tetta) {TestModel.create!(:name => "Tetta", :sex => "F", )}
    let(:antonio) {TestModel.create!(:name => "Antonio", :sex => "M", )}
    let(:assunta) {TestModel.create!(:name => "Assunta", :sex => "F", )}

    describe "paternal lineage" do

      before(:each) do
        subject.add_father!(uccio)
      end

      describe '#add_paternal_grandfather!' do
        it "has narduccio as paternal grandfather" do
          subject.add_paternal_grandfather!(narduccio)
          subject.reload.paternal_grandfather.should == narduccio
        end

        context "when it has no father" do
          it "raises a LineageGapException" do
            subject.remove_father!
            expect { subject.add_paternal_grandfather!(narduccio) }.to raise_error(Genealogy::LineageGapException)
          end
        end

        it "raises an WrongSexException when adding a female grandfather" do
          expect { subject.add_paternal_grandfather!(maria)}.to raise_error(Genealogy::WrongSexException)
        end

        it "raises a IncompatibleObjectException when adding other class objects" do
          expect { subject.add_paternal_grandfather!(Object.new) }.to raise_error(Genealogy::IncompatibleObjectException)
        end

        it "raises an IncompatibleRelationshipException when adding himself as grandfather" do
          expect { subject.add_paternal_grandfather!(subject) }.to raise_error(Genealogy::IncompatibleRelationshipException)
        end


      end

      describe '#add_paternal_grandmother!' do
        it "has maria as paternal grandmother" do
          subject.add_paternal_grandmother!(maria)
          subject.reload.paternal_grandmother.should == maria
        end

        it "raises an WrongSexException when adding a male grandfather" do
          expect { subject.add_paternal_grandmother!(narduccio) }.to raise_error(Genealogy::WrongSexException)
        end

      end

    end

    describe "maternal lineage" do
      
      before(:each) do
        subject.add_mother!(tetta)
      end

      describe '#add_maternal_grandfather!' do
        it "has antonio as maternal grandfather" do
          subject.add_maternal_grandfather!(antonio)
          subject.reload.maternal_grandfather.should == antonio
        end
      end

      describe '#add_maternal_grandmother!' do
        it "has assunta as maternal grandmother" do
          subject.add_maternal_grandmother!(assunta)
          subject.reload.maternal_grandmother.should == assunta
        end

        it "raises an IncompatibleRelationshipException when adding himself as grandmother" do
          expect { subject.add_maternal_grandmother!(subject) }.to raise_error(Genealogy::IncompatibleRelationshipException)
        end

      end

    end

  end

end

