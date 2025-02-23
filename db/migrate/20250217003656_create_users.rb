class CreateUser < ActiveRecord::Migration[8.0]
  def change
    create_table :user do |t|
      t.string :name
      t.string :email
      t.text :pass
      t.text :avatar

      t.timestamps
    end

    add_index :user, :email, unique: true
  end
end
