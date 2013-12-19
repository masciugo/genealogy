require 'spec_helper'

module QueryMethodsSpec
  extend GenealogyTestModel
  
  describe "*** Query methods ***" do

    before(:all) do
      QueryMethodsSpec.define_test_model_class({:current_spouse => true })
    end

    let!(:paul) {TestModel.create_with(:sex => "M", :father_id => manuel.id, :mother_id => terry.id).find_or_create_by(:name => "paul")}
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

    describe "class methods" do
      describe "#males" do
        specify { TestModel.males.all.should match_array [ruben, paul, peter, paso, manuel, john, jack, bob, tommy, luis, larry, ned, steve, marcel, julian, rud, mark, sam, charlie] }
      end

      describe "#females" do
        specify { TestModel.females.all.should match_array [titty, mary, barbara, irene, terry, debby, alison, maggie, emily, rosa, louise, naomi, michelle, beatrix, mia] }
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
      its(:descendants) {should match_array [titty, peter, steve, rud, mark, sam, charlie]}
      its(:family) { should match_array [irene,paso,jack,alison,john,titty,rud,mark] }
      its(:extended_family) { should match_array [irene,paso,jack,alison,john,titty,rud,mark,louise,bob,debby,barbara,charlie,sam,peter,steve] }
      its(:eligible_siblings) {should match_array TestModel.all - [paso,john,alison,jack,louise,bob]}
      its(:eligible_half_siblings) {should match_array TestModel.all - [paso,john,alison,jack,louise,bob]}
      its(:eligible_paternal_half_siblings) {should match_array TestModel.all - [paso,john,alison,jack,louise,bob]}
      its(:eligible_maternal_half_siblings) {should match_array TestModel.all - [paso,john,alison,jack,louise,bob]}
    end

    describe "louise" do
      subject {louise}
      its(:offspring) {should match_array [tommy, jack, debby]}
      its(:descendants) {should match_array [tommy, irene, titty, peter, jack, john, barbara, mary, debby, steve, paso, rud, mark, sam, charlie]}
      its(:ancestors) {should be_empty}
      its(:father){should be_nil}
      its(:parents){should match_array [nil,nil]}
      its(:spouses) {should match_array [larry,bob]}
      its(:eligible_spouses) {should match_array TestModel.males - [larry,bob]}
    end

    describe "michelle" do
      subject { michelle }
      its(:family) { should match_array [michelle,naomi,julian,beatrix,paul,ned] }
    end

    describe "manuel" do
      subject { manuel }
      its(:eligible_fathers) { should match_array [ned,paso,john,rud,mark,sam,charlie,tommy,jack,luis,larry,bob,marcel] }
      its(:eligible_mothers) { should match_array [terry,naomi,michelle,titty,mia,barbara,maggie,irene,emily,debby,alison,louise,rosa] }
    end

    describe "titty" do
      subject { titty }
      its(:uncles_and_aunts) { should match_array [john] }
      its(:nieces_and_nephews) {should match_array [sam,charlie]}
      its(:family) {should match_array [paul,peter,steve,rud,mark,irene,paso,titty]}
      its(:extended_family) {should match_array [paul,peter,steve,rud,mark,irene,paso,sam,charlie,emily,tommy,jack,alison,titty,john]}
    end

    context "when come up walter, a new individual" do

      let!(:walter) {TestModel.create_with(:sex => "M").find_or_create_by(:name => "walter")}
      
      describe "walter" do
        subject {walter}
        its(:eligible_fathers) {should match_array TestModel.males - [walter]}
        its(:eligible_mothers) {should match_array TestModel.females}
        its(:eligible_offspring) {should match_array TestModel.all - [walter]}
        context "and he has nick as child" do
          let!(:nick) {TestModel.create_with(:sex => "M", :father_id => walter.id ).find_or_create_by(:name => "nick")}
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
              its(:eligible_maternal_grandmothers) {should match_array TestModel.females - [emily,irene,titty]}
            end
            its(:eligible_siblings) {should match_array TestModel.all - [walter,luis,rosa,larry,louise,emily,tommy,irene]}
            its(:eligible_offspring) {should match_array TestModel.all - [walter,luis,rosa,larry,louise,emily,tommy,irene,nick]}
          end

        end


      end


    end
  end

end