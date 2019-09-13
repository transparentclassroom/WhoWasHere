class LogsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create
  http_basic_authenticate_with BASIC_AUTH.merge(only: :create)

  def create
    parser = LogParser.new
    request.body.each do |line|
      if (json = parser.parse_line(line))
        email, school_id, method, path = json['user'], json['school'], json['method'], json['path']

        if email.present? && school_id.present? && method.present? && path.present?
          user = User.find_or_create_by email: email
          Activity.log user, school_id, [method, path].join(' '), parser.last_time
        end
      end
    end
    head :ok
  end
end
