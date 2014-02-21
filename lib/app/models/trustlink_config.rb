class TrustlinkConfig < ActiveRecord::Base
  class << self
    def bot_ips
      where(name: 'ip').pluck(:value)
    end

    def start_code
      where(name: 'start').first.value
    end

    def stop_code
      where(name: 'end').first.value
    end
  end
end
