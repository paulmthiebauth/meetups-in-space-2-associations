class CreateCommentsTable < ActiveRecord::Migration
  def up
    create_table :comments do |t|
      t.integer :user_id, null: false
      t.integer :meetup_id, null: false
      t.string :body, null: false
      t.string :title
    end
  end

  def down
    drop_table :comments
  end

end
