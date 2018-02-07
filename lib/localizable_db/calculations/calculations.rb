module LocalizableDb
  module Localizable
    module Calculations
      extend ActiveSupport::Concern
      included do
      end

      module ClassMethods
        def override_calculations
          puts "CALLING FROM #{self}"
            class << self

              alias_method :localized_count, :count

              def count(column_name = nil)
                puts "LAksdñflkañlsdkflaksdñfkasdlñkfñlasdkfñlKÑLKKÑALSDKFÑLAKSDFLÑ"
                return unscope(:select).localized_count(column_name) if defined? LocalizableDb::Localizable and
                self.get_locale != I18n.default_locale
                localized_count(column_name)
              end
              #
              # def average(column_name)
              #   return unscope(:select).average(column_name) if defined? LocalizableDb::Localizable and
              #   self.get_locale != I18n.default_locale
              #   super(column_name)
              # end
              #
              # def minimum(column_name)
              #   return unscope(:select).minimum(column_name) if defined? LocalizableDb::Localizable and
              #   self.get_locale != I18n.default_locale
              #   super(column_name)
              # end
              #
              # def maximum(column_name)
              #   return unscope(:select).maximum(column_name) if defined? LocalizableDb::Localizable and
              #   self.get_locale != I18n.default_locale
              #   super(column_name)
              # end

              def localized_calculate(operation, column_name = nil)
                return unscope(:select).calculate(operation, column_name) if defined? LocalizableDb::Localizable and
                self.get_locale != I18n.default_locale
                calculate(:count, column_name)
              end

              def pluck(*column_names)
                puts "Kappa ?????"
                if defined? LocalizableDb::Localizable and
                  self.get_locale != I18n.default_locale
                  aux_column_names = []
                  column_names.each do |column_name|
                    aux_column_names << "#{self.localized_table_name}.#{column_name.to_s}" if self
                        .localized_attributes.include?(column_name.to_s)
                    aux_column_names << column_name if !self
                        .localized_attributes.include?(column_name.to_s)
                  end
                  puts "#{aux_column_names}"
                  super(*aux_column_names)
                else
                  puts "Kappa Pailas ????"
                  super(*column_names)
                end
              end
            end
        end
      end

    end
  end
end
