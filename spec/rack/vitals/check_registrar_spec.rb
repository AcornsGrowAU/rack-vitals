require "spec_helper"

describe Rack::Vitals::CheckRegistrar do
  subject { ::Rack::Vitals::CheckRegistrar.new }

  describe "#initalize" do
    it "creates a new instance of a check registrar" do
      check_registrar = ::Rack::Vitals::CheckRegistrar.new
      expect(check_registrar).to be_an_instance_of ::Rack::Vitals::CheckRegistrar
    end
  end

  describe "#register" do
    it "executes the given block in the context of the class" do
      expect(subject).to receive(:instance_eval)
      subject.register {}
    end
  end

  describe "#check" do
    let(:new_check) { instance_double ::Rack::Vitals::Check }

    before do
      allow(::Rack::Vitals::Check).to receive(:new).and_return new_check
    end

    it "creates a new check object" do
      expect(::Rack::Vitals::Check).to receive(:new).with("given name")
      subject.check "given name"
    end

    it "stores the check object for status checks" do
      subject.check "given name"
      expect(subject.instance_variable_get(:@all_checks)).to match_array([new_check])
    end

    context "when the check is critical" do
      it "stores the check object for health checks" do
        subject.check "given name", critical: true
        expect(subject.instance_variable_get(:@critical_checks)).to match_array([new_check])
      end
    end

    context "when the check is not critical" do
      it "does not store the check object for health checks" do
        subject.check "given name"
        expect(subject.instance_variable_get(:@critical_checks)).to eql(nil)
      end
    end
  end

  describe ".critical_checks" do
    context "when there are critical checks" do
      it "returns the collection of registered critical checks" do
        check = instance_double Rack::Vitals::Check
        subject.instance_variable_set(:@critical_checks, [check])
        expect(subject.critical_checks).to match_array([check])
      end
    end

    context "when there hasn't been any critical checks registered" do
      it "returns an empty array" do
        result = subject.critical_checks
        expect(result).to match_array([])
      end
    end
  end

  describe ".all_checks" do
    context "when there are critical checks" do
      it "returns the collection of all registered checks" do
        check = instance_double Rack::Vitals::Check
        subject.instance_variable_set(:@all_checks, [check])
        expect(subject.all_checks).to match_array([check])
      end
    end

    context "when there hasn't been any checks registered" do
      it "returns an empty array" do
        result = subject.all_checks
        expect(result).to match_array([])
      end
    end
  end
end
