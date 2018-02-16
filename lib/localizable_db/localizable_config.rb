module LocalizableDb

  mattr_accessor :configuration

  def config
    @@configuration ||= LocalizableConfig.new
    yield(@@configuration) if block_given?
    @@configuration
  end

  module_function :config

  private

  class LocalizableConfig

    attr_accessor :attributes_integration
    attr_accessor :enable_getters
    attr_accessor :enable_i18n_integration

    def initialize()
      @attributes_integration = false
      @enable_getters = false
      @enable_i18n_integration = false
    end
  end
end

LocalizableDb.send(:config)
