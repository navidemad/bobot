require 'rails_helper'

RSpec.describe 'Check that the files we have changed have correct syntax' do
  it 'runs rubocop on changed ruby files' do
    result = system "bundle exec rubocop --config .rubocop.yml --fail-level warn"
    expect(result).to be(true)
  end
end
