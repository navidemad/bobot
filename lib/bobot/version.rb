module Bobot
  class Version
    MAJOR = 2
    MINOR = 6
    PATCH = 1
    PRE = nil

    class << self
      def to_s
        [MAJOR, MINOR, PATCH, PRE].compact.join('.')
      end
    end
  end
end
