class Product < ApplicationRecord

  include LocalizableDb::Localizable

  localize [:name, :desc]

end
