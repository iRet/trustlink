require 'spec_helper'
require 'app/helpers/trustlink_helper'

describe TrustlinkHelper do
  describe '#trustlink_links' do

    subject { helper.trustlink_links }

    before do
      helper.request.path = '/'
      TrustlinkLink.stub(:where).with({page: '/'})
        .and_return([
          mock_model(TrustlinkLink, 
            page: "/",
            url: "http://kremlin.ru",
            anchor: "See some stuff",
            text: "Visit Kremlin"
            )
          ])
    end

    it { should include('kremlin.ru') }
    it { should include('See some stuff') }
    it { should include('Visit Kremlin') }

    describe 'recognized as bot' do
      before do
        helper.request.remote_addr = '127.0.0.1'
        TrustlinkConfig.stub(:bot_ips).and_return(['127.0.0.1'])
        TrustlinkConfig.stub(:start_code).and_return('<!--start-->')
        TrustlinkConfig.stub(:stop_code).and_return('<!--end-->')
      end
      
      it { should include('<!--start-->') }
      it { should include('<!--end-->') }

    end
  end
end
