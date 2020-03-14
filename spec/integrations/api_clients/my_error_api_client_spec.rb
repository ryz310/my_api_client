# frozen_string_literal: true

require './example/api_clients/my_error_api_client'

RSpec.describe 'Integration test with My Error API', type: :integration do
  let(:api_client) { MyErrorApiClient.new }

  describe 'GET error/:code' do
    context 'with error code: 0' do
      it do
        expect { api_client.get_error(code: 0) }
          .to raise_error(MyErrors::ErrorCode00)
      end
    end

    context 'with error code: 10' do
      it do
        expect { api_client.get_error(code: 10) }
          .to raise_error(MyErrors::ErrorCode10)
      end
    end

    context 'with error code: 20 to 29' do
      it do
        expect { api_client.get_error(code: rand(20..29)) }
          .to raise_error(MyErrors::ErrorCode2x)
      end
    end

    context 'with error code: 30' do
      it do
        expect { api_client.get_error(code: 30) }
          .to raise_error(MyErrors::ErrorCode30)
      end
    end

    context 'with error code: other' do
      it do
        expect { api_client.get_error(code: 40) }
          .to raise_error(MyErrors::ErrorCodeOther)
      end
    end
  end
end
