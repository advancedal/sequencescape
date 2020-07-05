require 'spec_helper'

RSpec.describe Cherrypick::PlateLayout::PlateLayoutProcessor do
  def dummy_request(id, barcode, map_description, batch)
    double(:request, id: id, 
      batch: batch,
      asset: double('well', 
      plate: double('plate', human_barcode: barcode),
      map_description: map_description))
  end

  let(:batch) { create :batch }
  let(:asset_shape) { create :asset_shape }
  let(:size) { 14 }
  let!(:requests) { 7.times.map{|i| dummy_request(i, "DN1", "A0#{i}", batch) } }
  let(:params) { {
      size: 96,
      shape: asset_shape,
      requests: requests
    }
  }

  def create_control_plate(num_wells)
    control = create(:plate)
    control.wells[0..num_wells].each{|w| w.update_attributes(control_plate: true, control_type: 'positive')}
    control
  end

  context '#initialize' do
    it 'can create an instance' do
      expect(Cherrypick::PlateLayout::PlateLayoutProcessor.new(params)).not_to be_nil
    end
  end

  context '#valid?' do
    it 'is valid with the right params' do
      expect(Cherrypick::PlateLayout::PlateLayoutProcessor.new(params)).to be_valid
    end
    it 'is not valid if plate does not have at least one allocatable position' do
      control = create_control_plate(2)
      expect(Cherrypick::PlateLayout::PlateLayoutProcessor.new(params.merge(control_plate: control))).to be_invalid
    end
    it 'is not valid if plate does not have space for all needed positions' do      
    end
  end

  context '#control_requests_for_plate' do
    it 'return empty list when no control plate' do
      
    end
    it 'creates as many requests as wells in control plate' do
    end
    it 'reuses previously created requests' do
    end
    it 'ignores wells that are not controls' do
    end
  end

  context '#find_or_create_control_request' do
    it 'creates a control request if none present for asset' do
      
    end
    it 'returns the already existing request if there is one for asset' do
      
    end
  end

  context '#plates' do
    it 'generates a PlateLayoutRenderer for each plate' do
    end
  end
  
  context '#control_wells' do
    it 'returns the control wells for the control plate' do
      control = create_control_plate(4)
      expect(control.wells.count).to eq(4)
    end
  end

  context '#requests_for_plate' do
    it 'splits requests in groups for each plate' do
    
    end
  end

  context '#available_positions' do
    it 'returns all positions without template and partial plate' do
    end
  end

  context '#available_requests_positions' do
    it 'returns all available positions without controls' do
    end
  end

  context '#allocated_requests_positions' do
    it 'returns all positions needed from the available for each group of requests of plate' do
      
    end
  end

  context '#partial_plate_positions' do
    it 'returns the positions for the wells for the partial plate' do
      
    end
  end

  context '#template_plate_positions' do
    it 'returns the positions for the wells for the template plate' do
      
    end
  end

  describe '#control_positions' do
    let(:instance) { described_class.new(params) }
    it 'calculates the positions for the control wells' do
      requests.first.batch.id=0
      # Test batch id 0, plate 0 to 4, 5 free wells, 2 control wells
      params.merge!(control_plate: create_control_plate(2))
      expect(instance.control_positions(0)).to eq([0, 1])
      expect(instance.control_positions(1)).to eq([1, 2])
      expect(instance.control_positions(2)).to eq([2, 3])
      expect(instance.control_positions(3)).to eq([3, 4])
      expect(instance.control_positions(4)).to eq([4, 0])
    end

    it 'fails when you try to put more controls than free wells' do
      requests.first.batch.id=0
      # Test batch id 0, plate 0, 2 free wells, 3 control wells, so they dont fit
      params.merge(control_plate: create_control_plate(6))
      expect do
        instance.control_positions(0, 0, 2, 3)
      end.to raise_error(ZeroDivisionError)
    end

    it 'does not clash with consecutive batches (1)' do
      requests.first.batch.id=12345
      params.merge(control_plate: create_control_plate(3), size: 100)
      # Test batch id 12345, plate 0 to 2, 100 free wells, 3 control wells
      expect(instance.control_positions(0)).to eq([45, 24, 1])
      expect(instance.control_positions(1)).to eq([46, 25, 2])
      expect(instance.control_positions(2)).to eq([47, 26, 3])
    end

    it 'does not clash with consecutive batches (2)' do
      requests.first.batch.id=12346
      params.merge(control_plate: create_control_plate(3), size: 100)
      # Test batch id 12346, plate 0 to 2, 100 free wells, 3 control wells
      expect(instance.control_positions(0)).to eq([46, 24, 1])
      expect(instance.control_positions(1)).to eq([47, 25, 2])
      expect(instance.control_positions(2)).to eq([48, 26, 3])
    end

    it 'does not clash with consecutive batches (3)' do
      requests.first.batch.id=12445
      params.merge(control_plate: create_control_plate(3), size: 100)

      # Test batch id 12445, plate 0 to 2, 100 free wells, 3 control wells
      expect(instance.control_positions(0)).to eq([45, 25, 1])
      expect(instance.control_positions(1)).to eq([46, 26, 2])
      expect(instance.control_positions(2)).to eq([47, 27, 3])
    end

    it 'does not clash with consecutive batches (4)' do
      requests.first.batch.id=12545
      params.merge(control_plate: create_control_plate(3), size: 100)

      # Test batch id 12545, plate 0 to 2, 100 free wells, 3 control wells
      expect(instance.control_positions(0)).to eq([45, 26, 1])
      expect(instance.control_positions(1)).to eq([46, 27, 2])
      expect(instance.control_positions(2)).to eq([47, 28, 3])
    end

    it 'also works with big batch id and small wells' do
      requests.first.batch.id=12545
      params.merge(control_plate: create_control_plate(1), size: 100)
      # Test batch id 12545, plate 0 to 4, 3 free wells, 1 control wells
      expect(instance.control_positions(0)).to eq([0])
      expect(instance.control_positions(1)).to eq([1])
      expect(instance.control_positions(2)).to eq([2])
      expect(instance.control_positions(3)).to eq([0])
      expect(instance.control_positions(4)).to eq([1])
    end
  end

end