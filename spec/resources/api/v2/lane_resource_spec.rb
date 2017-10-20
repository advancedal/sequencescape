require 'rails_helper'
require './app/resources/api/v2/lane_resource'

RSpec.describe Api::V2::LaneResource, type: :resource do
  let(:resource_model) { create :lane }
  subject { described_class.new(resource_model, {}) }

  # Test attributes
  it { is_expected.to have_attribute :uuid }

  # Read only attributes (almost certainly id, uuid)
  it { is_expected.to_not have_updatable_field(:id) }
  it { is_expected.to_not have_updatable_field(:uuid) }

  # Updatable fields
  # eg. it { is_expected.to have_updatable_field(:state) }

  # Filters
  # eg. it { is_expected.to filter(:order_type) }

  # Associations
  # eg. it { is_expected.to have_many(:samples).with_class_name('Sample') }

  # Custom method tests
  # Add tests for any custom methods you've added.
end
