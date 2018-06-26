require 'iconv'

module EstEID
  class Authentication
    attr_reader :eid_cert

    def initialize(request)
      @eid_cert = request.headers[EstEID.config.certificate_header]
    end

    def valid?
      eid_cert_present?
    end

    def identity_code
      return unless valid?
      data_hash["serialNumber"]
    end

    def first_name
      return unless valid?
      normalize(data_hash["GN"])
    end

    def last_name
      return unless valid?
      normalize(data_hash["SN"])
    end

    private

    def normalize(str)
      puts "NORMALIZE STR: #{str}"
      str = str.gsub(/\\x([\da-fA-F]{2})/) { |m| [m].pack('H*') }
      puts "NORMALIZE AFTER GSUB RESULT: #{str}"

      if str =~ /\\x00/
        # UCS-2 encoding
        # result.force_encoding('utf-16be').encode!('utf-8')
        conv=Iconv.new("UTF-8//IGNORE","UTF-16")
        str=conv.iconv(str)
      else
        str.force_encoding('UTF-8')
      end
      puts "NORMALIZE RESULT: #{str}"

      str
    end

    def data_hash
      @data_hash ||= parse_header
    end

    def eid_cert_present?
      !@eid_cert.nil? && !@eid_cert.empty?
    end

    def parse_header
      return unless valid?

      case
      when /\//.match(@eid_cert)
        parse_legacy
      else
        parse_rfc2253
      end
    end

    def parse_legacy
      ary = @eid_cert.split("/").reject(&:empty?)
      Hash[ary.collect { |k| k.split "=" }]
    end

    def parse_rfc2253
      ary = @eid_cert.gsub("\\,", "/").split(",")
      Hash[ary.collect { |k| k.split "=" }]
    end
  end
end
