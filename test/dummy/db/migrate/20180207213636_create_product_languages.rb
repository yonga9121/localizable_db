class CreateProductLanguages < ActiveRecord::Migration[5.0]

  def change
    create_table :product_languages do |t|
      t.integer :localizable_object_id, index: true
      t.string :locale, null: false, default: "en"
      t.string :name
    end
  end

end
