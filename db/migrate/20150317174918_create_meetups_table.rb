class CreateMeetupsTable < ActiveRecord::Migration

  def up
    create_table :meetups do |t|
      t.string :meetup_name, null: false
      t.string :meetup_description, null: false
      t.string :meetup_location, null: false
    end
  end

  def down
    drop_table :meetups
  end
  
end
