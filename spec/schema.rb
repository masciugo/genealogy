ActiveRecord::Schema.define(:version => 0) do

  create_table "simplest_individuals", :force => true do |t|
    t.integer :father_id
    t.integer :mother_id
  end

end