# frozen_string_literal: true

Evaluation = Struct.new(:type, :value, :score, :state, :reason) do
  def unconfirmed? = state == 'unconfirmed'
  def favorable? = state == 'favorable'
  def unfavorable? = state == 'unfavorable'
  def unable_to_reach_api? = reason == 'unable_to_reach_api'
  def ongoing_database_update? = reason == 'ongoing_database_update'
end
