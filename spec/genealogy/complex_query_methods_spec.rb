require 'spec_helper'

describe "*** Complex Query methods (based on spec/genealogy/sample_pedigree*.pdf files) *** ", :done, :query do
  before { @model = get_test_model({current_spouse: true})}
  include_context "pedigree exists"

  describe "peter" do
    subject {peter}
    describe "lowest common ancestors" do
      context "with mary" do
        specify { expect(peter.lowest_common_ancestors(mary)).to match_array([paul])}
        specify { expect(peter.class.lowest_common_ancestors(peter, mary)).to match_array([paul])}
      end
      context "with steve" do
        specify { expect(peter.lowest_common_ancestors(steve)).to match_array([paul, titty])}
      end
      context "with sue" do
        specify { expect(peter.lowest_common_ancestors(sue)).to match_array([irene, paso])}
      end
      context "with michelle" do
        specify { expect(peter.lowest_common_ancestors(michelle)).to match_array([])}
      end
      context "with jack" do
        specify { expect(peter.lowest_common_ancestors(jack)).to match_array([jack])}
      end
      context "with john" do
        specify { expect(peter.lowest_common_ancestors(john)).to match_array([jack, alison])}
      end
      context "with charlie and barbara" do
        specify { expect(peter.lowest_common_ancestors(john, barbara)).to match_array([jack, alison])}
      end
      context "with paso, jack, and bob" do
        specify { expect(peter.lowest_common_ancestors(paso, jack, bob)).to match_array([bob])}
      end
      context "with paso, jack, bob, and marcel" do
        specify { expect(peter.lowest_common_ancestors(paso, jack, bob, marcel)).to match_array([])}
      end
    end
  end

  describe "irene" do
    subject {irene}
    describe "lowest common ancestors" do
      context "with mary" do
        specify { expect(irene.lowest_common_ancestors(mary)).to match_array([louise])}
      end
      context "with paso" do
        specify { expect(irene.lowest_common_ancestors(paso)).to match_array([louise])}
      end
      context "with rosa" do
        specify { expect(irene.lowest_common_ancestors(rosa)).to match_array([rosa])}
      end
      context "with sue, peter, paso, and debby" do
        specify { expect(irene.lowest_common_ancestors(sue, peter, paso, debby)).to match_array([louise])}
      end
      context "with bad input" do
        specify { expect{irene.lowest_common_ancestors('17')}.to raise_error(ArgumentError)}
      end
    end
  end
end
