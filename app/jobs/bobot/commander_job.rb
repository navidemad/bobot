module Bobot
  class CommanderJob < ApplicationJob
    queue_as :default

    def perform(payload:)
      Bobot::Commander.trigger(payload)
    end
  end
end
