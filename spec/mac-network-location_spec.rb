require 'mac-network'
require 'mac-network/location'

describe "Mac::Network::Location" do
  describe "all" do
    it "returns an iterable" do
      Mac::Network::Location.all.should respond_to(:each)
    end
    it 'each item returned should be a location' do
      Mac::Network::Location.all.each do |loc|
        loc.should be_kind_of(Mac::Network::Location)
      end
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

  describe :name do
    it 'returns the network set name' do
      loc = Mac::Network::Location.new
      loc.name.should be_nil
      Mac::Network::Location.reload_prefs
      Mac::Network::Location.first.name.should_not == ""
      Mac::Network::Location.first.name.should_not be_nil
    end
  end
  describe 'name = ' do
    it 'sets the name' do
      loc = Mac::Network::Location.new
      loc.name = "My New Location"
      loc.name.should == "My New Location"
    end
  end
end
