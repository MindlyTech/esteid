require "savon"

module EstEID
  class Validation
    attr_reader :eid_public_key

    STATUSES = {
      'REVOKED' => 'cert_revoked',
      'UNKNOWN' => 'cert_unknown',
      'EXPIRED' => 'cert_expired',
      'SUSPENDED' => 'cert_suspended',
      '100' => '100',
      '101' => '101',
      '102' => '102',
      '103' => '103',
      '200' => '200',
      '201' => '201',
      '202' => '202',
      '203' => '203',
      '300' => '300',
      '301' => '301',
      '302' => '302',
      '303' => '303',
      '304' => '304',
      '305' => '305',
      '413' => '413',
      '503' => '503'
    }

    def initialize(request)
      @eid_public_key = request.headers[EstEID.config.public_key_header]
    end

    def valid?
      return false unless eid_public_key_present?
      status == "GOOD"
    end

    def status
      return soap_error_code if soap_fault?
      response.body.dig(:check_certificate_response, :status)
    end

    private

    def eid_public_key_present?
      !@eid_public_key.nil? && !@eid_public_key.empty?
    end

    def client
      @client ||= ::Savon.client(
        endpoint: EstEID.config.digidoc_endpoint_url,
        namespace: "http://www.sk.ee/DigiDocService/DigiDocService_2_3.wsdl",
        raise_errors: false,
        open_timeout: 10,
        ssl_version: :TLSv1,
        ssl_verify_mode: :none
      )
    end

    def response
      @response ||= client.call("CheckCertificate") do |locals|
        locals.message "Certificate" => @eid_public_key
      end
    end

    def soap_fault?
      response.http.body =~ /<*Fault>/
    end

    def soap_error_code
      response.body.dig(:fault, :faultstring)
    end

    def error_status(status)
      return if valid?

      if STATUSES.include?(status)
        STATUSES[status]
      else
        status
      end
    end
  end
end
