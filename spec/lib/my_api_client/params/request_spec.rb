# frozen_string_literal: true

RSpec.describe MyApiClient::Params::Request do
  let(:instance) { described_class.new(method, uri, headers, body) }
  let(:method) { :get }
  let(:uri) { URI.parse 'https://example.com/path/to/resource?key=value' }

  describe 'headers and body' do
    context 'with Hash' do
      let(:headers) { { 'Content-Type': 'application/json; charset=utf-8' } }
      let(:body) { { username: 'John Smith' } }

      describe '#to_sawyer_args' do
        it 'returns value formatted for arguments of Sawyer::Agent#call' do
          expect(instance.to_sawyer_args).to eq [
            :get,
            'https://example.com/path/to/resource?key=value',
            { username: 'John Smith' },
            { headers: { 'Content-Type': 'application/json; charset=utf-8' } },
          ]
        end
      end

      describe '#metadata' do
        context 'when body parameter is blank' do
          let(:body) { nil }

          it 'returns hashed parameters which omitted body parameter' do
            expect(instance.metadata).to eq(
              line: 'GET https://example.com/path/to/resource?key=value',
              headers: { 'Content-Type': 'application/json; charset=utf-8' }
            )
          end
        end

        context 'when query parameter is blank' do
          let(:method) { :post }
          let(:uri) { URI.parse 'https://example.com/path/to/resource' }

          it 'returns hashed parameters which omitted query parameter' do
            expect(instance.metadata).to eq(
              line: 'POST https://example.com/path/to/resource',
              headers: { 'Content-Type': 'application/json; charset=utf-8' },
              body: { username: 'John Smith' }
            )
          end
        end
      end

      describe '#inspect' do
        it 'returns contents as string for to be readable for human' do
          expect(instance.inspect)
            .to eq '{:method=>:get, ' \
                   ':uri=>"https://example.com/path/to/resource?key=value", ' \
                   ':headers=>{:"Content-Type"=>"application/json; charset=utf-8"}, ' \
                   ':body=>{:username=>"John Smith"}}'
        end
      end
    end

    context 'with Proc' do
      let(:data_array) { %w[request_id user_name] }

      let(:headers) do
        lambda {
          { 'X-Request-Id': data_array.shift }
        }
      end

      let(:body) do
        lambda {
          { username: data_array.shift }
        }
      end

      describe '#to_sawyer_args' do
        it 'returns value formatted for arguments of Sawyer::Agent#call' do
          expect(instance.to_sawyer_args).to eq [
            :get,
            'https://example.com/path/to/resource?key=value',
            { username: 'user_name' },
            { headers: { 'X-Request-Id': 'request_id' } },
          ]
        end
      end

      describe '#metadata' do
        context 'when body parameter is blank' do
          let(:body) { nil }

          it 'returns hashed parameters which omitted body parameter' do
            expect(instance.metadata).to eq(
              line: 'GET https://example.com/path/to/resource?key=value',
              headers: { 'X-Request-Id': 'request_id' }
            )
          end
        end

        context 'when query parameter is blank' do
          let(:method) { :post }
          let(:uri) { URI.parse 'https://example.com/path/to/resource' }

          it 'returns hashed parameters which omitted query parameter' do
            expect(instance.metadata).to eq(
              line: 'POST https://example.com/path/to/resource',
              headers: { 'X-Request-Id': 'request_id' },
              body: { username: 'user_name' }
            )
          end
        end
      end

      describe '#inspect' do
        it 'returns contents as string for to be readable for human' do
          expect(instance.inspect)
            .to eq '{:method=>:get, ' \
                   ':uri=>"https://example.com/path/to/resource?key=value", ' \
                   ':headers=>{:"X-Request-Id"=>"request_id"}, ' \
                   ':body=>{:username=>"user_name"}}'
        end
      end
    end
  end
end
