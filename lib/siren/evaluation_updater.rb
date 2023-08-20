# frozen_string_literal: true

require_relative 'company_state_service'

module Siren
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
      value = evaluation.score < 50 || evaluation.favorable? ? 1 : 5
      evaluation.score -= value
    end

    def evaluate
      CompanyStateService.active?(evaluation.value) ? update_as_active : update_as_inactive
    end

    def update_as_active
      evaluation.state = 'favorable'
      evaluation.reason = 'company_opened'
      evaluation.score = 100
    end

    def update_as_inactive
      evaluation.state = 'unfavorable'
      evaluation.reason = 'company_closed'
      evaluation.score = 100
    end
  end
end
