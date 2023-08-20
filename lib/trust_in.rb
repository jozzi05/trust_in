# frozen_string_literal: true

require 'siren/evaluation_updater'
require 'evaluation'

class TrustIn
  def initialize(evaluations)
    @evaluations = evaluations
  end

  def update_score
    @evaluations.each do |evaluation|
      Siren::EvaluationUpdater.new(evaluation).call if evaluation.type == 'SIREN'
    end
  end
end


