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

      it "lgtm with no violation" do
        @lgtm.lgtm

        expect(@dangerfile.status_report[:message].length).to eq(1)
      end
    end
  end
end
