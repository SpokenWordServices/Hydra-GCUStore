module Hull
  class Iso8601

    attr_accessor :year, :month, :day
    def initialize
    end


    # parse a date.  Raises ArgumentError if the date does not parse.  Currently supports:
    # YYYY
    # YYYY-MM
    # YYYY-MM-DD
    # as well as a date range using / as the separator
    # This method does not yet support time, time-zone offset, nor durations or repeating intervals
    def self.parse(str)
      if parts = /^(\d{4})(?:-(0[1-9]|1[0-2]))?(?:-([12]\d|0[1-9]|3[01]))?$/.match(str)
        d = Iso8601.new
        d.year = parts[1]
        d.month = parts[2]
        d.day = parts[3]
        return d if d.valid?
      elsif parts = /^([^\/]+)\/([^\/]+)$/.match(str)
        d = Iso8601Range.new(parse(parts[1]), parse(parts[2]))
        return d if d.valid?
      end

      raise ArgumentError, 'invalid date'

      # #ISO time
      # ^([01]\d|2[0-3])\D?([0-5]\d)\D?([0-5]\d)?\D?(\d{3})?$

      # #ISO offset
      # ^([zZ]|([\+-])([01]\d|2[0-3])\D?([0-5]\d)?)?$

      # #ISO date and time
      # ^(\d{4})\D?(0[1-9]|1[0-2])\D?([12]\d|0[1-9]|3[01])(\D?([01]\d|2[0-3])\D?([0-5]\d)\D?([0-5]\d)?\D?(\d{3})?)?$

      # #ISO date, time, and offset (the works)
      # ^(\d{4})\D?(0[1-9]|1[0-2])\D?([12]\d|0[1-9]|3[01])(\D?([01]\d|2[0-3])\D?([0-5]\d)\D?([0-5]\d)?\D?(\d{3})?([zZ]|([\+-])([01]\d|2[0-3])\D?([0-5]\d)?)?)?$

    end

    def valid?
      if @month
        return false if @month.to_i > 12 || @month.to_i < 1
      end
      if @day
        begin
          Date.parse(to_s)
        rescue ArgumentError
          return false
        end
      end
      true
    end

    def to_s
      s = @year.dup
      s << "-#{@month}" if @month
      s << "-#{@day}" if @day
      s
    end

  end

  class Iso8601Range
    attr_accessor :start, :end

    def initialize (s, e) 
      @start = s
      @end = e
    end

    def valid?
      self.start.valid? && self.end.valid?
    end

    def to_s
      "#{self.start}/#{self.end}"

    end

  end
end
