require 'mac-network'
require 'mac-network/location'

describe "Mac::Network::Location" do
  describe "all" do
    it "returns an iterable" do
      Mac::Network::Location.all.should respond_to(:each)
    end
  end

  describe :first do
    it "returns and instance of itself" do
      Mac::Network::Location.first.should be_kind_of(Mac::Network::Location)
    end
  end

  describe :current do
    it "returns the currently selected network" do
      Mac::Network::Location.first.should be_kind_of(Mac::Network::Location)
    end
  end
  describe :new do
    it 'creates an instance with the passed in properties' do
      pending
      Mac::Network::Location.new()
    end
    context "brand new location" do
      it 'creates a new SCNetworkLocation ref' do
        Mac::Network::Location.new().sc_location_ref.should_not be_nil
      end
    end
  end

  describe :save do
    it 'validates required properties like name' do
      pending
    end
  end

  describe :add_interface do
    it 'add a network service with the provided bsd name' do
      loc = Mac::Network::Location.new()
      loc
    end
  end
end
