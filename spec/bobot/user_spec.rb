require 'rails_helper'
require 'helpers/graph_api_helpers'

RSpec.describe Bobot::User do
  let(:access_token) { 'access token' }
  let(:page_id) { 'page-id' }
  let(:fb_id) { rand(100_000_000).to_s.ljust(10, "0") }
  let(:fields) { %w(first_name last_name) }

  let(:user_url) do
    File.join(
      described_class::GRAPH_FB_URL,
      described_class::GRAPH_FB_VERSION,
      "/#{fb_id}"
    )
  end

  before do
    Bobot.config.pages << Bobot::Configuration::Page.new(
      page_access_token: access_token,
      page_id:           page_id,
    )
  end

  describe '.get_profile' do
    context 'with a successful response' do
      before do
        stub_request(:get, user_url)
          .with(
            query: {
              fields: fields.join(','),
              access_token: access_token,
            },
          )
          .to_return(
            body: ActiveSupport::JSON.encode({ first_name: "Foo", last_name: "Bar" }),
            status: :ok,
            headers: default_graph_api_response_headers
          )
      end

      it 'returns user hash' do
        expect(
          subject.get_profile(
            query: {
              fb_id: fb_id,
              fields: fields,
              access_token: access_token,
            }
          )
        ).to eq({ "first_name" => "Foo", "last_name" => "Bar" })
      end
    end

    context 'with an unsuccessful response' do
      let(:error_message) { 'Invalid OAuth access token.' }

      before do
        stub_request(:get, user_url)
          .with(
            query: {
              fields: fields.join(','),
              access_token: access_token,
            },
          )
          .to_return(
            body: ActiveSupport::JSON.encode(
              'error' => {
                'message' => error_message,
                'type' => 'OAuthException',
                'code' => 190,
                'fbtrace_id' => 'Hlssg2aiVlN'
              }
            ),
            status: :ok,
            headers: default_graph_api_response_headers
          )
      end

      it 'raises an error' do
        expect do
          subject.get_profile(
            query: {
              fb_id: fb_id,
              fields: fields,
              access_token: access_token,
            }
          )
        end.to raise_error(Bobot::AccessTokenError)
      end
    end
  end
end
