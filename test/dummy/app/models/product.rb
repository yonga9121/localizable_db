class Product < ApplicationRecord

  localize [:name, :desc]

  has_many :things, class_name: "Thing", foreign_key: "product_id", inverse_of: :product

end
