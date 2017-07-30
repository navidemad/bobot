module Bobot
  class HookJob < ApplicationJob
    queue_as :default

    def perform(payload)
      Bobot::Commander.trigger(payload)
    end
  end
end
