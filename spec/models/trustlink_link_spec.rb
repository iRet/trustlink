require 'spec_helper'

describe TrustlinkLink do
  before do
    TrustlinkLink.delete_all
  end

  context '#host' do
    it 'should return host without path' do
      link = TrustlinkLink.create(
        page: '/test',
        anchor: 'You must see',
        text: 'very interesting thing',
        url: 'http://kremlin.ru/rss'
        )
      link.host.should eq('kremlin.ru')
    end
  end
end
