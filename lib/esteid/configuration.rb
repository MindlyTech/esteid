module EstEID
  class << self
    attr_reader :config
  end

  def self.configure
    @config = Configuration.new
    yield(@config) if block_given?
    @config
  end

  class Configuration
    attr_accessor :certificate_header
    attr_accessor :public_key_header
    attr_accessor :digidoc_endpoint_url

    def initialize
      @certificate_header = nil
      @public_key_header = nil
      @digidoc_endpoint_url = nil
    end
  end
end
