require 'rails_helper'

RSpec.describe Bobot do
  describe '#configure' do
    it 'sets correct configuration' do
      Bobot.configure do |config|
        config.app_id = 'app_id'
        config.app_secret = 'app_secret'
        config.verify_token = 'verify_token'
        config.debug_log = true
        config.async = true
        config.pages << Bobot::Configuration::Page.new(
          slug: 'slug',
          language: 'language',
          page_access_token: 'page_access_token',
          page_id: 'page_id',
          get_started_payload: 'get_started_payload',
        )
      end
      expect(Bobot.config.app_id).to eql('app_id')
      expect(Bobot.config.app_secret).to eql('app_secret')
      expect(Bobot.config.verify_token).to eql('verify_token')
      expect(Bobot.config.debug_log).to eql(true)
      expect(Bobot.config.async).to eql(true)
      expect(Bobot.config.pages[0].slug).to eql('slug')
      expect(Bobot.config.pages[0].language).to eql('language')
      expect(Bobot.config.pages[0].page_access_token).to eql('page_access_token')
      expect(Bobot.config.pages[0].page_id).to eql('page_id')
      expect(Bobot.config.pages[0].get_started_payload).to eql('get_started_payload')
    end
  end
end
