require "spec_helper"

describe Rack::Vitals::CheckRegistrar do
  let(:described_class) do
    Class.new Rack::Vitals::CheckRegistrar
  end

  describe ".register" do
    it "executes the given block in the context of the class" do
      expect(described_class).to receive(:class_eval)
      described_class.register
    end
  end

  describe ".check" do
    let(:new_check) { instance_double ::Rack::Vitals::Check }

    before do
      described_class.instance_variable_set(:@all_checks, [])
      described_class.instance_variable_set(:@critical_checks, [])
      allow(::Rack::Vitals::Check).to receive(:new).and_return new_check
    end

    it "creates a new check object" do
      expect(::Rack::Vitals::Check).to receive(:new).with("given name")
      described_class.check "given name"
    end

    it "stores the check object for status checks" do
      described_class.check "given name"
      expect(described_class.instance_variable_get(:@all_checks)).to match_array([new_check])
    end

    context "when the check is critical" do
      it "stores the check object for health checks" do
        described_class.check "given name", critical: true
        expect(described_class.instance_variable_get(:@critical_checks)).to match_array([new_check])
      end
    end

    context "when the check is not critical" do
      it "does not store the check object for health checks" do
        described_class.check "given name"
        expect(described_class.instance_variable_get(:@critical_checks)).to match_array([])
      end
    end
  end

  describe ".critical_checks" do
    context "when there are critical checks" do
      it "returns the collection of registered critical checks" do
        check = instance_double Rack::Vitals::Check
        described_class.instance_variable_set(:@critical_checks, [check])
        expect(described_class.critical_checks).to match_array([check])
      end
    end

    context "when there hasn't been any critical checks registered" do
      it "returns an empty array" do
        result = described_class.critical_checks
        expect(result).to match_array([])
      end
    end
  end

  describe ".all_checks" do
    context "when there are critical checks" do
      it "returns the collection of all registered checks" do
        check = instance_double Rack::Vitals::Check
        described_class.instance_variable_set(:@all_checks, [check])
        expect(described_class.all_checks).to match_array([check])
      end
    end

    context "when there hasn't been any checks registered" do
      it "returns an empty array" do
        result = described_class.all_checks
        expect(result).to match_array([])
      end
    end
  end
end
