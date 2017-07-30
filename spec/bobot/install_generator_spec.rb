require 'rails_helper'
require 'generators/bobot/install_generator'

RSpec.describe Bobot::InstallGenerator, type: :generator do
  destination File.expand_path('../../dummy/tmp/generator', __FILE__)
  arguments ['bobot']

  before do
    prepare_destination
  end

  it 'mounts Bobot as Engine and generates Bobot Initializer' do
    expect_any_instance_of(generator_class).to receive(:route).
      with('mount Bobot::Engine => \'/bobot\', as: \'bobot\'')
    silence_stream(STDOUT) do
      generator.invoke('install')
    end
    expect(destination_root).to have_structure {
      directory 'config' do
        directory 'initializers' do
          file 'bobot.rb' do
            contains 'Bobot.configure'
          end
        end
        directory 'locales' do
          file 'bobot.en.yml' do
            contains 'en:'
          end
          file 'bobot.fr.yml' do
            contains 'fr:'
          end
        end
      end
      directory 'app' do
        directory 'bobot' do
          file 'workflow.rb' do
            contains 'Bobot::Commander'
          end
        end
      end
    }
  end
end
