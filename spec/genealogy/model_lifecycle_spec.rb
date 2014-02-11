require 'spec_helper'

module ModelLifecycleSpec
  extend GenealogyTestModel

  describe "*** Model lifecycle ***" do
    
    before(:all) do
      ModelLifecycleSpec.define_test_model_class({})
    end

    let!(:paul) {TestModel.create_with(:sex => "M", :father_id => manuel.id, :mother_id => terry.id).find_or_create_by(:name => "paul")}
    let!(:titty) {TestModel.create_with(:sex => "F", :father_id => paso.id, :mother_id => irene.id).find_or_create_by(:name => "titty")}
    let!(:rud) {TestModel.create_with(:sex => "M", :father_id => paso.id, :mother_id => irene.id).find_or_create_by(:name => "rud")}
    let!(:mark) {TestModel.create_with(:sex => "M", :father_id => paso.id, :mother_id => irene.id).find_or_create_by(:name => "mark")}
    let!(:peter) {TestModel.create_with(:sex => "M", :father_id => paul.id, :mother_id => titty.id).find_or_create_by(:name => "peter")}
    let!(:mary) {TestModel.create_with(:sex => "F", :father_id => paul.id, :mother_id => barbara.id).find_or_create_by(:name => "mary")}
    let!(:mia) {TestModel.create_with(:sex => "F").find_or_create_by(:name => "mia")}
    let!(:sam) {TestModel.create_with(:sex => "M", :father_id => mark.id, :mother_id => mia.id).find_or_create_by(:name => "sam")}
    let!(:charlie) {TestModel.create_with(:sex => "M", :father_id => mark.id, :mother_id => mia.id).find_or_create_by(:name => "charlie")}
    let!(:barbara) {TestModel.create_with(:sex => "F", :father_id => john.id, :mother_id => maggie.id).find_or_create_by(:name => "barbara")}
    let!(:paso) {TestModel.create_with(:sex => "M", :father_id => jack.id, :mother_id => alison.id, :current_spouse_id => irene.id ).find_or_create_by(:name => "paso")}
    let!(:irene) {TestModel.create_with(:sex => "F", :father_id => tommy.id, :mother_id => emily.id).find_or_create_by(:name => "irene")}
    let!(:manuel) {TestModel.create_with(:sex => "M").find_or_create_by(:name => "manuel")}
    let!(:terry) {TestModel.create_with(:sex => "F", :father_id => marcel.id).find_or_create_by(:name => "terry")}
    let!(:john) {TestModel.create_with(:sex => "M", :father_id => jack.id, :mother_id => alison.id).find_or_create_by(:name => "john")}
    let!(:jack) {TestModel.create_with(:sex => "M", :father_id => bob.id, :mother_id => louise.id).find_or_create_by(:name => "jack")}
    let!(:bob) {TestModel.create_with(:sex => "M").find_or_create_by(:name => "bob")}
    let!(:debby) {TestModel.create_with(:sex => "F", :father_id => bob.id, :mother_id => louise.id).find_or_create_by(:name => "debby")}
    let!(:alison) {TestModel.create_with(:sex => "F").find_or_create_by(:name => "alison")}
    let!(:maggie) {TestModel.create_with(:sex => "F").find_or_create_by(:name => "maggie")}
    let!(:emily) {TestModel.create_with(:sex => "F", :father_id => luis.id, :mother_id => rosa.id).find_or_create_by(:name => "emily")}
    let!(:tommy) {TestModel.create_with(:sex => "M", :father_id => larry.id, :mother_id => louise.id).find_or_create_by(:name => "tommy")}
    let!(:luis) {TestModel.create_with(:sex => "M").find_or_create_by(:name => "luis")}
    let!(:rosa) {TestModel.create_with(:sex => "F").find_or_create_by(:name => "rosa")}
    let!(:larry) {TestModel.create_with(:sex => "M").find_or_create_by(:name => "larry")}
    let!(:louise) {TestModel.create_with(:sex => "F").find_or_create_by(:name => "louise")}
    let!(:ned) {TestModel.create_with(:sex => "M").find_or_create_by(:name => "ned")}
    let!(:steve) {TestModel.create_with(:sex => "M", :father_id => paul.id, :mother_id => titty.id).find_or_create_by(:name => "steve")}
    let!(:naomi) {TestModel.create_with(:sex => "F").find_or_create_by(:name => "naomi")}
    let!(:michelle) {TestModel.create_with(:sex => "F", :father_id => ned.id, :mother_id => naomi.id).find_or_create_by(:name => "michelle")}
    let!(:marcel) {TestModel.create_with(:sex => "M").find_or_create_by(:name => "marcel")}
    let!(:beatrix) {TestModel.create_with(:sex => "F", :father_id => paul.id, :mother_id => michelle.id).find_or_create_by(:name => "beatrix")}
    let!(:julian) {TestModel.create_with(:sex => "M", :father_id => paul.id, :mother_id => michelle.id).find_or_create_by(:name => "julian")}
    let!(:ruben) {TestModel.create_with(:sex => "M", :father_id => paul.id).find_or_create_by(:name => "ruben")}

    describe "#destroy", :wip do
      context "when destroying paul" do
        before(:each) do
          paul.destroy
        end
        it "peter's father is nil" do
          expect(peter.reload.father).to be_nil
        end
        it "paul.reload raises exception ActiveRecord::RecordNotFound" do
          expect { paul.reload }.to raise_error ActiveRecord::RecordNotFound
        end
      end
      context "when destroying louise" do
        before(:each) do
          louise.destroy
        end
        it "peter's mother is nil" do
          expect(jack.reload.mother).to be_nil
        end
        it "louise.reload raises exception ActiveRecord::RecordNotFound" do
          expect { louise.reload }.to raise_error ActiveRecord::RecordNotFound
        end
      end
    end


  end



  
end

