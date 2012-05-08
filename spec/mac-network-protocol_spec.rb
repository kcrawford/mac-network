require 'mac-network/protocol'
require 'mac-network/service'

include Mac::Network

describe "Protocol" do
  describe "new" do
    it 'returns a protocol' do
      Protocol.new(nil).should be_kind_of(Protocol)
    end
  end

  describe :instance do
    before(:each) do
      s = Service.new(:interface => Interface.first)
      s.configure_defaults
      @protocol = s.protocols.first
    end

    describe "configuration" do
      it 'returns configuration' do
        @protocol.configuration
      end
    end

    describe 'configuration setter' do
      it 'sets config' do
        @protocol.configuration = {"foo" => "bar"}
        @protocol.configuration.should have_key("foo")
        @protocol.configuration = {'blah' => []}
        @protocol.configuration.should have_key("blah")
      end
    end

    describe "protocol_type" do
      it 'returns non-empty string' do
        @protocol.protocol_type.should_not be_nil
        @protocol.protocol_type.length.should > 1
      end
    end
  end
end
