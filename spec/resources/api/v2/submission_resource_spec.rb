# frozen_string_literal: true

require 'rails_helper'
require './app/resources/api/v2/submission_resource'

RSpec.describe Api::V2::SubmissionResource, type: :resource do
  subject { described_class.new(resource_model, {}) }

  let(:resource_model) { create :submission }

  # Test attributes
  it 'works', :aggregate_failures do
    expect(subject).to have_attribute :uuid
    expect(subject).to have_attribute :name
    expect(subject).to have_attribute :used_tags
    expect(subject).to have_attribute :state
    expect(subject).to have_attribute :created_at
    expect(subject).to have_attribute :updated_at
    expect(subject).not_to have_updatable_field(:id)
    expect(subject).not_to have_updatable_field(:uuid)
    expect(subject).not_to have_updatable_field(:state)
    expect(subject).not_to have_updatable_field(:created_at)
    expect(subject).not_to have_updatable_field(:updated_at)
    expect(subject).not_to have_updatable_field :used_tags
  end

  # Updatable fields
  # eg. it { is_expected.to have_updatable_field(:state) }

  # Filters
  # eg. it { is_expected.to filter(:order_type) }

  # Associations
  # eg. it { is_expected.to have_many(:samples).with_class_name('Sample') }

  # Custom method tests
  # Add tests for any custom methods you've added.
end
