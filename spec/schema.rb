ActiveRecord::Schema.define(:version => 0) do

  create_table "simplest_individuals", :force => true do |t|
    t.string :name #just to be able to distinguish individuals
    t.integer :father_id
    t.integer :mother_id
  end

end