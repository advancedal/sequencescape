# frozen_string_literal: true

namespace :auto_imported_samples do
  desc 'Send messages to the stock_resource table in MLWH for samples that were imported before the bug fix in GPL-557'
  task register_as_stock: :environment do
    # retrieve the relevant receptacles
    # Any imported by Lighthouse or Wrangler
    # Find these by any created from start of May
    # Add extra checks that sample_manifest is nil
    # And purpose is one of expected ones

    relevant_studies = ['Heron Project', 'Heron Project R & D', 'Project Kestrel']

    # should we include Heron Lysed Plate, Heron Lysed Tube Rack?
    # if a sample is in multiple of these, should we include multiple stock receptacles per sample?
    relevant_purpose_names = ['Stock Plate', 'LHR Stock', 'TR Stock 96',
                              'Heron Lysed Plate', 'Heron Lysed Tube Rack']
    relevant_purpose_ids = Purpose.where(name: relevant_purpose_names).map(&:id).join(',')

    labware_samples = Labware.joins(:samples).where(
      """
      labware.created_at > '2020-05-01 00:00:00' AND
      labware.sti_type IN ('Plate', 'TubeRack') AND
      labware.plate_purpose_id IN (#{relevant_purpose_ids}) AND
      samples.sample_manifest_id IS NULL
      """
    ) # 78,507 in training 2020-07-07

    labware = labware_samples.uniq # 890 in training 2020-07-07

    receptacles = labware.map(&:receptacles).flatten
    # 85,440 in training 2020-07-07
    # includes the empty ones - TODO: filter these out

    # call register_stock! on each of them
    receptacles.each do |r|
      r.register_stock!
    end
  end
end


# SQL equivalent of labware query - numbers agree - 78,507
# SELECT *
# FROM labware
# JOIN receptacles ON labware.id = receptacles.labware_id
# JOIN aliquots ON receptacles.id = aliquots.receptacle_id
# JOIN samples ON aliquots.sample_id = samples.id
# WHERE labware.created_at > '2020-05-01 00:00:00'
# AND labware.sti_type IN ('Plate', 'TubeRack')
# AND labware.plate_purpose_id IN (2, 344, 348, 373, 374)
# AND samples.sample_manifest_id IS NULL