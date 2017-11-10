require "esteid/authentication"

describe EstEID::Authentication do
  let(:legacy_header) do
    "/C=EE/O=ESTEID/OU=authentication/CN=BAR,FOO,37502266535/SN=BAR/GN=FOO/serialNumber=37502266535"
  end

  let(:rfc2253_header)  do
    "serialNumber=37502266535,GN=FOO,SN=BAR,CN=BAR\\,FOO\\,37502266535,OU=authentication,O=ESTEID,C=EE"
  end

  let(:legacy_request) do
    double(:request, headers: { "HTTP_X_ESTEID_CERT" => legacy_header })
  end

  let(:request) do
    double(:request, headers: { "HTTP_X_ESTEID_CERT" => rfc2253_header })
  end

  let(:legacy_instance) { described_class.new(legacy_request) }
  let(:instance) { described_class.new(request) }

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
  end

  describe ".last_name" do
    it "calls .normalize" do
      expect(instance).to receive(:normalize).with("BAR")
      instance.last_name
    end

    context "with legacy header" do
      it "returns last name from EID cert header" do
        expect(legacy_instance.last_name).to eql("BAR")
      end
    end

    context "with RFC2253 header" do
      it "returns last name from EID cert header" do
        expect(instance.last_name).to eql("BAR")
      end
    end
  end
end
