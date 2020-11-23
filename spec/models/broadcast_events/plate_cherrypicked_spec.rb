require 'rails_helper'

RSpec.describe BroadcastEvent::PlateCherrypicked, type: :model, broadcast_event: true do
  def subject_record(subject_type, role_type, friendly_name, uuid)
    {
      "role_type": role_type,
      "subject_type": subject_type,
      "friendly_name": friendly_name,
      "uuid": uuid
    }
  end
  
  let(:uuids) { 6.times.map{ SecureRandom.uuid } }
  let(:destination_plate) { create :plate }
  let(:plate1) { 
    subject_record('plate', BroadcastEvent::PlateCherrypicked::SOURCE_PLATES_ROLE_TYPE, '000001', uuids[0]) 
  }
  let(:plate2) { 
    subject_record('plate', BroadcastEvent::PlateCherrypicked::SOURCE_PLATES_ROLE_TYPE, '000002', uuids[1]) 
  }
  let(:sample1) { 
    subject_record('sample', BroadcastEvent::PlateCherrypicked::SAMPLE_ROLE_TYPE, 'ASDF001-000001_A01-AP-Positive', uuids[2]) 
  }
  let(:sample2) { 
    subject_record('sample', BroadcastEvent::PlateCherrypicked::SAMPLE_ROLE_TYPE, 'ASDF001-000001_B01-AP-Negative', uuids[3]) 
  }
  let(:robot) { 
    subject_record('robot', BroadcastEvent::PlateCherrypicked::ROBOT_ROLE_TYPE, 'RB00001', uuids[4]) 
  }
  let(:plate3) {
    subject_record('plate', BroadcastEvent::PlateCherrypicked::DESTINATION_PLATE_ROLE_TYPE, '000003', uuids[5]) 
  }
  
  it 'is not directly instantiated' do
    expect(described_class.new).not_to be_valid
  end

  it 'cannot be created without robot' do
    props = {subjects: [plate1, plate2, sample1, sample2]}
    expect(described_class.new(seed: destination_plate, properties: props)).not_to be_valid
  end

  it 'can be created without destination plate' do
    props = {subjects: [plate1, plate2, sample1, sample2, robot]}
    instance = described_class.new(seed: destination_plate, properties: props)
    expect(instance).to be_valid
    expect(instance.subjects.size).to eq(6)
    expect(instance.subjects.any?{|s| 
      s.role_type == BroadcastEvent::PlateCherrypicked::DESTINATION_PLATE_ROLE_TYPE
    }).to be_truthy
  end

  it 'can be created with destination plate' do
    props = {subjects: [plate1, plate2, sample1, sample2, robot, plate3]}
    instance = described_class.new(seed: destination_plate, properties: props)
    expect(instance.subjects.size).to eq(6)
    expect(instance.subjects.any?{|s| 
      s.role_type == BroadcastEvent::PlateCherrypicked::DESTINATION_PLATE_ROLE_TYPE
    }).to be_truthy
  end
  
  it 'cannot be created without source plates' do
    props = {subjects: [sample1, sample2, robot]}
    expect(described_class.new(seed: destination_plate, properties: props)).not_to be_valid
  end

  it 'cannot be created without samples' do
    props = {subjects: [plate1, plate2, robot]}
    expect(described_class.new(seed: destination_plate, properties: props)).not_to be_valid
  end

  context 'with the right contents in properties and seed' do
    let(:props) {  { subjects: [plate1, plate2, sample1, sample2, robot]  } }
    let(:instance) { described_class.new(seed: destination_plate, properties: props) }

    it 'can be created when all required subjects are defined' do
      expect(instance).to be_valid
    end

    it 'can be persisted' do
      expect(instance.save).to be_truthy
    end

    context 'with a created instance' do
      before do
        instance.save
      end
      
      context '#to_json' do
        it 'can generate a json object' do          
          expect(instance.to_json).to include_json({
            event: {
              event_type: 'lh_beckman_cp_destination_created'
            }
          })
        end

        it 'includes all required subjects in the message' do
          event_info = JSON.parse(instance.to_json)
          expect(event_info['event'].has_key?('subjects')).to be_truthy
          expect(event_info['event']['subjects'].size).to eq(6)
        end
      end

      context '#default_destination_plate_subject' do
        it 'can generate a default destination plate subject' do
          expect(instance.default_destination_plate_subject).to include({
            uuid: destination_plate.uuid
          })
        end
      end
    end

  end
end