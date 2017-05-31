# frozen_string_literal: true

require File.expand_path('../spec_helper', __FILE__)

module Danger
  describe Danger::DangerLgtm do
    it 'should be a plugin' do
      expect(Danger::DangerLgtm.new(nil)).to be_a Danger::Plugin
    end

    #
    # You should test your custom attributes and methods here
    #
    describe 'with Dangerfile' do
      before do
        @dangerfile = testing_dangerfile
        @lgtm = @dangerfile.lgtm
      end

      # Some examples for writing tests
      # You should replace these with your own.

      it 'lgtm with no violation' do
        @lgtm.check_lgtm
        expect(@dangerfile.status_report[:markdowns].length).to eq(1)
      end

      it 'pick random pic from lgtm.in' do
        mock = double(
          :[] => 'https://lgtm.in/p/sSuI4hm0q',
          body: JSON.generate(
            actualImageUrl: 'https://example.com/image.jpg'
          )
        )

        allow(Net::HTTP).to receive(:start).and_return(mock)

        @lgtm.check_lgtm

        expect(@dangerfile.status_report[:markdowns][0].message)
          .to match(%r{https:\/\/example.com\/image.jpg})
      end

      it 'use given url' do
        @lgtm.check_lgtm image_url: 'http://imgur.com/Irk2wyX.jpg'
        expect(@dangerfile.status_report[:markdowns][0].message)
          .to match(%r{http:\/\/imgur\.com\/Irk2wyX\.jpg})
      end
    end
  end
end
