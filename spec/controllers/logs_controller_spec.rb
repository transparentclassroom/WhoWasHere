require 'rails_helper'

RSpec.describe LogsController, type: :controller do
  describe '#create' do
    it 'should record activity' do
      post :create, body: 'food bar'
    end
  end
end
