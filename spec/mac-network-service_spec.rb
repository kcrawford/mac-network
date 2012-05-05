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
end
