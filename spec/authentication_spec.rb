require "esteid/authentication"

describe EstEID::Authentication do
  let(:legacy_header) do
    "/C=EE/O=ESTEID/OU=authentication/CN=BÄRNÕŠ,FOO,37502266535/SN=BÄRNÕŠ/GN=FOO/serialNumber=37502266535"
  end

  let(:rfc2253_header) do
    "serialNumber=37502266535,GN=FOO,SN=BÄRNÕŠ,CN=BÄRNÕŠ\\,FOO\\,37502266535,OU=authentication,O=ESTEID,C=EE"
  end

  let(:idemia_header) do
    "/C=EE/CN=J\xC3\x95EORG,JAAK-KRISTJAN,38001085718/SN=J\xC3\x95EORG/GN=JAAK-KRISTJAN/serialNumber=PNOEE-38001085718"
  end

  let(:legacy_request) do
    double(:request, headers: { "HTTP_X_ESTEID_CERT" => legacy_header })
  end

  let(:request) do
    double(:request, headers: { "HTTP_X_ESTEID_CERT" => rfc2253_header })
  end

  let(:idemia_request) do
    double(:request, headers: { "HTTP_X_ESTEID_CERT" => idemia_header })
  end

  let(:idemia_instance) { described_class.new(idemia_request) }
  let(:legacy_instance) { described_class.new(legacy_request) }
  let(:instance) { described_class.new(request) }

  before do
    EstEID.configure do |config|
      config.certificate_header = "HTTP_X_ESTEID_CERT"
    end
  end

  describe ".initialize" do
    it "sets variables and parses header" do
      expect(instance.eid_cert).to eql(rfc2253_header)
    end
  end

  describe ".valid?" do
    it "validates EID cert header presence" do
      expect(instance).to be_valid
    end

    it "calls .eid_cert_present?" do
      expect(instance).to receive(:eid_cert_present?)
      instance.valid?
    end
  end

  describe ".identity_code" do
    context "with legacy header" do
      it "returns identity code from EID cert header" do
        expect(legacy_instance.identity_code).to eql("37502266535")
      end
    end

    context "with RFC2253 header" do
      it "returns identity code from EID cert header" do
        expect(instance.identity_code).to eql("37502266535")
      end
    end

    context "with idemia header" do
      it "returns identity code from EID cert header" do
        expect(idemia_instance.identity_code).to eql("38001085718")
      end
    end
  end

  describe ".first_name" do
    it "calls .normalize" do
      expect(instance).to receive(:normalize).with("FOO")
      instance.first_name
    end

    context "with legacy header" do
      it "returns first name from EID cert header" do
        expect(legacy_instance.first_name).to eql("FOO")
      end
    end

    context "with RFC2253 header" do
      it "returns first name from EID cert header" do
        expect(instance.first_name).to eql("FOO")
      end
    end

    context "with idemia header" do
      it "returns first name from EID cert header" do
        expect(idemia_instance.first_name).to eql("JAAK-KRISTJAN")
      end
    end
  end

  describe ".last_name" do
    it "calls .normalize" do
      expect(instance).to receive(:normalize).with("BÄRNÕŠ")
      instance.last_name
    end

    context "with legacy header" do
      it "returns last name from EID cert header" do
        expect(legacy_instance.last_name).to eql("BÄRNÕŠ")
      end
    end

    context "with RFC2253 header" do
      it "returns last name from EID cert header" do
        expect(instance.last_name).to eql("BÄRNÕŠ")
      end
    end

    context "with idemia header" do
      it "returns last name from EID cert header" do
        expect(idemia_instance.last_name).to eql("JÕEORG")
      end
    end
  end
end
