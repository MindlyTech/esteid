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

    def initialize
      @certificate_header = nil
    end
  end
end
