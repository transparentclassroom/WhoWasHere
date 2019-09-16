require "rails_helper"

RSpec.describe Admin, type: :model do
  describe "::authenticate(auth_hash:, session:)" do
    def build_auth_hash(email: nil, name: nil)
      OpenStruct.new(info: OpenStruct.new(email: email, name: name))
    end
    let(:session) { {} }
    it "returns an Admin when the auth_hash has an @transparentclassroom.com email" do
      auth_hash = build_auth_hash(name: "user name", email: "user@transparentclassroom.com")\

      admin = Admin.authenticate(auth_hash: auth_hash, session: session)

      aggregate_failures do
        expect(admin.name).to eql("user name")
        expect(admin.email).to eql("user@transparentclassroom.com")
      end
    end

    it "throws an error if the user email does not end with @transparentclassroom.com" do
      auth_hash = build_auth_hash(name: "user name", email: "user@example.com")

      expect {
        Admin.authenticate(auth_hash: auth_hash, session: session)
      }.to raise_error(NotAuthorizedError)
    end

    it "remembers the admin in the session" do
      auth_hash = build_auth_hash(email: "user@transparentclassroom.com", name: "user name")

      admin = Admin.authenticate(auth_hash: auth_hash, session: session)
      expect(Admin.from_session(session: session)).to eql(admin)
    end
  end

  describe "::logout(auth_hash:, session:)" do
  end

  describe "::from_session(session:)" do
  end
end
