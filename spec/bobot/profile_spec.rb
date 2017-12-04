require 'rails_helper'
require 'helpers/graph_api_helpers'

RSpec.describe Bobot::Profile do
  let(:access_token) { 'access token' }

  let(:messenger_profile_url) do
    File.join(
      described_class::GRAPH_FB_URL,
      '/me/messenger_profile?include_headers=false'
    )
  end

  before do
    Bobot.config.pages << Bobot::Page.new(
      page_access_token: access_token,
    )
  end

  describe '.set' do
    context 'with a successful response' do
      before do
        stub_request(:post, messenger_profile_url)
          .with(
            query: {
              access_token: access_token
            },
            body: ActiveSupport::JSON.encode(
              get_started: {
                payload: 'GET_STARTED_PAYLOAD'
              }
            )
          )
          .to_return(
            body: ActiveSupport::JSON.encode(
              result: 'Successfully added Get Started button'
            ),
            status: :ok,
            headers: default_graph_api_response_headers
          )
      end

      it 'returns hash' do
        expect(
          subject.set(
            body: {
              get_started: {
                payload: 'GET_STARTED_PAYLOAD'
              }
            },
            query: {
              access_token: access_token
            }
          )
        ).to include('result' => 'Successfully added Get Started button')
      end
    end

    context 'with an unsuccessful response' do
      let(:error_message) { 'Invalid OAuth access token.' }

      before do
        stub_request(:post, messenger_profile_url)
          .with(query: { access_token: access_token })
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
          subject.set(
            body: {
              get_started: {
                payload: 'GET_STARTED_PAYLOAD'
              }
            },
            query: {
              access_token: access_token
            }
          )
        end.to raise_error(Bobot::AccessTokenError)
      end
    end
  end

  describe '.unset' do
    context 'with a successful response' do
      before do
        stub_request(:delete, messenger_profile_url)
          .with(
            query: {
              access_token: access_token
            },
            body: ActiveSupport::JSON.encode(
              fields: [
                'get_started'
              ]
            )
          )
          .to_return(
            body: ActiveSupport::JSON.encode(
              result: 'Successfully deleted Get Started button'
            ),
            status: :ok,
            headers: default_graph_api_response_headers
          )
      end

      it 'returns hash' do
        expect(
          subject.unset(
            body: {
              fields: [
                'get_started'
              ]
            },
            query: {
              access_token: access_token
            }
          )
        ).to include('result' => 'Successfully deleted Get Started button')
      end
    end

    context 'with an unsuccessful response' do
      let(:error_message) { 'Invalid OAuth access token.' }

      before do
        stub_request(:delete, messenger_profile_url)
          .with(query: { access_token: access_token })
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
          subject.unset(
            body: {
              fields: [
                'get_started'
              ]
            },
            query: {
              access_token: access_token
            }
          )
        end.to raise_error(Bobot::AccessTokenError)
      end
    end
  end
end
