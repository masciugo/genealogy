shared_context 'unreleted people exist' do
  
  people = [
    {name: "agata", sex: "F"},
    {name: "alison", sex: "F"},
    {name: "barbara", sex: "F"},
    {name: "beatrix", sex: "F"},
    {name: "bob", sex: "M"},
    {name: "charlie", sex: "M"},
    {name: "debby", sex: "F"},
    {name: "dylan", sex: "M"},
    {name: "emily", sex: "F"},
    {name: "irene", sex: "F"},
    {name: "jack", sex: "M"},
    {name: "john", sex: "M"},
    {name: "julian", sex: "M"},
    {name: "larry", sex: "M"},
    {name: "louise", sex: "F"},
    {name: "luis", sex: "M"},
    {name: "maggie", sex: "F"},
    {name: "manuel", sex: "M"},
    {name: "marcel", sex: "M"},
    {name: "mark", sex: "M"},
    {name: "mary", sex: "F"},
    {name: "mia", sex: "F"},
    {name: "michelle", sex: "F"},
    {name: "naomi", sex: "F"},
    {name: "ned", sex: "M"},
    {name: "nick", sex: "M"},
    {name: "paso", sex: "M"},
    {name: "paul", sex: "M"},
    {name: "peter", sex: "M"},
    {name: "rosa", sex: "F"},
    {name: "ruben", sex: "M"},
    {name: "rud", sex: "M"},
    {name: "sam", sex: "M"},
    {name: "steve", sex: "M"},
    {name: "sue", sex: "F"},
    {name: "terry", sex: "F"},
    {name: "titty", sex: "F"},
    {name: "tommy", sex: "M"},
    {name: "walter", sex: "M"}
  ]
  people.each{|person| let(person[:name]) { @model.my_find_by_name(person[:name])} }

  before do
    # puts 'creating people'
    DatabaseCleaner.clean
    @model.create! people
  end

end

shared_context "releted people exist" do

  include_context 'unreleted people exist'

  before do
    # puts 'linking people'
    barbara.update_attributes(father_id: john.id, mother_id: maggie.id)
    beatrix.update_attributes(father_id: paul.id, mother_id: michelle.id)
    charlie.update_attributes(father_id: mark.id, mother_id: mia.id)
    debby.update_attributes(father_id: bob.id, mother_id: louise.id)
    emily.update_attributes(father_id: luis.id, mother_id: rosa.id)
    irene.update_attributes(father_id: tommy.id, mother_id: emily.id, current_spouse_id: paso.id)
    jack.update_attributes(father_id: bob.id, mother_id: louise.id)
    john.update_attributes(father_id: jack.id, mother_id: alison.id)
    julian.update_attributes(father_id: paul.id, mother_id: michelle.id)
    mark.update_attributes(father_id: paso.id, mother_id: irene.id)
    mary.update_attributes(father_id: paul.id, mother_id: barbara.id)
    michelle.update_attributes(father_id: ned.id, mother_id: naomi.id, current_spouse_id: paul.id)
    paso.update_attributes(father_id: jack.id, mother_id: alison.id, current_spouse_id: irene.id )
    paul.update_attributes(father_id: manuel.id, mother_id: terry.id, current_spouse_id: michelle.id)
    peter.update_attributes(father_id: paul.id, mother_id: titty.id)
    ruben.update_attributes(father_id: paul.id)
    rud.update_attributes(father_id: paso.id, mother_id: irene.id)
    sam.update_attributes(father_id: mark.id, mother_id: mia.id)
    steve.update_attributes(father_id: paul.id, mother_id: titty.id)
    sue.update_attributes(father_id: mark.id, mother_id: mia.id)
    terry.update_attributes(father_id: marcel.id)
    titty.update_attributes(father_id: paso.id, mother_id: irene.id)
    tommy.update_attributes(father_id: larry.id, mother_id: louise.id)
  end
end

shared_context "unreleted people exist with dates" do

  include_context 'unreleted people exist'

  before do
    # puts 'assigne dates people'
    alison.update_attributes(birth_date: Date.new(1920,8,10),death_date: Date.new(2012,10,4))
    barbara.update_attributes(birth_date: Date.new(1974,12,10))
    beatrix.update_attributes(birth_date: Date.new(2003,5,6))
    bob.update_attributes(death_date: Date.new(1949,5,6))
    charlie.update_attributes(birth_date: Date.new(2012,12,3))
    debby.update_attributes(birth_date: Date.new(1920,2,1))
    emily.update_attributes(birth_date: Date.new(1903,1,6),death_date: Date.new(1944,4,6))
    irene.update_attributes(birth_date: Date.new(1847,3,10),death_date: Date.new(1980,5,4))
    jack.update_attributes(birth_date: Date.new(1915,10,1),death_date: Date.new(1960,7,3))
    john.update_attributes(birth_date: Date.new(1948,12,4))
    julian.update_attributes(birth_date: Date.new(2000,2,3))
    larry.update_attributes(birth_date: Date.new(1870,9,3),death_date: Date.new(1900,4,6))
    louise.update_attributes(birth_date: Date.new(1874,4,10),death_date: Date.new(1930,8,7))
    # luis.update_attributes(birth_date: Date.new(1890,5,4))
    maggie.update_attributes(birth_date: Date.new(1952,4,17),death_date: Date.new(1979,6,6))
    manuel.update_attributes(birth_date: Date.new(1938,9,13))
    marcel.update_attributes(birth_date: Date.new(1902,5,1))
    mark.update_attributes(birth_date: Date.new(1980,5,4))
    mary.update_attributes(birth_date: Date.new(2011,4,10),death_date: Date.new(2011,4,15))
    mia.update_attributes(birth_date: Date.new(1985,1,10),death_date: Date.new(2013,12,8))
    michelle.update_attributes(birth_date: Date.new(1980,7,6))
    naomi.update_attributes(birth_date: Date.new(1950,11,6))
    ned.update_attributes(birth_date: Date.new(1930,5,1),death_date: Date.new(1972,7,3))
    paso.update_attributes(birth_date: Date.new(1945,1,4))
    paul.update_attributes(birth_date: Date.new(1970,3,3))
    peter.update_attributes(birth_date: Date.new(2005,10,3))
    rosa.update_attributes(birth_date: Date.new(1885,10,6),death_date: Date.new(1935,5,5))
    ruben.update_attributes(birth_date: Date.new(1996,2,3),death_date: Date.new(2010,5,18))
    rud.update_attributes(birth_date: Date.new(1970,5,3))
    sam.update_attributes(birth_date: Date.new(2010,9,3))
    steve.update_attributes(birth_date: Date.new(2009,5,3))
    sue.update_attributes(birth_date: Date.new(1999,2,10))
    terry.update_attributes(birth_date: Date.new(1940,10,16),death_date: Date.new(1985,2,7))
    titty.update_attributes(death_date: Date.new(2010,8,6))
    tommy.update_attributes(birth_date: Date.new(1895,12,9),death_date: Date.new(1993,12,12))
  end
end

