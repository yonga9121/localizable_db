require 'generators/localizable_db/orm_helper'
require 'rails/generators/active_record/model/model_generator'

module LocalizableDb
  module Generators
    class ModelGenerator < ActiveRecord::Generators::ModelGenerator

      include LocalizableDb::Generators::OrmHelper

      source_root File.join(
        File.dirname(
          ActiveRecord::Generators::ModelGenerator
            .instance_method(:create_migration_file).source_location.first
        ), File.expand_path('../templates', __FILE__)
      )

      def create_migration_file
        return unless options[:migration] && options[:parent].nil?
        
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

      def generate_model
        p "Model creation"
        case behavior
        when :invoke
          inject_into_class(
            Rails.root.join("app", "models", "#{table_name.singularize}.rb"),
            Object.const_get(table_name.singularize.camelize)
          ) do
            %Q{\tlocalize\n}
          end
        when :revoke
          system "rails d model #{table_name.singularize.camelize}"
        end
      end

    end
  end
end
