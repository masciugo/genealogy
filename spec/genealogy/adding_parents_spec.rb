require 'spec_helper'

module AddingParentsSpec
  extend GenealogyTestModel
  
  describe "adding/removing parents" do

    before(:all) do
      AddingParentsSpec.define_test_model_class({})
    end

    subject(:corrado) {TestModel.create!(:name => "Corrado", :sex => "M")}
    let(:uccio) {TestModel.create!(:name => "Uccio", :sex => "M")}
    let(:tetta) {TestModel.create!(:name => "Tetta", :sex => "F")}

    describe "corrado" do
      
      describe "#add_father(uccio)" do

        it "has uccio as father" do
          corrado.add_father(uccio)
          corrado.reload
          corrado.father.should == uccio
        end

        it "raises an IncompatibleObjectException when adding other class objects" do
          expect { corrado.add_father(Object.new) }.to raise_error(Genealogy::IncompatibleObjectException)
        end

        it "raises an IncompatibleRelationshipException when adding himself as father" do
          expect { corrado.add_father(corrado) }.to raise_error(Genealogy::IncompatibleRelationshipException)
        end

        let(:tetta) {TestModel.create!(:name => "tetta", :sex => "F")}

        it "raises a WrongSexException when adding a female as father" do
          expect { corrado.add_father(tetta) }.to raise_error(Genealogy::WrongSexException)
        end

      end

      describe "#add_parents(uccio,tetta)" do
        
        its(:parents) do
          corrado.add_parents(uccio,tetta)
          corrado.reload
          should == [uccio,tetta]
        end

        context "when corrado is invalid" do
          before(:each) do
            corrado.mark_invalid!
          end
          specify { expect { corrado.add_parents(uccio,tetta) }.to raise_error }
          its(:parents) do
            corrado.add_parents(uccio,tetta) rescue true
            corrado.reload
            should be_empty
          end
        end

      end

      context "when has uccio as father" do
        
        before(:each) do
          corrado.add_father(uccio)
        end

        describe "#remove_father" do

          it "has no father" do
            corrado.remove_father
            corrado.reload.father.should be_nil
          end

        end

        context "and tetta as mother" do
        
          before(:each) do
            corrado.add_mother(tetta)
          end

          describe "#remove_parents" do
            its(:parents) do
              corrado.remove_parents
              should be_empty
            end
          end

        end

        context "and #add_father(nil)" do
          
          its(:father) do
            corrado.add_father(nil)
            should be_nil
          end

        end

        context "and #add_parents(nil,nil)" do
          
          its(:parents) do
            corrado.add_parents(nil,nil)
            should be_empty
          end

        end


      end

    end



  end

end