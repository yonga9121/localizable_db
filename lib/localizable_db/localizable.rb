module LocalizableDb
  module Localizable
    extend ActiveSupport::Concern
    included do

      def is_localizable?
        self.class.is_localizable?
      end

    end

    module ClassMethods

      attr_accessor :is_localizable

      def is_localizable?
        self.is_localizable
      end

      def localize(*localizable_attributes)
        self.is_localizable = true
        class_eval do
          default_scope(if: LocalizableDb.configuration.enable_i18n_integration) do
            localized
          end
          mattr_accessor :localized_table_name
          mattr_accessor :normalized_table_name
          mattr_accessor :localizable_attributes
        end
        self.localized_table_name = "#{self.table_name.singularize}_languages"
        self.normalized_table_name = self.table_name
        self.localizable_attributes = localizable_attributes
        aux_localized_table_name = self.localized_table_name
        aux_model_name = self.name
        self.const_set("#{self.name}Language", Class.new(ApplicationRecord) do
            self.table_name = aux_localized_table_name
            belongs_to aux_model_name.downcase.to_sym,
              class_name: aux_model_name,
              foreign_key: "localizable_object_id",
              inverse_of: aux_localized_table_name.to_sym
        end)
        class_eval do
          has_many self.localized_table_name.to_sym,
          class_name: "#{self.name}Language",
          foreign_key: "localizable_object_id",
          inverse_of: aux_model_name.downcase.to_sym,
          dependent: :destroy

          accepts_nested_attributes_for self.localized_table_name.to_sym
        end
        if LocalizableDb.configuration.enable_getters
          self.localizable_attributes.each do |attribute|
            class_eval %Q{
              def get_#{attribute}(language = LocalizableDb::Languages::DEFAULT)
                if language == LocalizableDb::Languages::DEFAULT
                  self.attributes["#{attribute.to_s}"]
                else
                  self.attributes[language.to_s + "_#{attribute.to_s}"]
                end
              end
            }
          end
        end
        class << self

          def get_locale
            I18n.locale
          end

          def localized(*languages)
            if(defined? LocalizableDb::Localizable and
              ((LocalizableDb.configuration.enable_i18n_integration and self.get_locale != LocalizableDb::Languages::DEFAULT) or
              (languages.any? and (languages-[LocalizableDb::Languages::DEFAULT]).any?)))
              languages = LocalizableDb::Languages::SUPPORTED if(
                languages.any? and languages.first == :all)
              languages = [self.get_locale] if languages.empty? and LocalizableDb.configuration.enable_i18n_integration
              languages.map!{|language| language.to_sym}
              if languages.size == 1
                language = languages.first
                return one_language(language)
              else
               languages = languages.keep_if do |language|
                 LocalizableDb::Languages::NOT_DEFAULT.include? language
               end
                return multiple_languages(languages)
              end
            else
              ActiveRecord::Relation.new(self, self.table_name,self.predicate_builder)
            end
          end

          alias_method :l, :localized

          private

          def one_language(language)
            attrs_to_select = single_languege_attrs_to_select_conf(language)
            from("#{self.localized_table_name}").joins("
              JOIN (
                SELECT #{self.table_name}.id, #{attrs_to_select.join(',')}
                FROM #{self.localized_table_name}, #{self.table_name}
                WHERE #{self.localized_table_name}.locale = '#{language.to_s}'
                AND #{self.localized_table_name}.localizable_object_id = #{self.table_name}.id
              ) AS #{self.table_name}
              ON #{self.localized_table_name}.locale = '#{language.to_s}'
              AND #{self.localized_table_name}.localizable_object_id = #{self.table_name}.id
            ")
          end

          def multiple_languages(languages)
            attrs_to_select = (self.attribute_names - ["id"]).map do |attribute|
              "#{self.table_name}.#{attribute.to_s}"
            end
            tables_to_select = ""
            conditions_to_select = ""
            languages.each do |language|
              attrs_to_select = attrs_to_select | self.localizable_attributes.map do |attribute|
                "#{language.to_s}_#{self.localized_table_name}.#{attribute.to_s} as #{language.to_s}_#{attribute.to_s}"
              end
              tables_to_select += "," if language != languages.first
              tables_to_select += "#{self.localized_table_name} as #{language.to_s}_#{self.localized_table_name}"
              conditions_to_select += "#{language.to_s}_#{self.localized_table_name}.locale = '#{language.to_s}'"
              conditions_to_select += " AND #{language.to_s}_#{self.localized_table_name}.localizable_object_id = #{self.table_name}.id"
              conditions_to_select += " AND " if language != languages.last
            end
            from("#{tables_to_select}").joins("
              JOIN (
                SELECT #{self.table_name}.id, #{attrs_to_select.join(',')}
                FROM #{self.table_name}, #{tables_to_select}
                WHERE #{conditions_to_select}
              ) AS #{self.table_name}
              ON #{conditions_to_select}
            ")
          end

          def single_languege_attrs_to_select_conf(language = nil)
            if LocalizableDb.configuration.attributes_integration
              attrs_to_select = self.attribute_names - ["id"] - self.localizable_attributes.map do |attribute|
                attribute.to_s
              end
              attrs_to_select = attrs_to_select | self.localizable_attributes.map do |attribute|
                ["#{self.localized_table_name}.#{attribute.to_s}","#{self.localized_table_name}.#{attribute.to_s} as #{language}_#{attribute}"]
              end
              attrs_to_select.flatten!
            else
              attrs_to_select = self.attribute_names - ["id"]
              attrs_to_select = attrs_to_select.map do |attribute|
                "#{self.table_name}.#{attribute}"
              end | self.localizable_attributes.map do |attribute|
                "#{self.localized_table_name}.#{attribute.to_s} as #{language}_#{attribute}"
              end
            end
            attrs_to_select
          end

        end

      end
    end
  end
end


ActiveRecord::Base.send(:include, LocalizableDb::Localizable)
