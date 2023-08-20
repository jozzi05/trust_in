# frozen_string_literal: true

module Vat
  class CompanyStateService
    DATA = [
      { state: 'favorable', reason: 'company_opened' },
      { state: 'unfavorable', reason: 'company_closed' },
      { state: 'unconfirmed', reason: 'unable_to_reach_api' },
      { state: 'unconfirmed', reason: 'ongoing_database_update' }
    ].freeze

    def self.fetch_details(_value)
      DATA.sample
    end
  end
end
