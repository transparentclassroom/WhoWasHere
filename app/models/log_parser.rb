require "json"

class LogParser
  DATE_PATTERN = '\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:[\d\.]{2,9}[+-]\d{2}:\d{2}'
  REQUEST_ID_PATTERN = '\[\w{8}-\w{4}-\w{4}-\w{4}-\w{12}\]'
  REMOTE_IP_PATTERN = '\[[\d:\.]+\]'

  attr_reader :last_time

  def parse_line(line)
    if line =~ /^\d+ <\d+>\d+ (#{DATE_PATTERN}) (\w+) (\w+) ([\w.-]+) - (.*)$/
      @last_time, _host, app, proc, content = $1, $2, $3, $4, $5

      return nil if app == "heroku"
      return nil unless proc.start_with?("web")

      request_content = if content =~ /#{REQUEST_ID_PATTERN} #{REMOTE_IP_PATTERN} (.+)$/
                          $1.strip
                        elsif content =~ /#{REQUEST_ID_PATTERN} (.+)$/
                          $1.strip
                        else
                          nil
                        end

      return nil unless request_content && request_content.start_with?("{") && request_content.end_with?("}")

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
