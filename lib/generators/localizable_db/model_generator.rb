require 'generators/localizable_db/orm_helper'
require 'rails/generators/active_record/model/model_generator'

module LocalizableDb
  module Generators
    class ModelGenerator < ActiveRecord::Generators::ModelGenerator

      include LocalizableDb::Generators::OrmHelper
      # include ActiveRecord::Generators::MigrationGenerator
      # include ActiveRecord::Generators::ModelGenerator

      source_root File.join(
        File.dirname(
          ActiveRecord::Generators::ModelGenerator
            .instance_method(:create_migration_file).source_location.first
        ), "templates"
      )

      def create_migration_file
        return unless options[:migration] && options[:parent].nil?

        attributes.each { |a|
          a.attr_options.delete(:index) if a.reference? && !a.has_index?
        } if options[:indexes] == false

        model_template = "#{__FILE__}/../templates/create_table_migration.rb"
        model_migration_name =
          "db/migrate/create_#{table_name}.rb"

        migration_template(
          model_template, model_migration_name,
          migration_version: migration_version
        )
      end

      def generate_migration_for_localizable
        case behavior
        when :invoke
          invoke(
            "localizable_db:migration",
            [
              table_name.singularize.camelize
            ] +
            attributes.map { |attribute|
              if attribute.type.eql? :string
                "#{attribute.name}:#{attribute.type.to_s}"
              end
            }
          )
        when :revoke
          invoke(
            "localizable_db:migration",
            [ table_name ], behavior: :revoke
          )
        end
      end

    end
  end
end
