# frozen_string_literal: true

require 'siren/evaluation_updater'
require 'vat/evaluation_updater'
require 'evaluation'

class TrustIn
  def initialize(evaluations)
    @evaluations = evaluations
  end

  def update_score
    @evaluations.each do |evaluation|
      if evaluation.type == 'SIREN'
        Siren::EvaluationUpdater.new(evaluation).call
      elsif evaluation.type == 'VAT'
        Vat::EvaluationUpdater.new(evaluation).call
      end
    end
  end
end
