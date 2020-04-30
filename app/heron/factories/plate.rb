# frozen_string_literal: true

module Heron
  module Factories
    # Factory class to create Heron tube racks
    class Plate
      include ActiveModel::Model
      include Concerns::ForeignBarcodes

      attr_accessor :plate

      validates_presence_of :plate_purpose
      validate :validate_wells_content

      def initialize(params)
        @params = params
      end

      def barcode
        @params[:barcode]
      end

      def wells_content
        @wells_content ||= ::Heron::Factories::WellsContent.new(@params[:wells_content])
      end

      def validate_wells_content
        return if wells_content.valid?

        wells_content.sample_factories.each do |factory|
          errors.add(:sample, factory.errors)
        end
      end

      def plate_purpose
        @plate_purpose ||= @params[:plate_purpose] || PlatePurpose.with_uuid(@params[:plate_purpose_uuid]).first
      end

      def save
        return false unless valid?

        ActiveRecord::Base.transaction do
          @plate = plate_purpose.create!(params_for_plate_creation)

          Barcode.create!(asset: @plate, barcode: barcode, format: barcode_format)

          wells_content.add_aliquots_into_plate(plate)
        end
        true
      end

      def params_for_plate_creation
        @params.except(:plate_purpose, :plate_purpose_uuid, :wells_content, :barcode)
      end
    end
  end
end
