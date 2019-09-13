require 'json'

class LogParser
  DATE_PATTERN = '\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{6}\+\d{2}:\d{2}'
  REQUEST_ID_PATTERN = '\[\w{8}-\w{4}-\w{4}-\w{4}-\w{12}\]'

  attr_reader :last_time

  def parse_line(line)
    if line =~ /^\d+ <\d+>\d+ (#{DATE_PATTERN}) \w+ \w+ [\w.]+ - .*#{REQUEST_ID_PATTERN} (.+)$/
      @last_time = $1
      content = $2.strip
      if content.start_with?('{') && content.end_with?('}')
        JSON.parse($2)
      else
        nil
      end

    else
      raise "Can't parse #{line.inspect}"
    end
  end
end