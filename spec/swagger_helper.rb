# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  config.openapi_root = Rails.root.join('swagger', 'v1').to_s

  config.openapi_specs = {
  'swagger.yaml' => {
    openapi: '3.0.1',
    info: {
      title: 'API V1',
      version: 'v1'
    },
    paths: {},
    servers: [
      {
        url: 'http://35.229.247.36:3000'
      }
    ]
  }
}

  config.openapi_format = :yaml
end
