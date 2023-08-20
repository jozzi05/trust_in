# frozen_string_literal: true

FactoryBot.define do
  factory :evaluation do
    score { 50 }
    reason { 'company_closed' }

    trait(:siren) do
      type { 'SIREN' }
      value { '123456789' }
    end

    trait(:vat) do
      type { 'VAT' }
      value { 'IE6388047V' }
    end

    trait(:unconfirmed) { state { 'unconfirmed' } }
    trait(:favorable) { state { 'favorable' } }
    trait(:unfavorable) { state { 'unfavorable' } }
    trait(:ongoing_database_update) { reason { 'ongoing_database_update' } }
    trait(:company_opened) { reason { 'company_opened' } }
    trait(:company_closed) { reason { 'company_closed' } }
    trait(:unable_to_reach_api) { reason { 'unable_to_reach_api' } }

    initialize_with { new(**attributes) }
  end
end
