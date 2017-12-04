module Bobot
  class CommanderJob < ApplicationJob
    queue_as do
      if Bobot.config.commander_queue_name.present?
        Bobot.config.commander_queue_name
      else
        :default
      end
    end

    def perform(payload:)
      Bobot::Commander.trigger(payload)
    end
  end
end
