require 'spec_helper'

module QueryMethodsSpec
  extend GenealogyTestModel
  
  describe "*** Query methods ***", :wip => true do

    before(:all) do
      QueryMethodsSpec.define_test_model_class({:spouse => true })
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

    describe "class methods" do
      describe "#males" do
        specify { TestModel.males.all.should =~ [paul, peter, paso, manuel, john, jack, bob, tommy, luis, larry, ned, steve, marcel, julian, rud, mark, sam, charlie] }
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
      its(:half_siblings) {should =~ [mary, julian, beatrix]}
      its(:ancestors) {should =~ [paul, titty, manuel, terry, paso, irene, tommy, emily, larry, louise, luis, rosa, marcel, bob, jack, alison]}
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
      its(:half_siblings) { should =~ [peter, julian, beatrix, steve] }
      its(:descendants) {should be_empty}
      its(:siblings) { should_not include peter }
      its(:ancestors) {should =~ [paul, barbara, manuel, terry, john, maggie, marcel, jack, alison, bob, louise]}
    end

    describe "beatrix" do
      subject {beatrix}
      its(:parents) {should =~ [paul, michelle]}
      its(:siblings) {should =~ [julian]}
      its(:half_siblings) {should =~ [peter, steve, mary]}
      its(:paternal_half_siblings) {should =~ [peter, steve, mary]}
      describe "all half_siblings and siblings: #siblings(:half => :include)" do
        specify {beatrix.siblings(:half => :include).should =~ [peter, steve, mary, julian]}
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
      its(:offspring) {should =~ [peter, mary, julian, beatrix, steve]}
      describe "#offspring(:spouse => barbara)" do
        specify { paul.offspring(:spouse => barbara).should =~ [mary] }
      end
      describe "#offspring(:spouse => michelle)" do
        specify { paul.offspring(:spouse => michelle).should =~ [julian, beatrix] }
      end
      its(:descendants) {should =~ [peter, mary, julian, beatrix, steve]}
      its(:ancestors) {should =~ [manuel, terry, marcel]}
      its(:maternal_grandmother) {should be_nil}
      its(:maternal_grandparents) {should =~ [marcel, nil]}
      its(:grandparents) {should =~ [nil, nil, marcel, nil]}
    end

    describe "terry" do
      subject {terry}
      its(:father) {should == marcel}
      its(:mother) {should be_nil}
      its(:parents) {should =~ [marcel, nil]}
      its(:ancestors) {should =~ [marcel]}
    end

    describe "barbara" do
      subject {barbara}
      its(:offspring) {should =~ [mary]}
      describe "offspring with manuel" do
        specify { barbara.offspring(:spouse => manuel).should be_empty }
      end
      its(:descendants) {should =~ [mary]}
      its(:grandparents) {should =~ [jack, alison, nil, nil]}
    end
    
    describe "paso" do
      subject {paso}
      its(:offspring) {should =~ [titty, rud, mark]}
      its(:descendants) {should =~ [titty, peter, steve, rud, mark, sam, charlie]}
      its(:family) { should =~ [irene,paso,jack,alison,john,titty,rud,mark] }
      its(:extended_family) { should =~ [irene,paso,jack,alison,john,titty,rud,mark,louise,bob,debby,barbara,charlie,sam,peter,steve] }
    end

    describe "louise" do
      subject {louise}
      its(:offspring) {should =~ [tommy, jack, debby]}
      its(:descendants) {should =~ [tommy, irene, titty, peter, jack, john, barbara, mary, debby, steve, paso, rud, mark, sam, charlie]}
      its(:ancestors) {should be_empty}
      its(:father){should be_nil}
      its(:parents){should be_empty}
    end

    describe "michelle" do
      subject { michelle }
      its(:family) { should =~ [michelle,naomi,julian,beatrix,paul,ned] }
    end


    # context "when come up walter, a new individual", :wip => true do

    #   let!(:walter) {TestModel.find_or_create_by_name(:name => "walter", :sex => "M")}
      
    #   describe "walter" do
    #     subject {walter}
    #     its(:eligible_fathers) {should =~ TestModel.males - [walter]}
    #     its(:eligible_mothers) {should =~ TestModel.females}
    #     context "when he has parents tommy and emily" do
    #       before(:each) do
    #         walter.add_father(tommy)
    #         walter.add_mother(emily)
    #         walter.remove_grandparents
    #       end
    #       its(:eligible_grandfathers) {should =~ [paso, julian, paul, ned, manuel, john, jack, marcel, bob, larry, luis]}
    #       its(:eligible_grandmothers) {should =~ [beatrix, mary, michelle, barbara, naomi, terry, maggie, debby, alison, rosa, louise]}
    #       context "when she also has grandparents" do
    #         before(:each) do
    #           walter.add_grandparents(larry, louise, luis, rosa)
    #         end
    #         its(:eligible_siblings) {should =~ [bob, debby, jack, alison, john, maggie, barbara, paso, mary, paul, michelle, julian, beatrix, naomi, ned, manuel, terry, marcel]}
    #       end    
    #     end
    #   end


    # end
  end

end