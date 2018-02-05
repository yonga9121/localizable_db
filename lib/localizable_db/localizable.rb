module LocalizableDb
  module Localizable
    extend ActiveSupport::Concern

    included do


    end

    module ClassMethods

      def localize(localizable_attributes = [])
        singularized_model_name = self.name.downcase.singularize.dasherize
        class_eval %Q{

          default_scope { localized }

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
          def create_or_update
          end
          # def save(*args, &block )
          #   binding.pry
          #   if defined? LocalizableDb::Localizable and
          #     self.get_locale != I18n.default_locale
          #
          #     aux = super(attributes, block)
          #       if aux.errors.empty?
          #       self.table_name = self.localized_table_name
          #
          #       LocalizableDb::Languages::SUPPORTED.each do |language|
          #         if attributes[:languages][language]
          #           super(attributes[:languages][language].merge(locale: language, object_id: aux.id ))
          #         end
          #       end
          #       self.table_name = self.name.dasherize.pluralize
          #     end
          #   else
          #     super(attributes, block)
          #   end
          # end


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
