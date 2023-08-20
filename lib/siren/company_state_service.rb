# frozen_string_literal: true

require 'json'
require 'net/http'

class CompanyStateService
  ACTIVE_STATE = 'Actif'

  def self.active?(value)
    uri = URI(
      'https://public.opendatasoft.com/api/records/1.0/search/?dataset=economicref-france-sirene-v3' \
      "&q=#{value}&sort=datederniertraitementetablissement" \
      '&refine.etablissementsiege=oui'
    )
    response = Net::HTTP.get(uri)
    parsed_response = JSON.parse(response)
    state = parsed_response['records'].first['fields']['etatadministratifetablissement']
    state == ACTIVE_STATE
  end
end
