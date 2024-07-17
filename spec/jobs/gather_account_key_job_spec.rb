# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe GatherAccountKeyJob, type: :job do
  include ActiveJob::TestHelper

  describe '#perform' do
    let(:email) { 'foo@email.com' }
    let(:key) { 'r4nd0mk3y' }
    let(:error_class) { StandardError }

    subject { described_class.perform_async(email, key) }

    it 'queues the job' do
      expect { subject }.to change(GatherAccountKeyJob.jobs, :size).by(1)
    end

    it 'queues in the default queue' do
      expect { subject }.to change(Sidekiq::Queues['default'], :size).by(1)
    end

    xit 'calls GatherAccountKeyService' do
      expect(GatherAccountKeyService).to receive(:new).with(email, key)
      expect_any_instance_of(GatherAccountKeyService).to receive(:perform)
      GatherAccountKeyJob.perform_async(email, key)
    end

    context 'with failing GatherAccountKeyService' do
      xit 'raises an error' do
        allow(GatherAccountKeyService).to receive(:new).and_raise(StandardError)
        expect { GatherAccountKeyJob.perform_async(email, key) }.to raise_error(StandardError)
      end
    end

    xit 'retries on error and succeeds on retry' do
      expect(GatherAccountKeyService.new(email, key)).to receive(:perform).and_raise(error_class).once
      expect { GatherAccountKeyJob.perform_async(arguments) }.to raise_error(error_class)

      Sidekiq::Testing.disable!
      allow(GatherAccountKeyService).to receive(:perform).and_return(true)
      GatherAccountKeyJob.perform_async(arguments)
      Sidekiq::Testing.inline!
    end
  end
end
