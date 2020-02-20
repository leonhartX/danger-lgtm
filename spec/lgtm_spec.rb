# frozen_string_literal: true

require File.expand_path('spec_helper', __dir__)

describe Danger::DangerLgtm do
  it 'should be a plugin' do
    expect(Danger::DangerLgtm.new(nil)).to be_a(Danger::Plugin)
  end

  describe '#check_lgtm' do
    shared_examples 'returns correctly message' do
      it { expect(markdowns.first.message).to match(/#{image_url}/) }
    end

    let(:lgtm) { dangerfile.lgtm }
    let(:dangerfile) { testing_dangerfile }

    let(:https_only) { false }
    let(:image_url) { nil }

    let(:connection_mock) { double('Connection', request: response) }

    subject(:markdowns) do
      dangerfile.status_report[:markdowns]
    end

    context 'with HTTP errors' do
      let(:message) { 'Hello World!' }
      let(:response) { failure_response_mock(message) }

      it 'handles error' do
        expect($stdout).to receive(:puts).with(message)

        allow(Net::HTTP).to receive(:start).and_return(connection_mock)
        lgtm.check_lgtm(https_image_only: https_only, image_url: image_url)

        expect(markdowns.first.message).to eq("<h1 align='center'>LGTM</h1>")
      end
    end

    context 'without HTTP errors' do
      before do
        allow(Net::HTTP).to receive(:start).and_return(connection_mock)
      end

      before do
        lgtm.check_lgtm(https_image_only: https_only, image_url: image_url)
      end

      context 'with passed image url' do
        let(:lgtm_image) { 'https://example.com/image1.jpg' }
        let(:image_url) { 'https://example.com/image2.jpg' }
        let(:response) { success_response_mock(lgtm_image) }

        it_behaves_like 'returns correctly message'
      end

      context 'without passed image url' do
        let(:lgtm_image) { 'https://example.com/image.jpg' }
        let(:image_url) { 'https://example.com/image.jpg' }
        let(:response) { success_response_mock(lgtm_image) }

        it_behaves_like 'returns correctly message'
      end
    end
  end
end
