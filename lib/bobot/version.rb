module Bobot
  class Version
    MAJOR = 3
    MINOR = 7
    PATCH = 6
    PRE = nil

    class << self
      def to_s
        [MAJOR, MINOR, PATCH, PRE].compact.join('.')
      end
    end
  end
end
