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
      Mac::Network::Location.current.should be_kind_of(Mac::Network::Location)
    end
  end

  describe :select do
    it 'sets the location as the currently active location' do
      location = Mac::Network::Location.new(:name => 'Not Currently Active')
      service = location.add_service(Mac::Network::Service.new(:interface => Mac::Network::Interface.first))
      Mac::Network::Location.current.name.should_not == location.name
      location.select
      Mac::Network::Location.current.name.should == location.name
    end
  end
  describe :new do
    context "brand new location" do
      it 'creates a new SCNetworkLocation ref' do
        Mac::Network::Location.new().sc_location_ref.should_not be_nil
      end
      it 'sets name to provided name' do
        Mac::Network::Location.new({:name => 'My Great Location'}).name.should == 'My Great Location'
      end
    end
  end

  describe :exists? do
    it 'returns true or false based on provided name' do
      location = Mac::Network::Location.new
      location.name = "foo"
      Mac::Network::Location.exists?("foo").should be_true
      Mac::Network::Location.exists?("bar").should be_false
    end
  end

  describe :find_by_name do
    context :exists do
      it 'returns a location' do
        valid_name = Mac::Network::Location.all.first.name.to_s
        Mac::Network::Location.find_by_name(valid_name).should be_kind_of(Mac::Network::Location)
      end
    end
    context :not_exists do
      it 'returns nil' do
        Mac::Network::Location.find_by_name('2983294329').should be_nil
      end
    end
  end

  describe :add_service do
    it 'adds the provided service' do
      location = Mac::Network::Location.new
      service = location.add_service(Mac::Network::Service.new(:interface => Mac::Network::Interface.first))
      service.name = "Service This"
      location.services.first.name.should == service.name
    end
  end

  describe :services do
    it 'lists services for this location' do
      location = Mac::Network::Location.new
      service = location.add_service(Mac::Network::Service.new(:interface => Mac::Network::Interface.first))
      location.services.first.should be_kind_of(Mac::Network::Service)
      location.services.should have(1).items
    end
  end

  describe :has_service do
    before(:each) do
      @location = Mac::Network::Location.new
    end
    it 'false if not there' do
      @location.has_service?("Ethernet").should be_false
    end
    it 'true if has it' do
      service = Mac::Network::Service.new(:interface => Mac::Network::Interface.first)
      service.name = "Blah Blah"
      @location.add_service(service)
      @location.has_service?("Blah Blah").should be_true
    end
  end

  describe :destroy do
    it 'removes the location' do
      loc = Mac::Network::Location.new
      loc.name = 'A Grand Location'
      Mac::Network::Location.find_by_name('A Grand Location').should_not be_nil
      loc.destroy
      Mac::Network::Location.find_by_name('A Grand Location').should be_nil
    end
  end

  describe :name do
    it 'returns the network set name' do
      loc = Mac::Network::Location.new
      loc.name.should be_nil
      Mac::Network::reload_prefs
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
  describe :contains_interface do
    context 'has the interface' do
      it 'returns true' do
        Mac::Network::reload_prefs
        loc = Mac::Network::Location.first
        interface = loc.services.first.interface
        loc.contains_interface?(interface).should == true
      end
    end
    context 'does not have interface' do
      it 'returns false' do
        interface = Mac::Network::Interface.all.first
        Mac::Network::Location.new.contains_interface?(interface).should == false
      end
    end
  end
end
