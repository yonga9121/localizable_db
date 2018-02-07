module LocalizableDb
  module Generators
    class InstallGenerator < Rails::Generators::Base

      source_root File.join(File.expand_path('../templates', __FILE__))

      def copy_initializer_file
        copy_file "initializer.rb", "config/initializers/localizable_db.rb"
      end

    end
  end
end
