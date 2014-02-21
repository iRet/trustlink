require 'spec_helper'

describe TrustlinkConfig do
  before do
    TrustlinkConfig.delete_all
  end

  context '#start_code' do
    it 'should return code' do
      TrustlinkConfig.create name: 'start', value: '<!--start-code-->'
      TrustlinkConfig.start_code.should eq('<!--start-code-->')
    end
  end

  context '#stop_code' do
    it 'should return code' do
      TrustlinkConfig.create name: 'end', value: '<!--stop-code-->'
      TrustlinkConfig.stop_code.should eq('<!--stop-code-->')
    end
  end

  context '#bot_ips' do
    it 'should return bot ips array' do
      TrustlinkConfig.create name: 'ip', value: '127.0.0.1'
      TrustlinkConfig.bot_ips.should eq(['127.0.0.1'])
    end
  end
end
