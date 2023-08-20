# frozen_string_literal: true

class Evaluation
  attr_accessor :type, :value, :score, :state, :reason

  def initialize(type:, value:, score:, state:, reason:)
    @type = type
    @value = value
    @score = score
    @state = state
    @reason = reason
  end

  def unconfirmed? = state == 'unconfirmed'
  def favorable? = state == 'favorable'
  def unfavorable? = state == 'unfavorable'
  def unable_to_reach_api? = reason == 'unable_to_reach_api'
  def ongoing_database_update? = reason == 'ongoing_database_update'

  def to_s
    "#{@type}, #{@value}, #{@score}, #{@state}, #{@reason}"
  end
end
