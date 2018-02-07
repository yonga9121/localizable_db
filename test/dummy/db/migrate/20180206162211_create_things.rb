class CreateThings < ActiveRecord::Migration[5.0]
  def change
    create_table :things do |t|
      t.references :product, foreign_key: true
      t.string :name

      t.timestamps
    end
    create_table :thing_languages do |t|
      t.integer :localizable_object_id, foreign_key: true
      t.string :locale
      t.string :name
    end
  end
end
