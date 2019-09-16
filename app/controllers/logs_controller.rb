class LogsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create
  http_basic_authenticate_with BASIC_AUTH.merge(only: :create)

  def create
    parser = LogParser.new
    request.body.each do |line|
      if (json = parser.parse_line(line))
        user_id, school_id, method, path = json['user_id'], json['school_id'], json['method'], json['path']

        if user_id.present? && school_id.present? && method.present? && path.present?
          user = find_user user_id
          Activity.log user, school_id, [method, path].join(' '), parser.last_time
        else
          Rails.logger.debug("no user/school/method/path '#{line[0..200]}'")
        end
      else
        Rails.logger.debug("skipping '#{line[0..200]}'")
      end
    end
    head :ok
  end

  private

  def find_user(id)
    # this sometimes fails because we get 2 request back to back, that both try to create the user
    # so, if it fails, just look for it again
    User.find_or_create_by id: id
  rescue ActiveRecord::RecordNotUnique
    User.find id
  end
end
