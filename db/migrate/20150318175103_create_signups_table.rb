class CreateSignupsTable < ActiveRecord::Migration

    def up
      create_table :signups do |t|
        t.integer :user_id, null: false
        t.integer :meetup_id, null: false
      end
    end

    def down
      drop_table :signups
    end

end
