module LocalizableDb
  module Languages

      def config
        const_set("DEFAULT", LocalizableDb.configuration.default_language.to_sym || I18n.default_locale )
        const_set(
        "SUPPORTED",
          (LocalizableDb.configuration.supported_languages.map do |language|
            language.to_sym
          end | [LocalizableDb.configuration.default_language.to_sym].flatten)
        )
        const_set(
          "NOT_DEFAULT",
          (SUPPORTED - [DEFAULT])
        )
      end
      module_function :config
  end
end
