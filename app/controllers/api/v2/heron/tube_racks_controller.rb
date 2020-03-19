# frozen_string_literal: true

module Api
  module V2
    module Heron
      # Endpoint to create TubeRacks inside Sequencescape for Heron
      class TubeRacksController < ApplicationController
        before_action :login_required, except: [:create]
        skip_before_action :verify_authenticity_token

        def create
          rack_factory = ::Heron::Factories::TubeRack.new(params_for_tube_rack)
          if rack_factory.save
            render json: {}, status: :created
          else
            render json: { errors: rack_factory.errors.full_messages }, status: :unprocessable_entity
          end
        end

        private

        def create_tube_rack_response(params)
          params[:data].each_with_object(json: [], status: :created) do |param_job, response|
            job = ::Aker::Factories::Job.new(param_job[:attributes].permit!)
            return { json: job.errors, status: :unprocessable_entity } unless job.valid?

            response[:json].push(job.create)
          end
        end

        def params_for_tube_rack
          params.require(:data).require(:attributes).require(:tube_rack).permit(:barcode, tubes: %i[barcode supplier_sample_id location])
        end
      end
    end
  end
end
