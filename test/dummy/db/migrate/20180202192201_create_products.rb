class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      t.string :name
      t.text :desc

      t.timestamps
    end

    create_table :product_languages do |t|
      t.string :name
      t.text :desc
      t.integer :localizable_object_id
      t.string :locale
    end

  end
end
