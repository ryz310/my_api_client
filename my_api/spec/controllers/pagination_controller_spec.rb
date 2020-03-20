# frozen_string_literal: true

describe PaginationController, type: :controller do
  describe '#index' do
    let(:first_page) do
      {
        links: {
          next: 'https://example.com/test/pagination?page=2',
        },
        page: 1,
      }.to_json
    end

    let(:second_page) do
      {
        links: {
          next: 'https://example.com/test/pagination?page=3',
          previous: 'https://example.com/test/pagination?page=1',
        },
        page: 2,
      }.to_json
    end

    let(:third_page) do
      {
        links: {
          previous: 'https://example.com/test/pagination?page=2',
        },
        page: 3,
      }.to_json
    end

    context 'without page' do
      it 'returns a 1st page contents including 2nd page link' do
        get '/pagination'
        expect(response.status).to eq 200
        expect(response.body).to eq first_page
      end
    end

    context 'with page = 1' do
      it 'returns a 1st page contents including 2nd page link' do
        get '/pagination', page: 1
        expect(response.status).to eq 200
        expect(response.body).to eq first_page
      end
    end

    context 'with page = 2' do
      it 'returns a 2nd page contents including 3rd page link' do
        get '/pagination', page: 2
        expect(response.status).to eq 200
        expect(response.body).to eq second_page
      end
    end

    context 'with page = 3' do
      it 'returns a 3rd page contents not including next page link' do
        get '/pagination', page: 3
        expect(response.status).to eq 200
        expect(response.body).to eq third_page
      end
    end

    context 'with page = 4' do
      it 'returns 404 NOT FOUND' do
        get '/pagination', page: 4
        expect(response.status).to eq 404
        expect(response.body).to be_blank
      end
    end
  end
end
