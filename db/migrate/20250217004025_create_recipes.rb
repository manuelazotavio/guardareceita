class CreateRecipes < ActiveRecord::Migration[8.0]
  def change
    create_table :recipes do |t|
      t.string :name
      t.integer :rating
      t.string :image
      t.string :portions
      t.references :user, null: false, foreign_key: true
      t.text :description
      t.string :time
      t.string :instruction
      t.string :ingredients

      t.timestamps
    end
  end
end
