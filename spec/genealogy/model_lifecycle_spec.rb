require 'spec_helper'

describe "*** Model lifecycle ***", :done, :model do

  before { @model = get_test_model({}) }

  include_context 'unreleted people exist'

  context "when peter is son of paul and titty" do
    before { peter.update_attributes(father_id: paul.id, mother_id: titty.id) }

    context "when destroying paul" do
      before { paul.destroy }
      it "peter's father_id is nil" do
        expect(peter.reload.father_id).to be_nil
      end
      it "paul.reload raises exception ActiveRecord::RecordNotFound" do
        expect { paul.reload }.to raise_error ActiveRecord::RecordNotFound
      end
    end
    context "when destroying titty" do
      before { titty.destroy }
      it "peter's mother_id is nil" do
        expect(peter.reload.mother_id).to be_nil
      end
      it "titty.reload raises exception ActiveRecord::RecordNotFound" do
        expect { titty.reload }.to raise_error ActiveRecord::RecordNotFound
      end
    end

  end

end

