shared_context 'unreleted people exist' do
  
  people = [
    {name: "paul", sex: "M"},
    {name: "manuel", sex: "M"},
    {name: "paso", sex: "M"},
    {name: "steve", sex: "M"},
    {name: "peter", sex: "M"},
    {name: "john", sex: "M"},
    {name: "julian", sex: "M"},
    {name: "dylan", sex: "M"},
    {name: "walter", sex: "M"},
    {name: "rud", sex: "M"},
    {name: "mark", sex: "M"},
    {name: "sam", sex: "M"},
    {name: "charlie", sex: "M"},
    {name: "jack", sex: "M"},
    {name: "bob", sex: "M"},
    {name: "tommy", sex: "M"},
    {name: "luis", sex: "M"},
    {name: "larry", sex: "M"},
    {name: "ned", sex: "M"},
    {name: "marcel", sex: "M"},
    {name: "ruben", sex: "M"},
    {name: "nick", sex: "M"},
    {name: "terry", sex: "F"},
    {name: "titty", sex: "F"},
    {name: "irene", sex: "F"},
    {name: "michelle", sex: "F"},
    {name: "maggie", sex: "F"},
    {name: "agata", sex: "F"},
    {name: "barbara", sex: "F"},
    {name: "mary", sex: "F"},
    {name: "mia", sex: "F"},
    {name: "sue", sex: "F"},
    {name: "debby", sex: "F"},
    {name: "alison", sex: "F"},
    {name: "emily", sex: "F"},
    {name: "rosa", sex: "F"},
    {name: "louise", sex: "F"},
    {name: "naomi", sex: "F"},
    {name: "beatrix", sex: "F"}
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
    paul.update_attributes(father_id: manuel.id, mother_id: terry.id, current_spouse_id: michelle.id)
    titty.update_attributes(father_id: paso.id, mother_id: irene.id)
    rud.update_attributes(father_id: paso.id, mother_id: irene.id)
    mark.update_attributes(father_id: paso.id, mother_id: irene.id)
    peter.update_attributes(father_id: paul.id, mother_id: titty.id)
    mary.update_attributes(father_id: paul.id, mother_id: barbara.id)
    sam.update_attributes(father_id: mark.id, mother_id: mia.id)
    sue.update_attributes(father_id: mark.id, mother_id: mia.id)
    charlie.update_attributes(father_id: mark.id, mother_id: mia.id)
    barbara.update_attributes(father_id: john.id, mother_id: maggie.id)
    paso.update_attributes(father_id: jack.id, mother_id: alison.id, current_spouse_id: irene.id )
    irene.update_attributes(father_id: tommy.id, mother_id: emily.id, current_spouse_id: paso.id)
    terry.update_attributes(father_id: marcel.id)
    john.update_attributes(father_id: jack.id, mother_id: alison.id)
    jack.update_attributes(father_id: bob.id, mother_id: louise.id)
    debby.update_attributes(father_id: bob.id, mother_id: louise.id)
    emily.update_attributes(father_id: luis.id, mother_id: rosa.id)
    tommy.update_attributes(father_id: larry.id, mother_id: louise.id)
    steve.update_attributes(father_id: paul.id, mother_id: titty.id)
    michelle.update_attributes(father_id: ned.id, mother_id: naomi.id, current_spouse_id: paul.id)
    beatrix.update_attributes(father_id: paul.id, mother_id: michelle.id)
    julian.update_attributes(father_id: paul.id, mother_id: michelle.id)
    ruben.update_attributes(father_id: paul.id)
  end
end