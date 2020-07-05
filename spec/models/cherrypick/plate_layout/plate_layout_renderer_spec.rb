require 'spec_helper'

RSpec.describe Cherrypick::PlateLayout::PlateLayoutRenderer do
  let(:asset_shape) { create :asset_shape }
  let(:size) { 14 }
  let(:requests) { 7.times.map{|i| i } }
  let(:control_requests) { 2.times.map{|i| i } }
  let(:all_positions) { size.times.map{|i| i}}
  let(:control_positions) { [2,4] }
  let(:template_positions) { [12,13] }
  let(:partial_plate_positions) { [0,3,5]}
  let(:requests_positions) { all_positions - control_positions - template_positions - partial_plate_positions }
  let(:params) { {
      size: 96,
      shape: asset_shape,
      requests: requests,
      requests_positions: requests_positions,
    }
  }
  context '#initialize' do
    it 'can instantiate a plate layout' do
      expect{Cherrypick::PlateLayout::PlateLayoutRenderer.new}.not_to raise_error
    end
  end

  context '#valid?' do
    it 'is valid with the right params' do
      expect(Cherrypick::PlateLayout::PlateLayoutRenderer.new(params)).to be_valid
    end

    it 'is not valid without requests' do
      expect(Cherrypick::PlateLayout::PlateLayoutRenderer.new(params.except(:requests))).to be_invalid
    end
    it 'is not valid without size' do      
      expect(Cherrypick::PlateLayout::PlateLayoutRenderer.new(params.except(:size))).to be_invalid
    end
    it 'is not valid without requests_positions' do
      expect(Cherrypick::PlateLayout::PlateLayoutRenderer.new(params.except(:requests_positions))).to be_invalid
    end

    it 'is not valid if size is smaller than positions provided' do
      expect(Cherrypick::PlateLayout::PlateLayoutRenderer.new(params.merge(size: 3))).to be_invalid
    end

    it 'is not valid if shape and size are not compatible' do
      expect(Cherrypick::PlateLayout::PlateLayoutRenderer.new(params.merge(size: 3))).to be_invalid
    end

    context 'when defining controls' do
      it 'is not valid if missing control params needed' do
        expect(Cherrypick::PlateLayout::PlateLayoutRenderer.new(params.merge({
          control_requests: control_requests,
        }))).to be_invalid
        expect(Cherrypick::PlateLayout::PlateLayoutRenderer.new(params.merge({
          control_positions: control_positions,
        }))).to be_invalid
      end
      it 'is valid if contains all control params' do
        expect(Cherrypick::PlateLayout::PlateLayoutRenderer.new(params.merge({
          control_requests: control_requests,
          control_positions: control_positions,
        }))).to be_valid
      end
      it 'is not valid if there are requests without a position declared' do
        control_positions.pop
        expect(Cherrypick::PlateLayout::PlateLayoutRenderer.new(params.merge({
          control_requests: control_requests,
          control_positions: control_positions,
        }))).to be_invalid
      end
      it 'is not valid if plate does not have enough wells for controls and requests' do
        expect(Cherrypick::PlateLayout::PlateLayoutRenderer.new(params.merge({
          size: 2,
          control_requests: control_requests,
          control_positions: control_positions,
        }))).to be_invalid
      end
      it 'is not valid if controls positions clash with any other position' do      
        expect(Cherrypick::PlateLayout::PlateLayoutRenderer.new(params.merge({
          control_requests: control_requests,
          control_positions: control_positions.push(requests_positions[0])
        }))).to be_invalid
      end
    end

    context 'when defining template params' do      
      it 'is valid with the right template params' do
        expect(Cherrypick::PlateLayout::PlateLayoutRenderer.new(params.merge({
          template_positions: template_positions
        }))).to be_valid        
      end

      it 'is not valid if template positions clash with any other position' do      
        expect(Cherrypick::PlateLayout::PlateLayoutRenderer.new(params.merge({
          template_positions: template_positions.push(requests_positions[0])
        }))).to be_invalid
      end
    end

    context 'when defining partial_plate params' do

      it 'is valid with the right template params' do
        expect(Cherrypick::PlateLayout::PlateLayoutRenderer.new(params.merge({
          partial_plate_positions: partial_plate_positions
        }))).to be_valid        
      end

      it 'is not valid if partial plate positions clash with any other position' do      
        expect(Cherrypick::PlateLayout::PlateLayoutRenderer.new(params.merge({
          partial_plate_positions: partial_plate_positions.push(requests_positions[0])
        }))).to be_invalid
      end
    end

  end

  context 'with render methods' do
    def dummy_request(id, barcode, map_description)
      double(:request, id: id, asset: double('well', 
        plate: double('plate', human_barcode: barcode),
        map_description: map_description))
    end

    let(:plate) { create :plate }
    let(:params) { {
      size: 6,
      shape: asset_shape,
      requests: [dummy_request(1,'DN1', 'A01')],
      requests_positions: [0],
      control_requests: [dummy_request(2,'DN2', 'A01')],
      control_positions: [1],
      template_positions: [2],
      partial_plate_positions: [3]
    } }
    let(:renderer) { Cherrypick::PlateLayout::PlateLayoutRenderer.new(params) }

    context '#render' do
      it 'is valid' do
        expect(renderer).to be_valid
      end
      it 'renders a request' do
        request = params[:requests].first
        expect(renderer.render(0)).to eq([request.id, request.asset.plate.human_barcode, request.asset.map_description])
      end
      it 'renders a control request' do
        request = params[:control_requests].first
        expect(renderer.render(1)).to eq([request.id, request.asset.plate.human_barcode, request.asset.map_description])
      end
      it 'renders a template space' do
        expect(renderer.render(2)).to eq(Cherrypick::PlateLayout::PlateLayoutRenderer::TEMPLATE_EMPTY_WELL)
      end
      it 'renders a partial plate space' do
        expect(renderer.render(3)).to eq(Cherrypick::PlateLayout::PlateLayoutRenderer::EMPTY_WELL)
      end
    end

    context '#by_column' do
      it 'renders the layout' do
        expect(renderer.by_column).to eq([[2, "DN2", "A01"], [0, "Empty", ""], [0, "---", ""], [0, "Empty", ""], [0, "Empty", ""], [0, "Empty", ""]])
      end
    end

    context '#by_row' do
      it 'renders the layout' do
        expect(renderer.by_row).to eq([[1, "DN1", "A01"], [2, "DN2", "A01"], [0, "---", ""], [0, "Empty", ""], [0, "Empty", ""], [0, "Empty", ""]])
      end
    end

    context '#by_interleaced_column' do
      it 'renders the layout' do
        expect(renderer.by_interleaced_column).to eq([[0, "Empty", ""], [2, "DN2", "A01"], [0, "---", ""], [0, "Empty", ""], [0, "Empty", ""], [0, "Empty", ""]])
      end
    end
  end
end