require 'json'

class LogParser
  DATE_PATTERN = '\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:[\d\.]{2,9}[+-]\d{2}:\d{2}'
  REQUEST_ID_PATTERN = '\[\w{8}-\w{4}-\w{4}-\w{4}-\w{12}\]'

  attr_reader :last_time

  def parse_line(line)
    if line =~ /^\d+ <\d+>\d+ (#{DATE_PATTERN}) (\w+) (\w+) ([\w.-]+) - (.*)$/
      @last_time, host, app, proc, content = $1, $2, $3, $4, $5

      return nil if app == 'heroku'
      return nil unless proc.start_with?('web')

      return nil unless content =~ /#{REQUEST_ID_PATTERN} (.+)$/

      request_content = $1.strip
      return nil unless request_content.start_with?('{') && request_content.end_with?('}')

      begin
        JSON.parse(request_content)
      rescue JSON::ParserError
        nil
      end

    else
      raise "Can't parse #{line.inspect}"
    end
  end
end