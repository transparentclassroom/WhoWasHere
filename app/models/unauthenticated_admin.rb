# Null object for authentication
class UnauthenticatedAdmin
  def name
    nil
  end

  def email
    nil
  end

  def authenticated?
    false
  end
end
