module LocalizableDb
  module Languages
    DEFAULT =
      YAML::load(
        ERB.new(
          File.read(
            Rails.root.join("config","localizable_db.yml")
          )
        ).result
      )['languages']['default'].to_sym.freeze
    SUPPORTED =
      YAML::load(
        ERB.new(
          File.read(
            Rails.root.join("config","localizable_db.yml")
          )
        ).result
      )['languages']['supported'].map{|x| x.to_sym}.freeze
  end
end
