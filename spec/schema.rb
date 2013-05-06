ActiveRecord::Schema.define(:version => 0) do

  create_table "individuals", :force => true do |t|
    t.string :name #just to be able to distinguish individuals
    t.integer :father_id
    t.integer :mother_id
  end

  create_table "individuals_with_spouse", :force => true do |t|
    t.string :name #just to be able to distinguish individuals
    t.integer :father_id
    t.integer :mother_id
    t.integer :spouse_id
  end

  create_table "individuals_with_custom_parent_cols", :force => true do |t|
    t.string :name #just to be able to distinguish individuals
    t.integer :padre
    t.integer :madre
    t.integer :partner
  end

end