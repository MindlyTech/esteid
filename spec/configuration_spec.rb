require "esteid/configuration"

describe EstEID::Configuration do
  let(:config) { described_class.new }

  it "sets default blank values" do
    expect(config.certificate_header).to be_nil
  end

  it "it sets values" do
    config.certificate_header = "HTTP_X_FOO"
    expect(config.certificate_header).to eq("HTTP_X_FOO")
  end
end
