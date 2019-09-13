class LogsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create
  http_basic_authenticate_with BASIC_AUTH.merge(only: :create)

  def create
    parser = LogParser.new
    request.body.each do |line|
      if (json = parser.parse_line(line))
        user_id, school_id, method, path = json['user_id'], json['school_id'], json['method'], json['path']

        if user_id.present? && school_id.present? && method.present? && path.present?
          user = User.find_or_create_by id: user_id
          Activity.log user, school_id, [method, path].join(' '), parser.last_time
        else
          Rails.logger.debug("no user/school/method/path '#{line[0..100]}'")
        end
      else
        Rails.logger.debug("skipping '#{line[0..100]}'")
      end
    end
    head :ok
  end
end
