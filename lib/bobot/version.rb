module Bobot
  class Version
    MAJOR = 3
    MINOR = 0
    PATCH = 4
    PRE = nil

    class << self
      def to_s
        [MAJOR, MINOR, PATCH, PRE].compact.join('.')
      end
    end
  end
end
