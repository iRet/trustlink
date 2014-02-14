require 'spec_helper'

describe 'trustlink:fetch' do
  include_context 'rake'

  its(:prerequisites) { should include("environment") }

  describe "Without config file" do

    it "should fails with message" do
      lambda{ subject.invoke }.should raise_exception(RuntimeError, 'Config file not found (config/trustlink.yml)')
    end

  end

  describe "With config file" do
    let(:config)   { YAML.load(File.open(Rails.root.join("spec", "fixtures", "trustlink.yml"))) }
    let(:response) { File.open(Rails.root.join("spec", "fixtures", "response.xml")) }

    before do
      YAML.stub(:load_file).with('config/trustlink.yml').and_return(config)
      FakeWeb.register_uri(:any, "http://db.trustlink.ru/abcdefg/kremlin.ru/UTF-8.xml", body: response)
      TrustlinkConfig.any_instance.stub(:delete_all).and_return(:true)
      TrustlinkLink.any_instance.stub(:delete_all).and_return(:true)
    end

    it "should fetch xml file" do
      subject.invoke
      FakeWeb.should have_requested(:get, 'http://db.trustlink.ru/abcdefg/kremlin.ru/UTF-8.xml')
    end
    
    it "should fails if could not get file" do
      FakeWeb.register_uri(:any, "http://db.trustlink.ru/abcdefg/kremlin.ru/UTF-8.xml", status: 404)
      lambda{ subject.invoke }.should raise_exception(RuntimeError, 'Could not receive data')      
    end

    it "should add data" do
      subject.invoke
      TrustlinkConfig.count.should eq 7
      TrustlinkLink.count.should   eq 1
    end
  end

end
