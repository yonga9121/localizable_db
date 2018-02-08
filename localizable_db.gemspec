$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "localizable_db/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "localizable_db"
  s.version     = LocalizableDb::VERSION
  s.authors     = ["yonga9121", "Nevinyrral"]
  s.email       = ["jorgeggayon@gmail.com", "montanor@javeriana.edu.co"]
  s.homepage    = "https://yonga9121.github.io/localizable_db/"
  s.summary     = "Rails gem to localize your database"
  s.description = "If your application manage something like products or services that can be created dynamically, and you have to support multiple languages you may need to localize your database. LocalizableDb allow you to do that in a simple way."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.0.0"

  s.add_development_dependency "sqlite3"
end
