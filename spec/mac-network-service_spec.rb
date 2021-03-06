require 'mac-network/service'

describe "Mac::Network::Service" do
  describe "all" do
    it "returns an iterable" do
      Mac::Network::Service.all.should respond_to(:each)
    end
    it 'each item returned should be a service' do
      Mac::Network::Service.all.each do |service|
        service.should be_kind_of(Mac::Network::Service)
      end
    end
  end

  describe :first do
    it "returns and instance of itself" do
      Mac::Network::Service.first.should be_kind_of(Mac::Network::Service)
    end
  end

  describe :current do
    it "returns the currently selected network" do
      Mac::Network::Service.first.should be_kind_of(Mac::Network::Service)
    end
  end
  describe :find_by_name do
    it 'returns service with provided name' do
      name_to_find = Mac::Network::Service.first.name
      found = Mac::Network::Service.find_by_name(name_to_find)
      found.should be_kind_of(Mac::Network::Service)
      found.name.should == name_to_find
    end
    it 'returns nil for no match' do
      Mac::Network::Service.find_by_name('no name').should be_nil
    end
  end
  describe :new do
    it 'creates an instance with the passed in properties' do
      interface = Mac::Network::Interface.first
      service = Mac::Network::Service.new({:interface => interface})
      service.interface.bsd_name.should == interface.bsd_name
      service.should be_kind_of(Mac::Network::Service)
    end
    context "brand new service" do
      it 'creates a new SCNetworkService ref' do
        Mac::Network::Service.new(:interface => Mac::Network::Interface.first).sc_service_ref.should_not be_nil
      end
      it 'requires a service ref or interface' do
        expect { Mac::Network::Service.new().sc_service_ref.should_not be_nil }.to raise_error
      end
    end
  end

  describe :name do
    it 'returns the network service name' do
      service = Mac::Network::Service.new({:interface => Mac::Network::Interface.first})
      service.name.should_not be_nil
    end
  end
  describe 'name = ' do
    it 'sets the name' do
      service = Mac::Network::Service.new(:interface => Mac::Network::Interface.first)
      service.name = "My New Service"
      service.name.should == "My New Service"
    end
  end

  describe :protocols do
    it 'returns iterable' do
      Service.first.protocols.should respond_to(:each)
    end
  end

  describe :protocol_by_name do
    it 'returns one protocol with matching name' do
      s = Service.first
      s.configure_defaults
      s.protocol_by_name('ipv4').name.downcase.should == 'ipv4'
    end
  end

  describe :ipv4 do
    it 'returns ipv4 protocol' do
      Service.first.ipv4.should be_kind_of(Mac::Network::Protocol)
      Service.first.ipv4.name.downcase.should == 'ipv4'
    end
  end

  describe :disable_all_protocols do
    it 'disables them' do
      service = Mac::Network::Service.new(:interface => Mac::Network::Interface.first)
      service.configure_defaults
      protocol = service.protocols.first
      protocol.enable
      protocol.enabled?.should be_true
      service.disable_all_protocols
      protocol.enabled?.should be_false
    end
  end

end
