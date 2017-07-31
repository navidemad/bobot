require 'rails_helper'
require 'helpers/graph_api_helpers'

RSpec.describe Bobot::Subscription do
  let(:access_token) { 'access token' }
  let(:page_id) { 'page-id' }

  let(:subscription_url) do
    File.join(
      described_class::GRAPH_FB_URL,
      described_class::GRAPH_FB_VERSION,
      "/#{page_id}",
      '/subscribed_apps',
    )
  end

  before do
    Bobot.page_access_token = access_token
    Bobot.page_id = page_id
  end

  describe '.set' do
    context 'with a successful response' do
      before do
        puts subscription_url
        stub_request(:post, subscription_url)
          .with(query: { access_token: access_token})
          .to_return(
            body: ActiveSupport::JSON.encode(
              success: true,
            ),
            status: :ok,
            headers: default_graph_api_response_headers
          )
      end

      it 'returns hash' do
        expect(
          subject.set(
            query: {
              page_id: page_id,
              access_token: access_token,
            }
          )
        ).to include('success' => true)
      end
    end

    context 'with an unsuccessful response' do
      let(:error_message) { 'Invalid OAuth access token.' }

      before do
        stub_request(:post, subscription_url)
          .with(query: { access_token: access_token })
          .to_return(
            body: {
              'error' => {
                'message' => error_message,
                'type' => 'OAuthException',
                'code' => 190,
                'fbtrace_id' => 'Hlssg2aiVlN'
              }
            }.to_json,
            status: :ok,
            headers: default_graph_api_response_headers
          )
      end

      it 'raises an error' do
        expect do
          subject.set(
            query: {
              page_id: page_id,
              access_token: access_token,
            }
          )
        end.to raise_error(Bobot::AccessTokenError)
      end
    end
  end

  describe '.unset' do
    context 'with a successful response' do
      before do
        stub_request(:delete, subscription_url)
          .with(query: { access_token: access_token })
          .to_return(
            body: ActiveSupport::JSON.encode(
              success: true,
            ),
            status: :ok,
            headers: default_graph_api_response_headers
          )
      end

      it 'returns hash' do
        expect(
          subject.unset(
            query: {
              page_id: page_id,
              access_token: access_token,
            }
          )
        ).to include('success' => true)
      end
    end

    context 'with an unsuccessful response' do
      let(:error_message) { 'Invalid OAuth access token.' }

      before do
        stub_request(:delete, subscription_url)
          .with(query: { access_token: access_token })
          .to_return(
            body: {
              'error' => {
                'message' => error_message,
                'type' => 'OAuthException',
                'code' => 190,
                'fbtrace_id' => 'Hlssg2aiVlN'
              }
            }.to_json,
            status: :ok,
            headers: default_graph_api_response_headers
          )
      end

      it 'raises an error' do
        expect do
          subject.unset(
            query: {
              page_id: page_id,
              access_token: access_token,
            }
          )
        end.to raise_error(Bobot::AccessTokenError)
      end
    end
  end
end
