require 'rails_helper'

RSpec.describe Bobot::Page do
  before do
    Bobot.configure do |config|
      config.pages << Bobot::Page.new(
        slug: 'slug_1',
        language: 'language',
        page_access_token: 'page_access_token',
        page_id: '123',
        get_started_payload: 'get_started_payload',
      )
      config.pages << Bobot::Page.new(
        slug: 'slug_2',
        language: 'language',
        page_access_token: 'page_access_token',
        page_id: '456',
        get_started_payload: 'get_started_payload',
      )
    end
  end

  describe '#find' do
    it 'find page in the config' do
      expect(Bobot::Page.find("123").page_id).to eq("123")
      expect(Bobot::Page.find(123).page_id).to eq("123")
      expect(Bobot::Page.find("456").page_id).to eq("456")
      expect(Bobot::Page.find(456).page_id).to eq("456")
    end
    it 'not find page in the config' do
      expect(Bobot::Page.find("1664")).to eq(nil)
      expect(Bobot::Page.find(1664)).to eq(nil)
    end
  end
  
  describe '#find_by_slug' do
    it 'find page in the config' do
      expect(Bobot::Page.find_by_slug("slug_1").slug).to eq("slug_1")
      expect(Bobot::Page.find_by_slug("slug_2").slug).to eq("slug_2")
    end
    it 'not find page in the config' do
      expect(Bobot::Page.find_by_slug("slug_unknown")).to eq(nil)
    end
  end
  
  describe '#[]' do
    it 'find page in the config' do
      expect(Bobot::Page["123"].page_id).to eq("123")
      expect(Bobot::Page[123].page_id).to eq("123")
      expect(Bobot::Page["456"].page_id).to eq("456")
      expect(Bobot::Page[456].page_id).to eq("456")
      expect(Bobot::Page["slug_1"].slug).to eq("slug_1")
      expect(Bobot::Page["slug_2"].slug).to eq("slug_2")
    end
    it 'not find page in the config' do
      expect(Bobot::Page["1664"]).to eq(nil)
      expect(Bobot::Page[1664]).to eq(nil)
      expect(Bobot::Page["slug_unknown"]).to eq(nil)
    end
  end
end
