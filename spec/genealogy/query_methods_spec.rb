require 'spec_helper'

module QueryMethodsSpec
  extend GenealogyTestModel
  
  describe "*** Query methods ***" do

    before(:all) do
      QueryMethodsSpec.define_test_model_class({:current_spouse => true })
    end

    let!(:paul) {TestModel.find_or_create_by_name(:name => "paul", :sex => "M", :father_id => manuel.id, :mother_id => terry.id)}
    let!(:titty) {TestModel.find_or_create_by_name(:name => "titty", :sex => "F", :father_id => paso.id, :mother_id => irene.id)}
    let!(:rud) {TestModel.find_or_create_by_name(:name => "rud", :sex => "M", :father_id => paso.id, :mother_id => irene.id)}
    let!(:mark) {TestModel.find_or_create_by_name(:name => "mark", :sex => "M", :father_id => paso.id, :mother_id => irene.id)}
    let!(:peter) {TestModel.find_or_create_by_name(:name => "peter", :sex => "M", :father_id => paul.id, :mother_id => titty.id)}
    let!(:mary) {TestModel.find_or_create_by_name(:name => "mary", :sex => "F", :father_id => paul.id, :mother_id => barbara.id)}
    let!(:mia) {TestModel.find_or_create_by_name(:name => "mia", :sex => "F")}
    let!(:sam) {TestModel.find_or_create_by_name(:name => "sam", :sex => "M", :father_id => mark.id, :mother_id => mia.id)}
    let!(:charlie) {TestModel.find_or_create_by_name(:name => "charlie", :sex => "M", :father_id => mark.id, :mother_id => mia.id)}
    let!(:barbara) {TestModel.find_or_create_by_name(:name => "barbara", :sex => "F", :father_id => john.id, :mother_id => maggie.id)}
    let!(:paso) {TestModel.find_or_create_by_name(:name => "paso", :sex => "M", :father_id => jack.id, :mother_id => alison.id)}
    let!(:irene) {TestModel.find_or_create_by_name(:name => "irene", :sex => "F", :father_id => tommy.id, :mother_id => emily.id)}
    let!(:manuel) {TestModel.find_or_create_by_name(:name => "manuel", :sex => "M")}
    let!(:terry) {TestModel.find_or_create_by_name(:name => "terry", :sex => "F", :father_id => marcel.id)}
    let!(:john) {TestModel.find_or_create_by_name(:name => "john", :sex => "M", :father_id => jack.id, :mother_id => alison.id)}
    let!(:jack) {TestModel.find_or_create_by_name(:name => "jack", :sex => "M", :father_id => bob.id, :mother_id => louise.id)}
    let!(:bob) {TestModel.find_or_create_by_name(:name => "bob", :sex => "M")}
    let!(:debby) {TestModel.find_or_create_by_name(:name => "debby", :sex => "F", :father_id => bob.id, :mother_id => louise.id)}
    let!(:alison) {TestModel.find_or_create_by_name(:name => "alison", :sex => "F")}
    let!(:maggie) {TestModel.find_or_create_by_name(:name => "maggie", :sex => "F")}
    let!(:emily) {TestModel.find_or_create_by_name(:name => "emily", :sex => "F", :father_id => luis.id, :mother_id => rosa.id)}
    let!(:tommy) {TestModel.find_or_create_by_name(:name => "tommy", :sex => "M", :father_id => larry.id, :mother_id => louise.id)}
    let!(:luis) {TestModel.find_or_create_by_name(:name => "luis", :sex => "M")}
    let!(:rosa) {TestModel.find_or_create_by_name(:name => "rosa", :sex => "F")}
    let!(:larry) {TestModel.find_or_create_by_name(:name => "larry", :sex => "M")}
    let!(:louise) {TestModel.find_or_create_by_name(:name => "louise", :sex => "F")}
    let!(:ned) {TestModel.find_or_create_by_name(:name => "ned", :sex => "M")}
    let!(:steve) {TestModel.find_or_create_by_name(:name => "steve", :sex => "M", :father_id => paul.id, :mother_id => titty.id)}
    let!(:naomi) {TestModel.find_or_create_by_name(:name => "naomi", :sex => "F")}
    let!(:michelle) {TestModel.find_or_create_by_name(:name => "michelle", :sex => "F", :father_id => ned.id, :mother_id => naomi.id)}
    let!(:marcel) {TestModel.find_or_create_by_name(:name => "marcel", :sex => "M")}
    let!(:beatrix) {TestModel.find_or_create_by_name(:name => "beatrix", :sex => "F", :father_id => paul.id, :mother_id => michelle.id)}
    let!(:julian) {TestModel.find_or_create_by_name(:name => "julian", :sex => "M", :father_id => paul.id, :mother_id => michelle.id)}
    let!(:ruben) {TestModel.find_or_create_by_name(:name => "ruben", :sex => "M", :father_id => paul.id)}

    describe "class methods" do
      describe "#males" do
        specify { TestModel.males.all.should =~ [ruben, paul, peter, paso, manuel, john, jack, bob, tommy, luis, larry, ned, steve, marcel, julian, rud, mark, sam, charlie] }
      end

      describe "#females" do
        specify { TestModel.females.all.should =~ [titty, mary, barbara, irene, terry, debby, alison, maggie, emily, rosa, louise, naomi, michelle, beatrix, mia] }
      end
    end

    describe "peter" do
      subject {peter}
      its(:parents) {should =~ [paul, titty]}
      its(:paternal_grandfather) {should == manuel}
      its(:paternal_grandmother) {should == terry}
      its(:maternal_grandfather) {should == paso}
      its(:maternal_grandmother) {should == irene}
      its(:grandparents) {should =~ [manuel, terry, paso, irene]}
      its(:siblings) {should =~ [steve]}
      its(:paternal_grandparents) {should =~ [manuel, terry]}
      its(:maternal_grandparents) {should =~ [paso, irene]}
      its(:half_siblings) {should =~ [ruben, mary, julian, beatrix]}
      its(:ancestors) {should =~ [paul, titty, manuel, terry, paso, irene, tommy, emily, larry, louise, luis, rosa, marcel, bob, jack, alison]}
      its(:eligible_fathers) {should =~ []}
      its(:family_hash) { should be_a(Hash) }
      
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
        specify { should =~ [ruben, mary, julian, beatrix] } 
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
      its(:parents) {should =~ [paul, barbara]}
      its(:paternal_grandfather) {should == manuel}
      its(:paternal_grandmother) {should == terry}
      its(:maternal_grandfather) {should == john}
      its(:maternal_grandmother) {should == maggie}
      its(:paternal_grandparents) {should =~ [manuel, terry]}
      its(:maternal_grandparents) {should =~ [john, maggie]}
      its(:grandparents) {should =~ [manuel, terry, john, maggie]}
      its(:half_siblings) { should =~ [ruben, peter, julian, beatrix, steve] }
      its(:descendants) {should be_empty}
      its(:siblings) { should_not include peter }
      its(:ancestors) {should =~ [paul, barbara, manuel, terry, john, maggie, marcel, jack, alison, bob, louise]}
    end

    describe "beatrix" do
      subject {beatrix}
      its(:parents) {should =~ [paul, michelle]}
      its(:siblings) {should =~ [julian]}
      its(:half_siblings) {should =~ [ruben, peter, steve, mary]}
      its(:paternal_half_siblings) {should =~ [ruben, peter, steve, mary]}
      describe "all half_siblings and siblings: #siblings(:half => :include)" do
        specify {beatrix.siblings(:half => :include).should =~ [ruben, peter, steve, mary, julian]}
      end  
      describe "half_siblings with titty: #siblings(:half => father, :spouse => titty)" do
        specify {beatrix.siblings(:half => :father, :spouse => titty).should =~ [peter, steve]}
      end
      describe "half_siblings with mary: #siblings(:half => father, :spouse => barbara)" do
        specify {beatrix.siblings(:half => :father, :spouse => barbara).should =~ [mary]}
      end  
    end

    describe "paul" do
      subject {paul}
      its(:parents) {should =~ [manuel, terry]}
      its(:offspring) {should =~ [ruben, peter, mary, julian, beatrix, steve]}
      describe "#offspring(:spouse => barbara)" do
        specify { paul.offspring(:spouse => barbara).should =~ [mary] }
      end
      describe "#offspring(:spouse => michelle)" do
        specify { paul.offspring(:spouse => michelle).should =~ [julian, beatrix] }
      end
      describe "offspring with unknown mother" do
        specify { paul.offspring(:spouse => nil).should =~ [ruben] }
      end
      its(:descendants) {should =~ [ruben, peter, mary, julian, beatrix, steve]}
      its(:ancestors) {should =~ [manuel, terry, marcel]}
      its(:maternal_grandmother) {should be_nil}
      its(:maternal_grandparents) {should =~ [marcel, nil]}
      its(:grandparents) {should =~ [nil, nil, marcel, nil]}
      its(:eligible_paternal_grandfathers) {should =~ [sam,charlie,mark,rud,john,paso,ned,marcel,tommy,jack,luis,larry,bob]}
      its(:spouses) {should =~ [michelle,titty,barbara,nil]}
      its(:eligible_spouses) {should =~ TestModel.females - [michelle,titty,barbara]}
    end

    describe "terry" do
      subject {terry}
      its(:father) {should == marcel}
      its(:mother) {should be_nil}
      its(:parents) {should =~ [marcel, nil]}
      its(:ancestors) {should =~ [marcel]}
      its(:grandchildren) {should =~ [ruben, julian,beatrix,peter,steve,mary]}
    end

    describe "barbara" do
      subject {barbara}
      its(:offspring) {should =~ [mary]}
      describe "offspring with manuel" do
        specify { barbara.offspring(:spouse => manuel).should be_empty }
      end
      its(:descendants) {should =~ [mary]}
      its(:grandparents) {should =~ [jack, alison, nil, nil]}
      its(:eligible_offspring) {should =~ TestModel.all - [mary,barbara,john,maggie,jack,alison,louise,bob]}
    end
    
    describe "paso" do
      subject {paso}
      its(:offspring) {should =~ [titty, rud, mark]}
      its(:descendants) {should =~ [titty, peter, steve, rud, mark, sam, charlie]}
      its(:family) { should =~ [irene,paso,jack,alison,john,titty,rud,mark] }
      its(:extended_family) { should =~ [irene,paso,jack,alison,john,titty,rud,mark,louise,bob,debby,barbara,charlie,sam,peter,steve] }
      its(:eligible_siblings) {should =~ TestModel.all - [paso,john,alison,jack,louise,bob]}
      its(:eligible_half_siblings) {should =~ TestModel.all - [paso,john,alison,jack,louise,bob]}
      its(:eligible_paternal_half_siblings) {should =~ TestModel.all - [paso,john,alison,jack,louise,bob]}
      its(:eligible_maternal_half_siblings) {should =~ TestModel.all - [paso,john,alison,jack,louise,bob]}
    end

    describe "louise" do
      subject {louise}
      its(:offspring) {should =~ [tommy, jack, debby]}
      its(:descendants) {should =~ [tommy, irene, titty, peter, jack, john, barbara, mary, debby, steve, paso, rud, mark, sam, charlie]}
      its(:ancestors) {should be_empty}
      its(:father){should be_nil}
      its(:parents){should =~ [nil,nil]}
      its(:spouses) {should =~ [larry,bob]}
      its(:eligible_spouses) {should =~ TestModel.males - [larry,bob]}
    end

    describe "michelle" do
      subject { michelle }
      its(:family) { should =~ [michelle,naomi,julian,beatrix,paul,ned] }
    end

    describe "manuel" do
      subject { manuel }
      its(:eligible_fathers) { should =~ [ned,paso,john,rud,mark,sam,charlie,tommy,jack,luis,larry,bob,marcel] }
      its(:eligible_mothers) { should =~ [terry,naomi,michelle,titty,mia,barbara,maggie,irene,emily,debby,alison,louise,rosa] }
    end

    describe "titty" do
      subject { titty }
      its(:uncles_and_aunts) { should =~ [john] }
      its(:nieces_and_nephews) {should =~ [sam,charlie]}
      its(:family) {should =~ [paul,peter,steve,rud,mark,irene,paso,titty]}
      its(:extended_family) {should =~ [paul,peter,steve,rud,mark,irene,paso,sam,charlie,emily,tommy,jack,alison,titty,john]}
    end

    context "when come up walter, a new individual" do

      let!(:walter) {TestModel.find_or_create_by_name(:name => "walter", :sex => "M")}
      
      describe "walter" do
        subject {walter}
        its(:eligible_fathers) {should =~ TestModel.males - [walter]}
        its(:eligible_mothers) {should =~ TestModel.females}
        its(:eligible_offspring) {should =~ TestModel.all - [walter]}
        context "and he has nick as child" do
          let!(:nick) {TestModel.find_or_create_by_name(:name => "nick", :sex => "M", :father_id => walter.id )}
          its(:eligible_fathers) {should =~ TestModel.males - [walter,nick]}
          its(:eligible_offspring) {should =~ TestModel.all - [walter,nick]}
          its(:eligible_mothers) {should =~ TestModel.females}
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
              its(:eligible_paternal_grandfathers) {should =~ [ruben, larry,bob,jack,marcel,ned,manuel,paso,john,paul,julian,luis]}
              its(:eligible_paternal_grandmothers) {should =~ [emily,terry, louise, alison, rosa, maggie, barbara, mary, mia, debby, naomi, michelle, beatrix]}
              its(:eligible_maternal_grandfathers) {should =~ []}
              its(:eligible_maternal_grandmothers) {should =~ []}
            end
            context "and he has no maternal grandparents" do
              before(:each) do
                walter.remove_maternal_grandparents
              end
              its(:eligible_paternal_grandfathers) {should =~ []}
              its(:eligible_paternal_grandmothers) {should =~ []}
              its(:eligible_maternal_grandfathers) {should =~ TestModel.males - [walter,nick,rud,mark,peter,steve,sam,charlie]}
              its(:eligible_maternal_grandmothers) {should =~ TestModel.females - [emily,irene,titty]}
            end
            its(:eligible_siblings) {should =~ TestModel.all - [walter,luis,rosa,larry,louise,emily,tommy,irene]}
            its(:eligible_offspring) {should =~ TestModel.all - [walter,luis,rosa,larry,louise,emily,tommy,irene,nick]}
          end

        end


      end


    end
  end

end