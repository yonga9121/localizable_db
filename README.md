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

Product.find(1) #=> <Product id: 1, name: "suerte">
Product.where(id: 1)
#=> <ActiveRecord::Relation [#<Product id: 1, name: "suerte">]>

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
Product.l(:es).where(id: 1)
#=> <ActiveRecord::Relation [#<Product id: 1, name: "suerte">]>

Product.l(:pt).find(1) #=> <Product id: 1, name: "sortudo">
Product.l(:pt).where(id: 1)
#=> <ActiveRecord::Relation [#<Product id: 1, name: "sortudo">]>

Product.l(:fr).find(1) #=> <Product id: 1, name: "heureux">
Product.l(:fr).where(id: 1)
#=> <ActiveRecord::Relation [#<Product id: 1, name: "heureux">]>
````
Localize multiple languages
````ruby
products = Product.where(id: 1)
products.inspect
#=> <ActiveRecord::Relation [#<Product id: 1, name: "luck">]>
products = Product.l(:es,:pt,:fr).where(id: 1)
products.inspect
#=> <ActiveRecord::Relation [#<Product id: 1, name: "luck", es_name: "suerte", pt_name: "sortudo", fr_name: "heureux">]>

products.first.name #=> luck
products.first.get_name #=> luck
products.first.get_name(:es) #=> suerte
products.first.get_name(:pt) #=> sortudo
products.first.get_name(:fr) #=> heureux
products.first.attributes["es_name"] #=> suerte
products.first.attributes["pt_name"] #=> sortudo
products.first.attributes["fr_name"] #=> heureux
````
Creating
````ruby
Product.create(name: "something", product_languages_attributes: [{
		{name: "algo", locale: "es"},
    {name: "alguma cosia", locale: "pt"},
    {name: "quelque chose", locale: "fr"}
}])
#=> #<Product id:2, name: "something">
````
Saving
````ruby
Product.new(name: "love", product_languages_attributes: [{
		{name: "algo", locale: "es"},
    {name: "alguma cosia", locale: "pt"},
    {name: "quelque chose", locale: "fr"}
}]).save
#=> #<Product id:3, name: "love">

love = Product.last
love.product_languages.build([
	{name: "algo", locale: "es"},
	{name: "alguma cosia", locale: "pt"},
	{name: "quelque chose", locale: "fr"}
])
love.save
#=> #<Product id: 3, name: "love">
love =  Product.l(:fr).find(3)
love.inspect
#=> #<Product id: 3, name: "amouuurt">
````
Updating
````ruby
product = Product.find(3)
product.update(name: "the love", product_languages_attributes: [{
		{name: "algo", locale: "es"},
    {name: "alguma cosia", locale: "pt"},
    {name: "quelque chose", locale: "fr"}
}])
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

products = Product.l(:es).includes.where(id: 1)
products.first.features.inspect
#=> <ActiveRecord::Relation [#<Feature id: 1, desc: "Hace a la gente feliz">]>
````
Eager loading support for multiple languages
````ruby
products = Product.includes(:features).where(id: 1)
products.first.features.inspect
#=> <ActiveRecord::Relation [#<Feature id: 1, desc: "Makes people happy">]>

products = Product.l(:es,:pt,:fr).includes(:features).where(id: 1)
products.first.features.inspect
#=> <ActiveRecord::Relation [#<Feature id: 1, desc: "Makes people happy", es_desc: "Hace a la gente feliz", pt_desc: "Faz as pessoas felizes", fr_desc: "Rend les gens heureux">]>
````
Aggregation and grouping stuff operations work as usual
````ruby
Product.count
# => 3

Product.l(:es,:pt,:fr).count
# => 3
````
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
