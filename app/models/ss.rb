# describes SS of video (for example: 00:00:11) from seconds
class SS
  attr_reader :result_hours

  def initialize(seconds)
    @result_seconds = seconds
    @result_hours = 0
    @result_minutes = 0
  end

  def ss
    [
      sprintf('%02d', result_seconds),
      sprintf('%02d', result_minutes),
      sprintf('%02d', result_hours)
    ].reverse.join(':')
  end

  def at_percentage(percentage)
    @result_seconds = @result_seconds * percentage / 100
    ss
  end

  def result_minutes
    if @result_minutes > 59
      @result_hours = @result_minutes.to_i / 60
      @result_minutes = @result_minutes - (@result_hours * 60)
    end
    @result_minutes
  end

  def result_seconds
    if @result_seconds > 59
      @result_minutes = @result_seconds.to_i / 60
      @result_seconds = @result_seconds - (@result_minutes * 60)
    end
    @result_seconds
  end
end
