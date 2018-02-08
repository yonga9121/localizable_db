class Product < ApplicationRecord
	localize [:name]
	has_many :things, class_name: "Thing", foreign_key: "product_id"
	validates :name, presence: true

	accepts_nested_attributes_for :things
end
