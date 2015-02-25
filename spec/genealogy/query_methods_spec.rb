require 'spec_helper'

describe "*** Query methods ***", :done, :query do

  before { @model = get_test_model({:current_spouse => true})}
  include_context "releted people exist"

  describe "class methods" do
    describe ".males" do
      specify do
        all_males = [ruben, paul, peter, paso, manuel, john, jack, bob, tommy, luis, larry, ned, steve, marcel, julian, rud, mark, sam, charlie]
        expect(@model.males.all).to match_array all_males
      end
    end

    describe ".females" do
      specify do
        all_females = [titty, mary, barbara, irene, terry, debby, alison, maggie, emily, rosa, louise, naomi, michelle, beatrix, mia, sue]
        expect(@model.females.all).to match_array all_females
      end
    end
  end

  describe "peter" do
    subject {peter}
    its(:parents) {is_expected.to match_array [paul, titty]}
    its(:paternal_grandfather) {is_expected.to eq manuel}
    its(:paternal_grandmother) {is_expected.to eq terry}
    its(:maternal_grandfather) {is_expected.to eq paso}
    its(:maternal_grandmother) {is_expected.to eq irene}
    its(:grandparents) {is_expected.to match_array [manuel, terry, paso, irene]}
    its(:siblings) {is_expected.to match_array [steve]}
    its(:paternal_grandparents) {is_expected.to match_array [manuel, terry]}
    its(:maternal_grandparents) {is_expected.to match_array [paso, irene]}
    its(:half_siblings) {is_expected.to match_array [ruben, mary, julian, beatrix]}
    its(:ancestors) {is_expected.to match_array [paul, titty, manuel, terry, paso, irene, tommy, emily, larry, louise, luis, rosa, marcel, bob, jack, alison]}
    its(:uncles) {is_expected.to match_array [mark, rud]}
    its(:maternal_uncles) {is_expected.to match_array [mark, rud]}
    its(:paternal_uncles) {is_expected.to match_array []}
    its(:great_grandparents) {is_expected.to match_array [nil, nil, marcel, nil, jack, alison, tommy, emily]}
    describe "cousins" do
      it { expect(peter.cousins).to match_array([sam, charlie, sue])}
      context "with options :lineage => :paternal" do
        specify { expect(peter.cousins(:lineage => :paternal)).to  match_array [] }
      end
      context "with options :lineage => :maternal" do
        specify { expect(peter.cousins(:lineage => :maternal)).to  match_array [sam,charlie,sue] }
      end
    end
    describe "family_hash" do
      it { expect( peter.family_hash ).to match_family({:father => paul, :mother => titty, :children => [], :siblings => [steve], :current_spouse=>nil}) }
      context "with options :half => :include" do
        specify { expect(peter.family_hash(:half => :include)).to match_family({:father => paul, :mother => titty, :children => [], :siblings => [steve], :current_spouse=>nil, :half_siblings => [ruben, mary, julian, beatrix] })}
      end
      context "with options :half => :father" do
        specify { expect(peter.family_hash(:half => :father)).to match_family({:father => paul, :mother => titty, :children => [], :siblings => [steve], :current_spouse=>nil, :paternal_half_siblings => [ruben, mary, julian, beatrix] })}
      end
      context "with options :half => :mother" do
        specify { expect(peter.family_hash(:half => :mother)).to match_family({:father => paul, :mother => titty, :children => [], :siblings => [steve], :current_spouse=>nil, :maternal_half_siblings => [] })}
      end
      context "with options :extended => true" do
        specify { expect(peter.family_hash(:extended => true)).to match_family(
          :father=>paul, 
          :mother=>titty, 
          :children=>[], 
          :siblings=>[steve], 
          :current_spouse=>nil,
          :paternal_grandfather=>manuel,
          :paternal_grandmother=>terry,
          :maternal_grandfather=>paso,
          :maternal_grandmother=>irene,
          :grandchildren=>[], 
          :uncles_and_aunts=>[rud, mark], 
          :nieces_and_nephews=>[], 
          :cousins=>[sam, sue, charlie])}
      end
      context "with options :extended => true, :half => :include" do
        specify { expect(peter.family_hash(:extended => true, :half => :include)).to match_family(
          :father=>paul, 
          :mother=>titty, 
          :children=>[], 
          :siblings=>[steve], 
          :current_spouse=>nil,
          :paternal_grandfather=>manuel,
          :paternal_grandmother=>terry,
          :maternal_grandfather=>paso,
          :maternal_grandmother=>irene,
          :grandchildren=>[], 
          :uncles_and_aunts=>[rud, mark], 
          :nieces_and_nephews=>[], 
          :cousins=>[sam, sue, charlie],
          :half_siblings=>[ruben, mary, julian, beatrix])}
      end
      context "with options :half => :bar" do
        specify { expect { peter.family_hash(:half => :bar) }.to raise_error(ArgumentError)}
      end
    end

    describe "family" do
      it { expect(peter.family).to match_array([paul, titty, steve])}
      context "with options :half => :include" do
        specify { expect(peter.family(:half => :include)).to match_array([paul, titty, steve, ruben, mary, julian, beatrix])}
      end
      context "with options :half => :father" do
        specify { expect(peter.family(:half => :father)).to match_array([paul, titty, steve, ruben, mary, julian, beatrix])}
      end
      context "with options :half => :mother" do
        specify { expect(peter.family(:half => :mother)).to match_array([paul, titty, steve])}
      end
      context "with options :extended => true" do
        specify { expect(peter.family(:extended => true)).to match_array([paul, titty, steve, manuel, terry, paso, irene, rud, mark, sue, sam, charlie])}
      end
      context "with options :extended => true, :half => :include" do
        specify { expect(peter.family(:extended => true, :half => :include)).to match_array([paul, titty, steve, manuel, terry, paso, irene, rud, mark, sue, sam, charlie, ruben, mary, julian, beatrix])}
      end
      context "with options :half => :bar" do
        specify { expect { peter.family(:half => :bar) }.to raise_error(ArgumentError)}
      end
    end
  end

  describe "mary" do
    subject {mary}
    its(:parents) {is_expected.to match_array [paul, barbara]}
    its(:paternal_grandfather) {is_expected.to eq manuel}
    its(:paternal_grandmother) {is_expected.to eq terry}
    its(:maternal_grandfather) {is_expected.to eq john}
    its(:maternal_grandmother) {is_expected.to eq maggie}
    its(:paternal_grandparents) {is_expected.to match_array [manuel, terry]}
    its(:maternal_grandparents) {is_expected.to match_array [john, maggie]}
    its(:grandparents) {is_expected.to match_array [manuel, terry, john, maggie]}
    its(:half_siblings) {is_expected.to match_array [ruben, peter, julian, beatrix, steve] }
    its(:descendants) {is_expected.to be_empty}
    its(:siblings) {is_expected.to_not include peter }
    its(:ancestors) {is_expected.to match_array [paul, barbara, manuel, terry, john, maggie, marcel, jack, alison, bob, louise]}
  end

  describe "beatrix" do
    subject {beatrix}
    its(:parents) {is_expected.to match_array [paul, michelle]}
    its(:siblings) {is_expected.to match_array [julian]}
    its(:half_siblings) {is_expected.to match_array [ruben, peter, steve, mary]}
    its(:paternal_half_siblings) {is_expected.to match_array [ruben, peter, steve, mary]}
    describe "all half_siblings and siblings: #siblings(:half => :include)" do
      specify {expect(beatrix.siblings(:half => :include)).to match_array [ruben, peter, steve, mary, julian]}
    end
    describe "half_siblings with titty: #siblings(:half => father, :spouse => titty)" do
      specify {expect(beatrix.siblings(:half => :father, :spouse => titty)).to match_array [peter, steve]}
    end
    describe "half_siblings with mary: #siblings(:half => father, :spouse => barbara)" do
      specify {expect(beatrix.siblings(:half => :father, :spouse => barbara)).to match_array [mary]}
    end
  end

  describe "paul" do
    subject {paul}
    its(:parents) {is_expected.to match_array [manuel, terry]}
    describe "children" do
      it { expect(paul.children).to match_array([ruben, peter, mary, julian, beatrix, steve])}
      context "with options :sex => :male" do
        specify { expect(paul.children(:sex => :male)).to match_array [ruben, peter, julian, steve] }
      end
      context "with options :sex => :female" do
        specify { expect(paul.children(:sex => :female)).to match_array [mary, beatrix] }
      end
      context "with options :spouse => barbara" do
        specify { expect(paul.children(:spouse => barbara)).to match_array [mary] }
      end
      context "with options :spouse => michelle" do
        specify { expect(paul.children(:spouse => michelle)).to match_array [julian, beatrix] }
      end
      context "with options :spouse => nil" do
        specify { expect(paul.children(:spouse => nil)).to match_array [ruben] }
      end
    end
    describe "ancestors" do
      specify { expect(paul.ancestors).to match_array [manuel, terry, marcel] }
      context "with options sex: :male" do
        specify { expect(paul.ancestors(sex: :male)).to match_array [manuel, marcel] }
      end
      context "with options sex: :female" do
        specify { expect(paul.ancestors(sex: :female)).to match_array [terry] }
      end
    end
    describe "descendants" do
      specify { expect(paul.descendants).to match_array [ruben, peter, mary, julian, beatrix, steve] }
      context "with options sex: :male" do
        specify { expect(paul.descendants(sex: :male)).to match_array [ruben, peter, julian, steve] }
      end
      context "with options sex: :female" do
        specify { expect(paul.descendants(sex: :female)).to match_array [mary, beatrix] }
      end
    end
    its(:maternal_grandmother) {is_expected.to be_nil}
    its(:maternal_grandparents) {is_expected.to match_array [marcel, nil]}
    its(:grandparents) {is_expected.to match_array [nil, nil, marcel, nil]}
    its(:spouses) {is_expected.to match_array [michelle,titty,barbara,nil]}

  end

  describe "terry" do
    subject {terry}
    its(:father) {is_expected.to eq marcel}
    its(:mother) {is_expected.to be_nil}
    its(:parents) {is_expected.to match_array [marcel, nil]}
    its(:ancestors) {is_expected.to match_array [marcel]}
    its(:grandchildren) {is_expected.to match_array [ruben, julian,beatrix,peter,steve,mary]}
  end

  describe "barbara" do
    subject {barbara}
    its(:children) {is_expected.to match_array [mary]}
    describe "children with manuel" do
      specify { expect(barbara.children(:spouse => manuel)).to be_empty }
    end
    its(:descendants) {is_expected.to match_array [mary]}
    its(:grandparents) {is_expected.to match_array [jack, alison, nil, nil]}
    describe "cousins", :wipp do
      it { expect(barbara.cousins).to match_array([titty,rud,mark])}
      context "with options :sex => :male" do
        specify { expect(barbara.cousins(:sex => :male)).to  match_array [rud,mark] }
      end
      context "with options :sex => :female" do
        specify { expect(barbara.cousins(:sex => :female)).to  match_array [titty] }
      end
      context "with options :lineage => :paternal" do
        specify { expect(barbara.cousins(:lineage => :paternal)).to  match_array [titty,rud,mark] }
      end
      context "with options :lineage => :maternal" do
        specify { expect(barbara.cousins(:lineage => :maternal)).to  match_array [] }
      end
      context "with options :lineage => :paternal, :sex => :female" do
        specify { expect(barbara.cousins(:lineage => :paternal, :sex => :female)).to  match_array [titty] }
      end

    end
  end

  describe "paso" do
    subject {paso}
    its(:children) {is_expected.to match_array [titty, rud, mark]}
    its(:descendants) {is_expected.to match_array [titty, peter, steve, rud, mark, sam, charlie, sue]}
    its(:aunts) {is_expected.to match_array [debby]}
    its(:maternal_aunts) {is_expected.to match_array []}
    its(:paternal_aunts) {is_expected.to match_array [debby]}
    describe "family_hash" do
      it { expect( paso.family_hash ).to match_family({
        :father => jack, 
        :mother => alison, 
        :children => [titty,rud,mark], 
        :siblings => [john], 
        :current_spouse => irene}) }
      context "with options :half => :include" do
        specify { expect(paso.family_hash(:half => :include)).to match_family({
          :father => jack, 
          :mother => alison, 
          :children => [titty,rud,mark], 
          :siblings => [john], 
          :current_spouse => irene,
          :half_siblings => [] })}
      end
      context "with options :extended => true" do
        specify { expect(paso.family_hash(:extended => true)).to match_family(
          :father => jack, 
          :mother => alison, 
          :children => [titty,rud,mark], 
          :siblings => [john], 
          :current_spouse => irene,
          :paternal_grandfather=>bob,
          :paternal_grandmother=>louise,
          :maternal_grandfather=>nil,
          :maternal_grandmother=>nil,
          :grandchildren=>[peter,steve,sue,sam,charlie], 
          :uncles_and_aunts=>[debby], 
          :nieces_and_nephews=>[], 
          :cousins=>[])}
      end
    end

  end

  describe "louise" do
    subject {louise}
    its(:children) {is_expected.to match_array [tommy, jack, debby]}
    its(:descendants) {is_expected.to match_array [tommy, irene, titty, peter, jack, john, barbara, mary, debby, steve, paso, rud, mark, sam, charlie, sue]}
    its(:ancestors) {is_expected.to be_empty}
    its(:great_grandchildren) {is_expected.to match_array [titty, rud, mark, barbara]}
    its(:great_grandparents) {is_expected.to match_array [nil, nil, nil, nil, nil, nil, nil, nil]}
    its(:father){is_expected.to be_nil}
    its(:parents){is_expected.to match_array [nil,nil]}
    its(:spouses) {is_expected.to match_array [larry,bob]}
  end

  describe "michelle" do
    subject { michelle }
    its(:family) {is_expected.to match_array [naomi,julian,beatrix,paul,ned] }
    its(:extended_family) {is_expected.to match_array [naomi,julian,beatrix,paul,ned] }
  end

  describe "titty" do
    subject { titty }
    its(:uncles_and_aunts) {is_expected.to match_array [john] }
    its(:uncles) {is_expected.to match_array [john] }
    its(:paternal_uncles) {is_expected.to match_array [john] }
    its(:maternal_uncles) {is_expected.to match_array [] }
    its(:nieces_and_nephews) {is_expected.to match_array [sam,charlie,sue]}
    its(:nephews) {is_expected.to match_array [sam, charlie]}
    its(:nieces) {is_expected.to match_array [sue]}
    describe "cousins" do
      it { expect(titty.cousins).to match_array([barbara])}
      context "with options :lineage => :paternal" do
        specify { expect(titty.cousins(:lineage => :paternal)).to  match_array [barbara] }
      end
      context "with options :lineage => :maternal" do
        specify { expect(titty.cousins(:lineage => :maternal)).to  match_array [] }
      end
    end
    its(:family) {is_expected.to match_array [peter,steve,rud,mark,irene,paso]}
    its(:extended_family) {is_expected.to match_array [peter,steve,rud,mark,irene,paso,sam,charlie,emily,sue,tommy,jack,alison,john, barbara]}
    describe "family_hash" do
      it { expect( titty.family_hash ).to match_family({
        :father => paso, 
        :mother => irene, 
        :children => [peter,steve], 
        :siblings => [rud,mark], 
        :current_spouse => nil}) }
      context "with options :extended => true" do
        specify { expect(titty.family_hash(:extended => true)).to match_family(
          :father => paso, 
          :mother => irene, 
          :children => [peter,steve], 
          :siblings => [rud,mark], 
          :current_spouse => nil,
          :paternal_grandfather=>tommy,
          :paternal_grandmother=>emily,
          :maternal_grandfather=>jack,
          :maternal_grandmother=>alison,
          :grandchildren=>[], 
          :uncles_and_aunts=>[], 
          :nieces_and_nephews=>[sue,sam,charlie], 
          :cousins=>[barbara])}
      end
    end

  end

  describe "irene" do
    subject { irene }
    its(:uncles_and_aunts) {is_expected.to be_empty }
    describe "#uncles_and_aunts(:half => :include)" do
      specify { expect(irene.uncles_and_aunts(:half => :include)).to match_array [debby, jack] }
    end
    describe "#uncles_and_aunts(:half => :include, :lineage => :paternal )" do
      specify { expect(irene.uncles_and_aunts(:half => :include, :lineage => :paternal )).to match_array [debby, jack] }
    end
    describe "#uncles_and_aunts(:half => :include, :sex => :male)" do
      specify { expect(irene.uncles_and_aunts(:half => :include, :sex => :male)).to match_array [jack] }
    end
    describe "#uncles_and_aunts(:half => :include, :sex => :female)" do
      specify { expect(irene.uncles_and_aunts(:half => :include, :sex => :female)).to match_array [debby] }
    end
  end

  describe "rud" do
    subject { rud }
    its(:nieces_and_nephews) {is_expected.to match_array [sue, sam, charlie, peter, steve] }
    describe "#nieces_and_nephews(:sex => :male)" do
      specify { expect(rud.nieces_and_nephews(:sex => :male)).to match_array [sam, charlie, peter, steve] }
    end
  end

  describe "tommy" do
    subject { tommy }
    its(:nieces_and_nephews) {is_expected.to be_empty }
    describe "#nieces_and_nephews({},{:half => :include })" do
      specify { expect(tommy.nieces_and_nephews({:half => :include })).to match_array [paso, john] }
    end
  end

end
