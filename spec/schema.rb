ActiveRecord::Schema.define(:version => 0) do

  create_table "simplest_individuals", :force => true do |t|
    t.string :name #just to distinguish among individuals
    t.integer :father_id
    t.integer :mother_id
  end

end