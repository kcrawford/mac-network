require 'mac-network/interface'

describe "Mac::Network::Interface" do
  describe "all" do
    it "returns an iterable" do
      Mac::Network::Interface.all.should respond_to(:each)
    end
    it 'each item returned should be a interface' do
      Mac::Network::Interface.all.each do |interface|
        interface.should be_kind_of(Mac::Network::Interface)
      end
    end
  end

  describe :first do
    it "returns and instance of itself" do
      Mac::Network::Interface.first.should be_kind_of(Mac::Network::Interface)
    end
  end

  describe :current do
    it "returns the currently selected network" do
      Mac::Network::Interface.first.should be_kind_of(Mac::Network::Interface)
    end
  end
  describe :new do
    it 'creates an instance with an sc_interface_ref' do
      interface = Mac::Network::Interface.new(OSX::SCNetworkInterfaceCopyAll().first)
      interface.should be_kind_of(Mac::Network::Interface)
      interface.sc_interface_ref.should_not be_nil
    end
  end

  describe :name do
    it 'returns the network set name' do
      Mac::Network::Interface.first.name.should_not == ""
      Mac::Network::Interface.first.name.should_not be_nil
    end
  end
end
