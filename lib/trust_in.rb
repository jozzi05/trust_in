# frozen_string_literal: true

require 'json'
require 'net/http'

class TrustIn
  def initialize(evaluations)
    @evaluations = evaluations
  end

  def update_score
    @evaluations.each do |evaluation|
      if evaluation.type == 'SIREN'
        if evaluation.score.positive? && evaluation.state == 'unconfirmed' && evaluation.reason == 'ongoing_database_update'
          uri = URI('https://public.opendatasoft.com/api/records/1.0/search/?dataset=economicref-france-sirene-v3' \
            "&q=#{evaluation.value}&sort=datederniertraitementetablissement" \
            '&refine.etablissementsiege=oui')
          response = Net::HTTP.get(uri)
          parsed_response = JSON.parse(response)
          company_state = parsed_response['records'].first['fields']['etatadministratifetablissement']
          evaluation.score = 100

          if company_state == 'Actif'
            evaluation.state = 'favorable'
            evaluation.reason = 'company_opened'
          else
            evaluation.state = 'unfavorable'
            evaluation.reason = 'company_closed'
          end
        elsif evaluation.score >= 50
          if evaluation.state == 'unconfirmed' && evaluation.reason == 'unable_to_reach_api'
            evaluation.score = evaluation.score - 5
          elsif evaluation.state == 'favorable'
            evaluation.score = evaluation.score - 1
          end
        elsif evaluation.score <= 50 && evaluation.score.positive?
          evaluation.score = evaluation.score - 1 if evaluation.state == 'unconfirmed' && evaluation.reason == 'unable_to_reach_api' || evaluation.state == 'favorable'
        elsif evaluation.state == 'favorable' || evaluation.state == 'unconfirmed'
          uri = URI('https://public.opendatasoft.com/api/records/1.0/search/?dataset=economicref-france-sirene-v3' \
              "&q=#{evaluation.value}&sort=datederniertraitementetablissement" \
              '&refine.etablissementsiege=oui')
          response = Net::HTTP.get(uri)
          parsed_response = JSON.parse(response)
          company_state = parsed_response['records'].first['fields']['etatadministratifetablissement']
          evaluation.score = 100

          if company_state == 'Actif'
            evaluation.state = 'favorable'
            evaluation.reason = 'company_opened'
          else
            evaluation.state = 'unfavorable'
            evaluation.reason = 'company_closed'
          end
        end
      end
    end
  end
end

class Evaluation
  attr_accessor :type, :value, :score, :state, :reason

  def initialize(type:, value:, score:, state:, reason:)
    @type = type
    @value = value
    @score = score
    @state = state
    @reason = reason
  end

  def to_s
    "#{@type}, #{@value}, #{@score}, #{@state}, #{@reason}"
  end
end