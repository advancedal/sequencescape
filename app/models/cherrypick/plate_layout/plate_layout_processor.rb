module Cherrypick
  module PlateLayout
    class PlateLayoutProcessor
      include ActiveModel::Model

      attr_accessor :size, :shape
      attr_accessor :control_plate, :partial_plate, :template_plate
      attr_accessor :requests

      validates_presence_of :batch, :size, :shape, :requests
      validate :all_plates_valid

      def plates
        @plates ||= total_plates.times.map do |num_plate|
          PlateLayoutRenderer.new(
            shape: shape,
            size: size,
            requests: requests_for_plate[num_plate], 
            requests_positions: allocated_requests_positions(num_plate),
            control_requests: control_requests_for_plate(num_plate),
            control_positions: control_positions(num_plate),
            template_positions: template_positions(num_plate),
            partial_plate_positions: partial_plate_positions(num_plate)
          )
        end
      end

      def batch
        requests.first.batch
      end

      def control_requests_for_plate(num_plate)
        return [] unless control_plate
        return @control_requests_for_plate if @control_requests_for_plate
        @control_requests_for_plate = []

        @control_requests_for_plate = total_plates.times.map do 
          control_wells.map do |control_well|
            find_or_create_control_request(control_well)
          end
        end
        @control_requests_for_plate[num_plate]
      end

      def find_or_create_control_request(control_well)
        return create_control_request(control_well) unless _remaining_control_requests
        pos = _remaining_control_requests.find_index do |request|
          request.asset == control_well
        end
        _remaining_control_requests.pop(pos)
      end

      # Creates control requests for the control assets provided and adds them to the batch
      def create_control_request(control_well)
        CherrypickRequest.create(
          asset: control_well,
          target_asset: Well.new,
          submission: requests.first.submission,
          request_type: requests.first.request_type,
          request_purpose: 'standard'
        ).tap do |control_requests|
          batch.requests << control_request
        end
      end

      def control_wells
        return [] unless @control_plate
        @control_wells ||= @control_plate.wells.joins(aliquots: :sample).where(samples: { control: true})
      end

      def requests_for_plate
        return @requests_for_plate if @requests_for_plate
        @requests_for_plate = []

        remaining_requests = requests.to_a
        num_plate = 0
        while (remaining_requests.length != 0) do
          @requests_for_plate.push(remaining_requests.shift(available_requests_positions(num_plate).length))
          num_plate = num_plate + 1
          errors.add(:base, 'Max limit of cherrypicking is 99 plates') if num_plate > 99
        end

        return @requests_for_plate
      end

      def total_plates
        return requests_for_plate.length
      end

      def all_positions
        @all_positions ||= (0...size).to_a
      end

      def available_positions(num_plate)
        all_positions - partial_plate_positions(num_plate) - template_positions(num_plate)
      end

      def available_requests_positions(num_plate)
        available_positions(num_plate) - control_positions(num_plate)
      end

      def allocated_requests_positions(num_plate)
        available_requests_positions(num_plate).shift(requests_for_plate[num_plate].length)
      end

      def partial_plate_positions(num_plate)
        return [] unless partial_plate
        return [] unless num_plate == 0
        @partial_plate.wells.where(aliquots: nil).map(&:map_id)
      end

      def template_positions(num_plate)
        return [] unless template_plate
        @template_plate.wells.map(&:map_id)
      end

      #
      # Returns a list with the destination positions for the control wells distributed by
      # using batch_id and num_plate as position generators.
      def control_positions(num_plate)
        return [] unless control_plate

        unique_number = batch.id
        free_wells = available_positions(num_plate)

        # Generation of the choice
        positions = []
        binding.pry
        while positions.length < control_wells.length
          current_size = free_wells.length
          position = free_wells.slice!(unique_number % current_size)
          position_for_plate = (position + num_plate) % free_wells.length
          positions.push(position_for_plate)
          unique_number /= current_size
        end

        positions
      end

      protected
      def all_plates_valid
        return if plates.all?(&:valid?)

        plates.each_with_index do |plate, pos|
          plate.errors.messages.each do |k, v|
            errors.add("plate_#{pos}_#{k}", v)
          end
        end
      end

      private
      def _remaining_control_requests
        @_remaining_control_requests ||= @requests.select{|r| r.asset.aliquots.first.sample.control }
      end
    end
  end
end

