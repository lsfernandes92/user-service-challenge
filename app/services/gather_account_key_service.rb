class GatherAccountKeyService
  def initialize(email, key)
    @email = email
    @key = key
  end

  def perform
    user = User.find_by!(email: @email)
    
    gather_account_key

    user.account_key = @external_account_key
    user.save!
  end

  private

    def gather_account_key
      @external_account_key ||= account_key_service.gather_account_key(
        email: @email,
        key: @key
      )
    end

    def account_key_service
      @account_key_service ||= ::Api::ExternalServices::AccountKeyService
    end
end