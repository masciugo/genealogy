require 'spec_helper'

describe "*** Complex Query methods (based on spec/genealogy/sample_pedigree*.pdf files) *** ", :done, :query do
  before { @model = get_test_model({current_spouse: true})}


  describe "peter" do
    subject {peter}
    describe "least common ancestor" do
      context "with steve" do
        specify { expect(peter.least_common_ancestor(steve)).to match_array([paul, titty])}
      end
      context "with sue" do
        specify { expect(peter.least_common_ancestor(sue)).to match_array([irene, paso])}
      end
      context "with mary" do
        specify { expect(peter.least_common_ancestor(sue)).to match_array([jack, alison])}
      end
    end
  end
end
