# LocalizableDb
Rails gem to localize your database.

If your application manage something like products or services that can be created dynamically, and you have to support multiple languages you may need to localize your database. LocalizableDb allow you to do that in a simple way.

## Usage

I18n Integration.
````ruby
Product.find(1) #=> #<Product id: 1, name: "luck">
Product.where(id: 1)
#=> <ActiveRecord::Relation [#<Product id: 1, name: "luck">]>

I18n.locale = :es

Product.l.find(1) #=> <Product id: 1, name: "suerte">
Product.l.where(id: 1)
#=> <ActiveRecord::Relation [#<Product id: 1, name: "suerte">]>

````
Specify the language you want

````ruby
Product.find(1) #=> <Product id: 1, name: "luck">
Product.where(id: 1)
#=> <ActiveRecord::Relation [#<Product id: 1, name: "luck">]>

Product.l(:es).find(1) #=> <Product id: 1, name: "suerte">
Product.find(1).l(:es) #=> <Product id: 1, name: "suerte">
Product.l(:es).where(id: 1)
#=> <ActiveRecord::Relation [#<Product id: 1, name: "suerte">]>

Product.l(:pt).find(1) #=> <Product id: 1, name: "sortudo">
Product.find(1).l(:pt) #=> <Product id: 1, name: "sortudo">
Product.l(:pt).where(id: 1)
#=> <ActiveRecord::Relation [#<Product id: 1, name: "sortudo">]>

Product.l(:fr).find(1) #=> <Product id: 1, name: "heureux">
Product.find(1).l(:fr) #=> <Product id: 1, name: "heureux">
Product.l(:fr).where(id: 1)
#=> <ActiveRecord::Relation [#<Product id: 1, name: "heureux">]>
````
Localize multiple languages
````ruby
products = Product.where(id: 1)
products.inspect
#=> <ActiveRecord::Relation [#<Product id: 1, name: "luck">]>
products = Product.wl(:es,:pt,:fr).where(id: 1)
products.inspect
#=> <ActiveRecord::Relation [#<Product id: 1, name: "luck", es_name: "suerte", pt_name: "sortudo", fr_name: "heureux">]>

products.first.name #=> luck
products.first.attributes["es_name"] #=> suerte
products.first.attributes["pt_name"] #=> sortudo
products.first.attributes["fr_name"] #=> heureux
````
Creating
````ruby
Product.create(name: "something", languages: {
	es: {name: "algo"},
    pt: {name: "alguma cosia"},
    fr: {name: "quelque chose"}
})
#=> #<Product id:2, name: "something">
````
Saving
````ruby
Product.new(name: "love", languages: {
	es: {name: "amor"},
    pt: {name: "amor"},
    fr: {name: "amour"}
}).save
#=> #<Product id:3, name: "love">

love = Product.last
love.set_languages({
	es: {name: "amor :D"},
    pt: {name: "amor :D"},
    fr: {name: "amouuurt"}
})
love.save
#=> #<Product id: 3, name: "love">
love =  Product.l(:fr).find(3)
love.inspect
#=> #<Product id: 3, name: "amouuurt">
````
Updating
````ruby
product = Product.find(3)
product.update(name: "the love", languages: {
	es: {name: "el amor"},
    pt: {name: "o amor"},
    fr: {name: "l'amour"}
})
#=> #<Product id:3, name: "the love">

product = Product.l(:fr).find(3)
product.inspect
#=> #<Product id: 3, name: "l'amour">
````
Destroying
````ruby
Product.find(1).destroy
# begin transaction
# SELECT "product_languages".* FROM "product_languages" WHERE "product_languages"."localizable_object_id" = ?  [["localizable_object_id", 1]]
# DELETE FROM "product_languages" WHERE "product_languages"."id" = ?  [["id", 1]]
# DELETE FROM "products" WHERE "products"."id" = ?  [["id", 1]]
# commit transaction
````
Eager loading support
````ruby
products = Product.includes(:features).where(id: 1)
products.first.features.inspect
#=> <ActiveRecord::Relation [#<Feature id: 1, desc: "Makes people happy">]>

products = Product.l(:es) do |products|
	products.includes(:features)
end.where(id: 1)
products.first.features.inspect
#=> <ActiveRecord::Relation [#<Feature id: 1, desc: "Hace a la gente feliz">]>
````
Eager loading support for multiple languages
````ruby
products = Product.includes(:features).where(id: 1)
products.first.features.inspect
#=> <ActiveRecord::Relation [#<Feature id: 1, desc: "Makes people happy">]>

products = Product.wl(:es,:pt,:fr) do |products|
	products.includes(:features)
end.where(id: 1)
products.first.features.inspect
#=> <ActiveRecord::Relation [#<Feature id: 1, desc: "Makes people happy", es_desc: "Hace a la gente feliz", pt_desc: "Faz as pessoas felizes", fr_desc: "Rend les gens heureux">]>
````
#### NOTE:
If you need to use aggregation functions or grouping stuff, use the raw model without calling the localize method (.l), otherwise a syntax error will be raised from ActiveRecord. We still working on this feature, if you want to help us, feel free to make a pull request :)

## Installation
Add this line to your application's Gemfile:
```ruby
gem 'localizable_db'
```

And then execute:
```bash
$ bundle
```

Then Install it!
````bash
$ rails g localizable_db:install
````

Configure your supported languages
````ruby
# config/initializers/localizable_db_initializer_.rb
module LocalizableDb
  module Languages
    DEFAULT = :en
    SUPPORTED = [:en, :es] #=> Add your locales to this array.
  end
end
````

## Generating
Generate a localizable model.
````bash
rails g localizable_db:model Product name:string desc:text other:string
````

Generate a migration for a localizable model.
````bash
rails g localizable_db:migration Product name:string desc:text other:string
````


## Setting up your models
You need to call the localize method on your models, so localizable_db knows which attributes are localizable. Notice that the localizable attributes that you define in the model must have a column in the related localized table.

````ruby
# app/models/product.rb
class Product < ApplicationRecord
	localize :name, :desc
end
````

## Authors
[yonga9121](https://github.com/yonga9121) |
[Nevinyrral](http://github.com/Nevinyrral)


## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
