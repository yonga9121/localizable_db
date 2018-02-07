module LocalizableDb
  module Localizable
    extend ActiveSupport::Concern

    included do

      def save_languages
        if !self._locale and self.languages
          self.class.table_name = self.class.localized_table_name
          self.languages.each do |language_key, language_values|
              aux_object = nil
              aux_object = self.class.find_by(locale: language_key.to_s, localizable_object_id: self.id) if self.id
              aux_object = self.class.new if !self.id or !aux_object
              aux_object.locale = language_key.to_s
              self.class.localized_attributes.each do |attribute|
                aux_object.send(:"#{attribute}=", language_values[attribute.to_sym])
              end
              aux_object.localizable_object_id = self.id
              aux_object.save(validate: false)
          end
          self.class.table_name = self.class.name.pluralize.dasherize.downcase
        end
      end

    end

    module ClassMethods

      def localize(localizable_attributes = [])
        singularized_model_name = self.name.downcase.singularize.dasherize
        class_eval %Q{

          default_scope { localize_eager_load }
          default_scope { with_languages_eager_load }

          attr_accessor :languages, :_locale

          after_save :save_languages

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

          def localized(language = nil)
            if defined? LocalizableDb::Localizable and
              (self.get_locale != I18n.default_locale or
              (language and language != I18n.default_locale))

              language = self.get_locale unless language
              raise "The locale :#{language} is not defined in the initialization file, please check config/initializers/localizable_db.rb to add it." if !LocalizableDb::Languages::SUPPORTED.include? language
              attrs_to_select = ""
              self.attribute_names.each do |attribute|
                attrs_to_select += "#{self.table_name}.#{attribute}"
                attrs_to_select += ", " if attribute != self.attribute_names.last
              end
              self.localized_attributes.each do |a|
                attrs_to_select += ", " if a == self.localized_attributes.first
                attrs_to_select += "#{self.localized_table_name}.#{a} as #{a}"
                attrs_to_select += ", " if a != self.localized_attributes.last
              end
              aux_select_values = joins("
                JOIN  #{self.localized_table_name}
                ON    locale = '#{language.to_s}'
                AND   #{self.table_name}.id = #{self.localized_table_name}.localizable_object_id
              ").select_values.map{|select_value| select_value.to_s }.join(' ')
              localized_chain = (aux_select_values.scan(/#{self.localized_table_name}/).any? ? true : false)
              result = joins("
                JOIN  #{self.localized_table_name}
                ON    locale = '#{language.to_s}'
                AND   #{self.table_name}.id = #{self.localized_table_name}.localizable_object_id
              ").select(attrs_to_select) if !localized_chain
              result = unscope(:joins, :select).joins("
                JOIN  #{self.localized_table_name}
                ON    locale = '#{language.to_s}'
                AND   #{self.table_name}.id = #{self.localized_table_name}.localizable_object_id
              ").select(attrs_to_select) if localized_chain
              if block_given?
                ActiveRecord::Base._localized_eager_load = true
                result = yield(result).reload
                ActiveRecord::Base._localized_eager_load = false
              end
              result
            else
              return where(id: nil).unscope(where: :id)
            end
          end

          def with_languages(with_languages = [])
            with_languages = LocalizableDb::Languages::SUPPORTED if with_languages.empty?
            attrs_to_select = "#{self.table_name}.*, "
            with_languages.each do |language|
              self.localized_attributes.each do |localized_attribute|
                attrs_to_select += "#{self.localized_table_name}.#{localized_attribute} as #{language.to_s}_#{localized_attribute}"
                attrs_to_select += ", " if localized_attribute != self.localized_attributes.last
              end
              attrs_to_select += ", " if language != with_languages.last
            end
            result = unscope(:joins).joins("
            JOIN  #{self.localized_table_name}
            ON    locale IN (#{with_languages.map{|l| '"' + l.to_s + '"' }.join(', ')})
            AND   #{self.table_name}.id = #{self.localized_table_name}.localizable_object_id
            ").select(attrs_to_select)
            if block_given?
              ActiveRecord::Base._with_languages_eager_load = true
              result = yield(result).reload
              ActiveRecord::Base._with_languages_eager_load = false
            end
            result
          end

          alias_method :l, :localized
          alias_method :localized, :l
          alias_method :wl, :with_languages
          alias_method :with_languages, :wl

          def localize_eager_load(language = nil)
            if ActiveRecord::Base._localized_eager_load
              l(language)
            else
              ActiveRecord::Relation.new(self, self.table_name,self.predicate_builder)
            end
          end

          def with_languages_eager_load(with_languages = [])
            if ActiveRecord::Base._with_languages_eager_load
              wl(with_languages)
            else
              ActiveRecord::Relation.new(self, self.table_name,self.predicate_builder)
            end
          end

        end
      end

    end
  end
end

ActiveRecord::Base.send(:include, LocalizableDb::Localizable)
ActiveRecord::Base.class_eval{ mattr_accessor :_localized_eager_load, :_with_languages_eager_load}
