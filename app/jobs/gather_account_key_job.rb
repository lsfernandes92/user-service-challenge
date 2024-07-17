class GatherAccountKeyJob
  include Sidekiq::Job

  def perform(email, key)
    GatherAccountKeyService.new(email, key).perform
  end
end
