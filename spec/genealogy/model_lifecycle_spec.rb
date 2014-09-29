require 'spec_helper'

module ModelLifecycleSpec
  extend GenealogyTestModel

  describe "*** Model lifecycle ***" do

    before(:all) do
      ModelLifecycleSpec.define_test_model_class({:current_spouse => true})
    end

    let(:paul) {TestModel.my_find_or_create_by({:sex => "M", :father_id => manuel.id, :mother_id => terry.id},{:name => "paul"})}
    let(:paul) {TestModel.my_find_or_create_by({:sex => "M", :father_id => manuel.id, :mother_id => terry.id},{:name => "paul"})}
    let(:titty) {TestModel.my_find_or_create_by({:sex => "F", :father_id => paso.id, :mother_id => irene.id},{:name => "titty"})}
    let(:rud) {TestModel.my_find_or_create_by({:sex => "M", :father_id => paso.id, :mother_id => irene.id},{:name => "rud"})}
    let(:mark) {TestModel.my_find_or_create_by({:sex => "M", :father_id => paso.id, :mother_id => irene.id},{:name => "mark"})}
    let(:peter) {TestModel.my_find_or_create_by({:sex => "M", :father_id => paul.id, :mother_id => titty.id},{:name => "peter"})}
    let(:mary) {TestModel.my_find_or_create_by({:sex => "F", :father_id => paul.id, :mother_id => barbara.id},{:name => "mary"})}
    let(:mia) {TestModel.my_find_or_create_by({:sex => "F"},{:name => "mia"})}
    let(:sam) {TestModel.my_find_or_create_by({:sex => "M", :father_id => mark.id, :mother_id => mia.id},{:name => "sam"})}
    let(:charlie) {TestModel.my_find_or_create_by({:sex => "M", :father_id => mark.id, :mother_id => mia.id},{:name => "charlie"})}
    let(:barbara) {TestModel.my_find_or_create_by({:sex => "F", :father_id => john.id, :mother_id => maggie.id},{:name => "barbara"})}
    let(:paso) {TestModel.my_find_or_create_by({:sex => "M", :father_id => jack.id, :mother_id => alison.id, :current_spouse_id => irene.id },{:name => "paso"})}
    let(:irene) {TestModel.my_find_or_create_by({:sex => "F", :father_id => tommy.id, :mother_id => emily.id},{:name => "irene"})}
    let(:manuel) {TestModel.my_find_or_create_by({:sex => "M"},{:name => "manuel"})}
    let(:terry) {TestModel.my_find_or_create_by({:sex => "F", :father_id => marcel.id},{:name => "terry"})}
    let(:john) {TestModel.my_find_or_create_by({:sex => "M", :father_id => jack.id, :mother_id => alison.id},{:name => "john"})}
    let(:jack) {TestModel.my_find_or_create_by({:sex => "M", :father_id => bob.id, :mother_id => louise.id},{:name => "jack"})}
    let(:bob) {TestModel.my_find_or_create_by({:sex => "M"},{:name => "bob"})}
    let(:debby) {TestModel.my_find_or_create_by({:sex => "F", :father_id => bob.id, :mother_id => louise.id},{:name => "debby"})}
    let(:alison) {TestModel.my_find_or_create_by({:sex => "F"},{:name => "alison"})}
    let(:maggie) {TestModel.my_find_or_create_by({:sex => "F"},{:name => "maggie"})}
    let(:emily) {TestModel.my_find_or_create_by({:sex => "F", :father_id => luis.id, :mother_id => rosa.id},{:name => "emily"})}
    let(:tommy) {TestModel.my_find_or_create_by({:sex => "M", :father_id => larry.id, :mother_id => louise.id},{:name => "tommy"})}
    let(:luis) {TestModel.my_find_or_create_by({:sex => "M"},{:name => "luis"})}
    let(:rosa) {TestModel.my_find_or_create_by({:sex => "F"},{:name => "rosa"})}
    let(:larry) {TestModel.my_find_or_create_by({:sex => "M"},{:name => "larry"})}
    let(:louise) {TestModel.my_find_or_create_by({:sex => "F"},{:name => "louise"})}
    let(:ned) {TestModel.my_find_or_create_by({:sex => "M"},{:name => "ned"})}
    let(:steve) {TestModel.my_find_or_create_by({:sex => "M", :father_id => paul.id, :mother_id => titty.id},{:name => "steve"})}
    let(:naomi) {TestModel.my_find_or_create_by({:sex => "F"},{:name => "naomi"})}
    let(:michelle) {TestModel.my_find_or_create_by({:sex => "F", :father_id => ned.id, :mother_id => naomi.id},{:name => "michelle"})}
    let(:marcel) {TestModel.my_find_or_create_by({:sex => "M"},{:name => "marcel"})}
    let(:beatrix) {TestModel.my_find_or_create_by({:sex => "F", :father_id => paul.id, :mother_id => michelle.id},{:name => "beatrix"})}
    let(:julian) {TestModel.my_find_or_create_by({:sex => "M", :father_id => paul.id, :mother_id => michelle.id},{:name => "julian"})}
    let(:ruben) {TestModel.my_find_or_create_by({:sex => "M", :father_id => paul.id},{:name => "ruben"})}

    describe "#destroy" do
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

