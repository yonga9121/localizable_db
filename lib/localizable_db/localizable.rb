module LocalizableDb
  module Localizable
    extend ActiveSupport::Concern

    included do

      def save_languages
        if !self.locale and self.languages
          self.class.table_name = self.class.localized_table_name
          self.languages.each do |language_key, language_values|
              self.locale = language_key
              self.class.localized_attributes.each do |attribute|
                self.send(:"#{attribute}=", language_values[attribute])
              end
              self.object_id = self.id
              self.save
          end
          self.class.table_name = self.class.name.pluralize.dasherize.downcase
        end
      end

    end

    module ClassMethods

      def localize(localizable_attributes = [])
        singularized_model_name = self.name.downcase.singularize.dasherize
        class_eval %Q{

          attr_accessor :languages, :locale

          default_scope { localized }

          after_create :save_languages

          private

          def self.localized_table_name
            "#{singularized_model_name}_languages".freeze
          end

          def self.localized_attributes
            #{localizable_attributes}.map{|a| a.to_s}.freeze
          end

          def self.get_locale
            I18n.locale
          end
        }

        class << self

          def localized
            if defined? LocalizableDb::Localizable and
              self.get_locale != I18n.default_locale

              attrs_to_select = "#{self.table_name}.*"
              attrs_to_select += ", " if self.localized_attributes.size > 0
              self.localized_attributes.each do |a|
                attrs_to_select += "#{self.localized_table_name}.#{a}"
                attrs_to_select += ", " if a != self.localized_attributes.last
              end
              joins("
                JOIN  #{self.localized_table_name}
                ON    locale = '#{self.get_locale}'
                AND   #{self.table_name}.id = #{self.localized_table_name}.object_id
              ").select(attrs_to_select)
            else
              ActiveRecord::Relation.new(self, self.table_name, self.predicate_builder)
            end
          end

        end
      end

    end
  end
end
