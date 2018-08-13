# frozen_string_literal: true

require File.expand_path('spec_helper', __dir__)

describe Danger::DangerLgtm do
  def mock(request_url: 'https://lgtm.in/p/sSuI4hm0q',
           actual_image_url: 'https://example.com/image.jpg')
    double(
      :[] => request_url,
      body: JSON.generate(
        actualImageUrl: actual_image_url
      )
    )
  end

  it 'should be a plugin' do
    expect(Danger::DangerLgtm.new(nil)).to be_a(Danger::Plugin)
  end

  describe '#check_lgtm' do
    subject do
      lgtm.check_lgtm(
        https_image_only: https_image_only,
        image_url: image_url
      )
    end

    let(:dangerfile) { testing_dangerfile }
    let(:lgtm) { dangerfile.lgtm }
    let(:https_image_only) { false } # default false
    let(:image_url) {} # default nil

    shared_examples 'returns correctly message' do
      it do
        allow(Net::HTTP).to receive(:start).and_return(mock)
        is_expected

        expect(dangerfile.status_report[:markdowns][0].message)
          .to match(expected_message)
      end
    end

    context 'with Dangerfile' do
      it 'when no violation' do
        is_expected
        expect(dangerfile.status_report[:markdowns].length).to eq(1)
      end

      it 'lgtm with errors' do
        allow(lgtm).to receive(:validate_response)
          .and_raise(::Lgtm::Errors::UnexpectedError)
        is_expected
        expect(dangerfile.status_report[:markdowns][0].message)
          .to eq("<h1 align='center'>LGTM</h1>")
      end

      context 'pick random pic from lgtm.in' do
        let(:expected_message) { %r{https:\/\/example.com\/image.jpg} }
        it_behaves_like 'returns correctly message'
      end

      context 'pick random pic from lgtm.in with https_image_only option' do
        let(:https_image_only) { true }
        let(:expected_message) { %r{https:\/\/example.com\/image.jpg} }
        it_behaves_like 'returns correctly message'
      end

      context 'use given url' do
        let(:image_url) { 'http://imgur.com/Irk2wyX.jpg' }
        let(:expected_message) { %r{http:\/\/imgur\.com\/Irk2wyX\.jpg} }
        it_behaves_like 'returns correctly message'
      end
    end
  end
end
