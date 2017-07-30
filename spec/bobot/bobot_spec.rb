require 'rails_helper'

RSpec.describe Bobot do
  describe '#configure' do
    it 'sets correct configuration' do
      Bobot.configure do |config|
        config.app_id = '1'
        config.app_secret = '2'
        config.page_access_token = '3'
        config.verify_token = '4'
        config.page_id = '5'
        config.debug_log = true
      end
      expect(Bobot.app_id).to eql('1')
      expect(Bobot.app_secret).to eql('2')
      expect(Bobot.page_access_token).to eql('3')
      expect(Bobot.verify_token).to eql('4')
      expect(Bobot.page_id).to eql('5')
      expect(Bobot.debug_log).to eql(true)
    end
  end
end
