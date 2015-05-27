require 'spec_helper'

describe "*** Complex Query methods (based on spec/genealogy/sample_pedigree*.pdf files) *** ", :done, :query do
  before { @model = get_test_model({current_spouse: true})}
  include_context "pedigree exists"

  describe "peter" do
    subject {peter}
    describe "least common ancestor" do
      context "with mary" do
        specify { expect(peter.least_common_ancestor(mary)).to match_array([paul])}
      end
      context "with steve" do
        specify { expect(peter.least_common_ancestor(steve)).to match_array([paul, titty])}
      end
      context "with sue" do
        specify { expect(peter.least_common_ancestor(sue)).to match_array([irene, paso])}
      end
      context "with michelle" do
        specify { expect(peter.least_common_ancestor(michelle)).to match_array([])}
      end
      context "with jack" do
        specify { expect(peter.least_common_ancestor(jack)).to match_array([jack])}
      end
      context "with john" do
        specify { expect(peter.least_common_ancestor(john)).to match_array([jack, alison])}
      end
    end
  end

  describe "irene" do
    subject {irene}
    describe "least common ancestor" do
      context "with mary" do
        specify { expect(irene.least_common_ancestor(mary)).to match_array([louise])}
      end
      context "with paso" do
        specify { expect(irene.least_common_ancestor(paso)).to match_array([louise])}
      end
      context "with rosa" do
        specify { expect(irene.least_common_ancestor(rosa)).to match_array([rosa])}
      end
      context "with bad input" do
        specify { expect{irene.least_common_ancestor('17')}.to raise_error(ArgumentError)}
      end
    end
  end
end
