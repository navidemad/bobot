# FIX ERROR: uninitialized constant ApplicationCable::ActionCable
require 'rails_helper'

module Bobot
  RSpec.describe CommanderJob, type: :job do
    subject(:job) { described_class.perform_later(payload) }

    let :payload do
      {
        'sender' => {
          'id' => '2'
        },
        'recipient' => {
          'id' => '3'
        },
        'timestamp' => 145_776_419_762_7,
        'message' => {
          'mid' => 'mid.1457764197618:41d102a3e1ae206a38',
          'seq' => 73,
          'text' => 'Hello, bot!'
        }
      }
    end

    it 'queues the job' do
      expect { job }.to have_enqueued_job(described_class)
        .with(payload)
        .on_queue("default")
    end
  end
end
