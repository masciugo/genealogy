require 'spec_helper'

module QueryMethodsSpec
  extend GenealogyTestModel

  describe "*** Query methods ***" do

    before(:all) do
      QueryMethodsSpec.define_test_model_class({:current_spouse => true, birth_date_column: 'birth_date', death_date_column: 'death_date' })
    end

    let!(:paul) {TestModel.my_find_or_create_by({:sex => "M", :father_id => manuel.id, :mother_id => terry.id},{:name => "paul"})}
    let!(:paul) {TestModel.my_find_or_create_by({:sex => "M", :father_id => manuel.id, :mother_id => terry.id},{:name => "paul"})}
    let!(:titty) {TestModel.my_find_or_create_by({:sex => "F", :father_id => paso.id, :mother_id => irene.id},{:name => "titty"})}
    let!(:rud) {TestModel.my_find_or_create_by({:sex => "M", :father_id => paso.id, :mother_id => irene.id},{:name => "rud"})}
    let!(:mark) {TestModel.my_find_or_create_by({:sex => "M", :father_id => paso.id, :mother_id => irene.id},{:name => "mark"})}
    let!(:peter) {TestModel.my_find_or_create_by({:sex => "M", :father_id => paul.id, :mother_id => titty.id},{:name => "peter"})}
    let!(:mary) {TestModel.my_find_or_create_by({:sex => "F", :father_id => paul.id, :mother_id => barbara.id},{:name => "mary"})}
    let!(:mia) {TestModel.my_find_or_create_by({:sex => "F"},{:name => "mia"})}
    let!(:sam) {TestModel.my_find_or_create_by({:sex => "M", :father_id => mark.id, :mother_id => mia.id},{:name => "sam"})}
    let!(:sue) {TestModel.my_find_or_create_by({:sex => "F", :father_id => mark.id, :mother_id => mia.id},{:name => "sue"})}
    let!(:charlie) {TestModel.my_find_or_create_by({:sex => "M", :father_id => mark.id, :mother_id => mia.id},{:name => "charlie"})}
    let!(:barbara) {TestModel.my_find_or_create_by({:sex => "F", :father_id => john.id, :mother_id => maggie.id},{:name => "barbara"})}
    let!(:paso) {TestModel.my_find_or_create_by({:sex => "M", :father_id => jack.id, :mother_id => alison.id, :current_spouse_id => irene.id },{:name => "paso"})}
    let!(:irene) {TestModel.my_find_or_create_by({:sex => "F", :father_id => tommy.id, :mother_id => emily.id},{:name => "irene"})}
    let!(:manuel) {TestModel.my_find_or_create_by({:sex => "M"},{:name => "manuel"})}
    let!(:terry) {TestModel.my_find_or_create_by({:sex => "F", :father_id => marcel.id},{:name => "terry"})}
    let!(:john) {TestModel.my_find_or_create_by({:sex => "M", :father_id => jack.id, :mother_id => alison.id},{:name => "john"})}
    let!(:jack) {TestModel.my_find_or_create_by({:sex => "M", :father_id => bob.id, :mother_id => louise.id},{:name => "jack"})}
    let!(:bob) {TestModel.my_find_or_create_by({:sex => "M"},{:name => "bob"})}
    let!(:debby) {TestModel.my_find_or_create_by({:sex => "F", :father_id => bob.id, :mother_id => louise.id},{:name => "debby"})}
    let!(:alison) {TestModel.my_find_or_create_by({:sex => "F"},{:name => "alison"})}
    let!(:maggie) {TestModel.my_find_or_create_by({:sex => "F"},{:name => "maggie"})}
    let!(:emily) {TestModel.my_find_or_create_by({:sex => "F", :father_id => luis.id, :mother_id => rosa.id},{:name => "emily"})}
    let!(:tommy) {TestModel.my_find_or_create_by({:sex => "M", :father_id => larry.id, :mother_id => louise.id},{:name => "tommy"})}
    let!(:luis) {TestModel.my_find_or_create_by({:sex => "M"},{:name => "luis"})}
    let!(:rosa) {TestModel.my_find_or_create_by({:sex => "F"},{:name => "rosa"})}
    let!(:larry) {TestModel.my_find_or_create_by({:sex => "M"},{:name => "larry"})}
    let!(:louise) {TestModel.my_find_or_create_by({:sex => "F", :birth_date => '1925-05-12T18:22:59-05:00', :death_date =>  '1994-03-10T18:22:59-05:00'},{:name => "louise"})}
    let!(:ned) {TestModel.my_find_or_create_by({:sex => "M"},{:name => "ned"})}
    let!(:steve) {TestModel.my_find_or_create_by({:sex => "M", :father_id => paul.id, :mother_id => titty.id},{:name => "steve"})}
    let!(:naomi) {TestModel.my_find_or_create_by({:sex => "F"},{:name => "naomi"})}
    let!(:michelle) {TestModel.my_find_or_create_by({:sex => "F", :father_id => ned.id, :mother_id => naomi.id},{:name => "michelle"})}
    let!(:marcel) {TestModel.my_find_or_create_by({:sex => "M"},{:name => "marcel"})}
    let!(:beatrix) {TestModel.my_find_or_create_by({:sex => "F", :father_id => paul.id, :mother_id => michelle.id},{:name => "beatrix"})}
    let!(:julian) {TestModel.my_find_or_create_by({:sex => "M", :father_id => paul.id, :mother_id => michelle.id},{:name => "julian"})}
    let!(:ruben) {TestModel.my_find_or_create_by({:sex => "M", :father_id => paul.id},{:name => "ruben"})}

    describe "class methods" do
      describe ".males" do
        specify do
          all_males = [ruben, paul, peter, paso, manuel, john, jack, bob, tommy, luis, larry, ned, steve, marcel, julian, rud, mark, sam, charlie]
          TestModel.males.all.should match_array all_males
        end
      end

      describe ".females" do
        specify do
          all_females = [titty, mary, barbara, irene, terry, debby, alison, maggie, emily, rosa, louise, naomi, michelle, beatrix, mia, sue]
          TestModel.females.all.should match_array all_females
        end
      end
    end

    describe "peter" do
      subject {peter}
      its(:parents) {should match_array [paul, titty]}
      its(:paternal_grandfather) {should == manuel}
      its(:paternal_grandmother) {should == terry}
      its(:maternal_grandfather) {should == paso}
      its(:maternal_grandmother) {should == irene}
      its(:grandparents) {should match_array [manuel, terry, paso, irene]}
      its(:siblings) {should match_array [steve]}
      its(:paternal_grandparents) {should match_array [manuel, terry]}
      its(:maternal_grandparents) {should match_array [paso, irene]}
      its(:half_siblings) {should match_array [ruben, mary, julian, beatrix]}
      its(:ancestors) {should match_array [paul, titty, manuel, terry, paso, irene, tommy, emily, larry, louise, luis, rosa, marcel, bob, jack, alison]}
      its(:eligible_fathers) {should match_array []}
      its(:family_hash) { should be_a(Hash) }
      its(:cousins) {should match_array [sam, charlie, sue]}
      its(:uncles) {should match_array [mark, rud]}
      its(:maternal_uncles) {should match_array [mark, rud]}
      its(:paternal_uncles) {should match_array []}
      its(:great_grandparents) {should match_array [nil, marcel, jack, alison, tommy, emily]}

      describe "#family_hash" do
        subject {peter.family_hash}
        specify { should include(
          :father => paul,
          :mother => titty,
          :children => [],
          :siblings => [steve]
        ) }
      end

      describe "#family_hash(:half => :include)[:half_siblings] " do
        subject {peter.family_hash(:half => :include)[:half_siblings]}
        specify { should match_array [ruben, mary, julian, beatrix] }
      end

      describe "#cousins(:lineage => :paternal) " do
        subject {peter.cousins(:lineage => :paternal)}
        specify { should match_array [sam,charlie,sue] }
      end

        describe "#cousins(:lineage => :maternal) " do
        subject {peter.cousins(:lineage => :maternal)}
        specify { should match_array [sam,charlie,sue] }
      end

      describe "#extended_family_hash" do
        subject {peter.extended_family_hash}
        specify { should include(
          :paternal_grandfather => manuel,
          :paternal_grandmother => terry,
          :maternal_grandfather => paso,
          :maternal_grandmother => irene,
          :grandchildren => [],
          :uncles_and_aunts => [rud, mark],
          :nieces_and_nephews => []
        ) }
      end


    end

    describe "mary" do
      subject {mary}
      its(:parents) {should match_array [paul, barbara]}
      its(:paternal_grandfather) {should == manuel}
      its(:paternal_grandmother) {should == terry}
      its(:maternal_grandfather) {should == john}
      its(:maternal_grandmother) {should == maggie}
      its(:paternal_grandparents) {should match_array [manuel, terry]}
      its(:maternal_grandparents) {should match_array [john, maggie]}
      its(:grandparents) {should match_array [manuel, terry, john, maggie]}
      its(:half_siblings) { should match_array [ruben, peter, julian, beatrix, steve] }
      its(:descendants) {should be_empty}
      its(:siblings) { should_not include peter }
      its(:ancestors) {should match_array [paul, barbara, manuel, terry, john, maggie, marcel, jack, alison, bob, louise]}
    end

    describe "beatrix" do
      subject {beatrix}
      its(:parents) {should match_array [paul, michelle]}
      its(:siblings) {should match_array [julian]}
      its(:half_siblings) {should match_array [ruben, peter, steve, mary]}
      its(:paternal_half_siblings) {should match_array [ruben, peter, steve, mary]}
      describe "all half_siblings and siblings: #siblings(:half => :include)" do
        specify {beatrix.siblings(:half => :include).should match_array [ruben, peter, steve, mary, julian]}
      end
      describe "half_siblings with titty: #siblings(:half => father, :spouse => titty)" do
        specify {beatrix.siblings(:half => :father, :spouse => titty).should match_array [peter, steve]}
      end
      describe "half_siblings with mary: #siblings(:half => father, :spouse => barbara)" do
        specify {beatrix.siblings(:half => :father, :spouse => barbara).should match_array [mary]}
      end
    end

    describe "paul" do
      subject {paul}
      its(:parents) {should match_array [manuel, terry]}
      its(:offspring) {should match_array [ruben, peter, mary, julian, beatrix, steve]}
      describe "#offspring(:spouse => barbara)" do
        specify { paul.offspring(:spouse => barbara).should match_array [mary] }
      end
      describe "#offspring(:spouse => michelle)" do
        specify { paul.offspring(:spouse => michelle).should match_array [julian, beatrix] }
      end
      describe "offspring with unknown mother" do
        specify { paul.offspring(:spouse => nil).should match_array [ruben] }
      end
      its(:descendants) {should match_array [ruben, peter, mary, julian, beatrix, steve]}
      its(:ancestors) {should match_array [manuel, terry, marcel]}
      its(:maternal_grandmother) {should be_nil}
      its(:maternal_grandparents) {should match_array [marcel, nil]}
      its(:grandparents) {should match_array [nil, nil, marcel, nil]}
      its(:eligible_paternal_grandfathers) {should match_array [sam,charlie,mark,rud,john,paso,ned,marcel,tommy,jack,luis,larry,bob]}
      its(:spouses) {should match_array [michelle,titty,barbara,nil]}
      its(:eligible_spouses) {should match_array TestModel.females - [michelle,titty,barbara]}
    end

    describe "terry" do
      subject {terry}
      its(:father) {should == marcel}
      its(:mother) {should be_nil}
      its(:parents) {should match_array [marcel, nil]}
      its(:ancestors) {should match_array [marcel]}
      its(:grandchildren) {should match_array [ruben, julian,beatrix,peter,steve,mary]}
    end

    describe "barbara" do
      subject {barbara}
      its(:offspring) {should match_array [mary]}
      describe "offspring with manuel" do
        specify { barbara.offspring(:spouse => manuel).should be_empty }
      end
      its(:descendants) {should match_array [mary]}
      its(:grandparents) {should match_array [jack, alison, nil, nil]}
      its(:eligible_offspring) {should match_array TestModel.all - [mary,barbara,john,maggie,jack,alison,louise,bob]}
    end

    describe "paso" do
      subject {paso}
      its(:offspring) {should match_array [titty, rud, mark]}
      its(:descendants) {should match_array [titty, peter, steve, rud, mark, sam, charlie, sue]}
      its(:family) { should match_array [irene,paso,jack,alison,john,titty,rud,mark] }
      its(:extended_family) { should match_array [irene,paso,jack,alison,john,titty,rud,mark,louise,bob,debby,barbara,charlie,sam,sue,peter,steve] }
      its(:aunts) {should match_array [debby]}
      its(:maternal_aunts) {should match_array []}
      its(:paternal_aunts) {should match_array [debby]}
      its(:eligible_siblings) {should match_array TestModel.all - [paso,john,alison,jack,louise,bob]}
      its(:eligible_half_siblings) {should match_array TestModel.all - [paso,john,alison,jack,louise,bob]}
      its(:eligible_paternal_half_siblings) {should match_array TestModel.all - [paso,john,alison,jack,louise,bob]}
      its(:eligible_maternal_half_siblings) {should match_array TestModel.all - [paso,john,alison,jack,louise,bob]}
    end

    describe "louise" do
      subject {louise}
      its(:offspring) {should match_array [tommy, jack, debby]}
      its(:descendants) {should match_array [tommy, irene, titty, peter, jack, john, barbara, mary, debby, steve, paso, rud, mark, sam, charlie, sue]}
      its(:ancestors) {should be_empty}
      its(:great_grandchildren) {should match_array [titty, rud, mark, barbara]}
      its(:father){should be_nil}
      its(:parents){should match_array [nil,nil]}
      its(:spouses) {should match_array [larry,bob]}
      its(:eligible_spouses) {should match_array TestModel.males - [larry,bob]}
      its(:birth) {should == '1925-05-12T18:22:59-05:00'}
      its(:death) {should == '1994-03-10T18:22:59-05:00'}
      its(:age) {should == 69}
      describe "#age(:measurement => 'years')" do
        specify { louise.age(:measurement => 'year').should == 69 }
      end
      describe "#age(:measurement => 'years', :string => true)" do
        specify { louise.age({:measurement => 'year', :string =>true}).should == '69 years' }
      end
      describe "#age(:measurement => 'months')" do
        specify { louise.age(:measurement => 'months').should == 838 }
      end
      describe "#age(:measurement => 'months', :string => true)" do
        specify { louise.age({:measurement => 'months', :string =>true}).should == '69 years and 10 months' }
      end
    end

    describe "michelle" do
      subject { michelle }
      its(:family) { should match_array [michelle,naomi,julian,beatrix,paul,ned] }
    end

    describe "manuel" do
      subject { manuel }
      its(:eligible_fathers) { should match_array [ned,paso,john,rud,mark,sam,charlie,tommy,jack,luis,larry,bob,marcel] }
      its(:eligible_mothers) { should match_array [terry,naomi,michelle,titty,mia,barbara,maggie,irene,emily,debby,alison,louise,rosa,sue] }
    end

    describe "titty" do
      subject { titty }
      its(:uncles_and_aunts) { should match_array [john] }
      its(:uncles) { should match_array [john] }
      its(:paternal_uncles) { should match_array [john] }
      its(:maternal_uncles) { should match_array [] }
      its(:nieces_and_nephews) {should match_array [sam,charlie,sue]}
      its(:nephews) {should match_array [sam, charlie]}
      its(:nieces) {should match_array [sue]}
      its(:family) {should match_array [paul,peter,steve,rud,mark,irene,paso,titty]}
      its(:extended_family) {should match_array [paul,peter,steve,rud,mark,irene,paso,sam,charlie,emily,sue,tommy,jack,alison,titty,john]}
    end

    describe "irene" do
      subject { irene }
      its(:uncles_and_aunts) { should be_empty }
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
      its(:nieces_and_nephews) { should match_array [sue, sam, charlie, peter, steve] }
      describe "#nieces_and_nephews(:sex => :male)" do
        specify { expect(rud.nieces_and_nephews(:sex => :male)).to match_array [sam, charlie, peter, steve] }
      end
    end

    describe "tommy" do
      subject { tommy }
      its(:nieces_and_nephews) { should be_empty }
      describe "#nieces_and_nephews({},{:half => :include })" do
        specify { expect(tommy.nieces_and_nephews({},{:half => :include })).to match_array [paso, john] }
      end
    end

    context "when come up walter, a new individual" do

      let!(:walter) {TestModel.my_find_or_create_by({:sex => "M"},{:name => "walter"})}

      describe "walter" do
        subject {walter}
        its(:eligible_fathers) {should match_array TestModel.males - [walter]}
        its(:eligible_mothers) {should match_array TestModel.females}
        its(:eligible_offspring) {should match_array TestModel.all - [walter]}
        context "and he has nick as child" do
          let!(:nick) {TestModel.my_find_or_create_by({:sex => "M", :father_id => walter.id},{:name => "nick"} )}
          its(:eligible_fathers) {should match_array TestModel.males - [walter,nick]}
          its(:eligible_offspring) {should match_array TestModel.all - [walter,nick]}
          its(:eligible_mothers) {should match_array TestModel.females}
          context "and he has parents tommy and emily and larry, louise, luis, rosa as grandparents" do
            before(:each) do
              walter.add_father(tommy)
              walter.add_mother(emily)
              walter.add_grandparents(larry, louise, luis, rosa)
            end
            context "and he has no paternal grandparents" do
              before(:each) do
                walter.remove_paternal_grandparents
              end
              its(:eligible_paternal_grandfathers) {should match_array [ruben,larry,bob,jack,marcel,ned,manuel,paso,john,paul,julian,luis]}
              its(:eligible_paternal_grandmothers) {should match_array [emily,terry, louise, alison, rosa, maggie, barbara, mary, mia, debby, naomi, michelle, beatrix]}
              its(:eligible_maternal_grandfathers) {should match_array []}
              its(:eligible_maternal_grandmothers) {should match_array []}
            end
            context "and he has no maternal grandparents" do
              before(:each) do
                walter.remove_maternal_grandparents
              end
              its(:eligible_paternal_grandfathers) {should match_array []}
              its(:eligible_paternal_grandmothers) {should match_array []}
              its(:eligible_maternal_grandfathers) {should match_array TestModel.males - [walter,nick,rud,mark,peter,steve,sam,charlie]}
              its(:eligible_maternal_grandmothers) {should match_array TestModel.females - [emily,irene,titty,sue]}
            end
            its(:eligible_siblings) {should match_array TestModel.all - [walter,luis,rosa,larry,louise,emily,tommy,irene]}
            its(:eligible_offspring) {should match_array TestModel.all - [walter,luis,rosa,larry,louise,emily,tommy,irene,nick]}
          end

        end


      end


    end
  end

end