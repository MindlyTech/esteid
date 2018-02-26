require "esteid/validation"

describe EstEID::Validation do
  let(:public_key_header) do
    "FOOBARKEY"
  end

  let(:request) do
    double(:request, headers: { "HTTP_X_ESTEID_PUBLICKEY" => public_key_header })
  end

  let(:instance) { described_class.new(request) }

  before do
    EstEID.configure do |config|
      config.public_key_header = "HTTP_X_ESTEID_PUBLICKEY"
    end
  end

  describe ".initialize" do
    it "sets variables and parses header" do
      expect(instance.eid_public_key).to eql(public_key_header)
    end
  end

  describe ".valid?" do
    context "when public_key_header is missing" do
      it "returns false" do
        expect(instance).to receive(:eid_public_key_present?).and_return(false)
        expect(instance.valid?).to eq(false)
      end
    end

    context "when status is other than 'GOOD'" do
      it "returns false" do
        expect(instance).to receive(:eid_public_key_present?).and_return(true)
        expect(instance).to receive(:status).and_return("LOLNO")
        expect(instance.valid?).to eq(false)
      end
    end

    context "when status is 'GOOD'" do
      it "returns true" do
        expect(instance).to receive(:eid_public_key_present?).and_return(true)
        expect(instance).to receive(:status).and_return("GOOD")
        expect(instance.valid?).to eq(true)
      end
    end
  end

  describe ".status" do
    context "SOAP client returned fault" do
      it "returns SOAP error code" do
        expect(instance).to receive(:soap_fault?).and_return(true)
        expect(instance).to receive(:soap_error_code)
        expect(instance).to_not receive(:certificate_status)

        instance.status
      end
    end

    it "calls .certificate_status" do
      expect(instance).to receive(:soap_fault?).and_return(false)
      expect(instance).to_not receive(:soap_error_code)
      expect(instance).to receive(:certificate_status)

      instance.status
    end
  end
end
