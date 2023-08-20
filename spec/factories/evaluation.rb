# frozen_string_literal: true

FactoryBot.define do
  factory :evaluation do
    value { '123456789' }
    score { 50 }
    reason { 'company_closed' }

    trait(:siren) { type { 'SIREN' } }
    trait(:vat) { type { 'VAT' } }
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
