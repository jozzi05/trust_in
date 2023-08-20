# frozen_string_literal: true

require_relative 'company_state_service'

module Vat
  class EvaluationUpdater
    def initialize(evaluation)
      @evaluation = evaluation
    end

    def call
      return if evaluation.unfavorable?

      requires_new_evaluation? ? evaluate : update_score
    end

    private

    attr_reader :evaluation

    def requires_new_evaluation?
      evaluation.score.zero? || evaluation.unconfirmed? && evaluation.ongoing_database_update?
    end

    def update_score
      value = evaluation.score >= 50 || evaluation.favorable? ? 1 : 3
      evaluation.score -= value
    end

    def evaluate
      state_details = CompanyStateService.fetch_details(evaluation.value)
      evaluation.state = state_details[:state]
      evaluation.reason = state_details[:reason]
      evaluation.score = 100
    end
  end
end
