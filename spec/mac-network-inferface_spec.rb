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

  describe 'wired with link' do
    it 'has link and is wired' do
      Interface.wired_with_link.each do |i|
        i.wired?.should be_true
        i.has_link?.should be_true
      end
    end
  end

  describe 'wireless with link' do
    it 'has link and is wireless' do
      Interface.wireless_with_link.each do |i|
        i.wired?.should be_false
        i.has_link?.should be_true
      end
    end
  end

  describe :first do
    it "returns and instance of itself" do
      Mac::Network::Interface.first.should be_kind_of(Mac::Network::Interface)
    end
  end

  describe :find_by_name do
    it 'returns interface with provided name' do
      name_to_find = Mac::Network::Interface.first.name
      found = Mac::Network::Interface.find_by_name(name_to_find)
      found.should be_kind_of(Mac::Network::Interface)
      found.name.should == name_to_find
    end
    it 'returns nil for no match' do
      Mac::Network::Interface.find_by_name('no name').should be_nil
    end
  end

  describe :for_default_gateway do
    it 'returns the interface used as the default gateway' do
      shelled_out_bsd_name = `netstat -arn | grep default`.gsub(/.* /,'').rstrip
      Mac::Network::Interface.for_default_gateway.bsd_name.should == shelled_out_bsd_name
    end
  end

  describe :all_with_link do
    it 'lists only interfaces with link' do
      Mac::Network::Interface.all_with_link.each do |i|
        i.has_link?.should be_true
      end
    end
  end

  describe :new do
    it 'creates an instance with an sc_interface_ref' do
      interface = Mac::Network::Interface.new(CF::Array.new(SystemConfig::SCNetworkInterfaceCopyAll()).first)
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

  describe 'wired?' do
    it 'returns bool' do
      Mac::Network::Interface.find_by_name("Wi-Fi").wired?.should be_false
      #Mac::Network::Interface.all.select {|i| i.name.to_s =~ /Ethernet/i}.first.wired?.should be_true
    end
  end

  describe 'has_link?' do
    it 'returns a bool' do
      [true,false].should include(Mac::Network::Interface.first.has_link?)
    end
    it 'is probably false for thunderbolt bridge' do
      bridge = Mac::Network::Interface.find_by_bsd_name('bridge0')
      bridge.has_link?.should be_false
    end
  end
end
