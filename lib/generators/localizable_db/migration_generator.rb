require 'generators/localizable_db/orm_helper'
require 'rails/generators/active_record/migration/migration_generator'

module LocalizableDb
  module Generators
    class MigrationGenerator < ActiveRecord::Generators::MigrationGenerator

      include LocalizableDb::Generators::OrmHelper

      source_root File.join(
        File.dirname(
          ActiveRecord::Generators::MigrationGenerator
            .instance_method(:create_migration_file).source_location.first
        ), 'templates'
      )

      def create_migration_file
        if !model_exists? and behavior == :invoke
          raise "Model #{table_name.singularize.camelize} doesn't exist," +
          " please run 'bundle exec rails g localizable_db:model #{table_name.
          singularize.camelize}' or create the model #{table_name
          .singularize.camelize} and run localizable_db:migration again."
          return
        end

        attributes.each { |a|
          a.attr_options.delete(:index) if a.reference? && !a.has_index?
        } if options[:indexes] == false

        template = "#{__FILE__}/../templates/migration_for.rb"
        migration_name =
          "db/migrate/create_#{table_name.singularize}_languages.rb"
        migration_template(
          template, migration_name, migration_version: migration_version
        )
      end

      def generate_localizable_model
        if !model_exists? and behavior == :invoke
          raise "Model #{table_name.singularize.camelize} doesn't exist"
          return
        end

        case behavior
        when :invoke
          inject_into_class(
            Rails.root.join("app", "models", "#{table_name.singularize}.rb"),
            Object.const_get(table_name.singularize.camelize)
          ) do
            %Q{\tlocalize\n}
          end
        when :revoke
          # Do nothing
        end
      end
    end
  end
end
