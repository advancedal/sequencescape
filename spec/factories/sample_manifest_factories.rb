# frozen_string_literal: true

FactoryBot.define do
  factory :sample_manifest do
    study
    supplier
    asset_type { 'plate' }
    count { 1 }

    factory :sample_manifest_with_samples do
      samples { create_list(:sample_with_well, 5) }
    end

    factory :tube_sample_manifest do
      asset_type { '1dtube' }

      factory :tube_sample_manifest_with_tubes_and_manifest_assets do
        transient do
          tube_count { 1 }
          tube_factory { :empty_sample_tube }
        end

        labware { create_list tube_factory, tube_count }

        after(:build) do |sample_manifest|
          sample_manifest.labware.each do |tube|
            create(:sample_manifest_asset,
                   sanger_sample_id: generate(:sanger_sample_id),
                   asset: tube,
                   sample_manifest: sample_manifest)
          end
          sample_manifest.barcodes = sample_manifest.labware.map(&:human_barcode)
        end
      end

      factory :tube_sample_manifest_with_samples do
        samples { create_list(:sample_tube, 5).map(&:samples).flatten }

        factory :tube_sample_manifest_with_sample_tubes do
          count { 5 }

          after(:build) do |sample_manifest|
            sample_manifest.barcodes = sample_manifest.labware.map(&:human_barcode)
          end
        end
      end
    end

    factory :pending_plate_sample_manifest do
      transient do
        num_plates { 2 }
        num_samples_per_plate { 2 }
        plates { create_list :plate, num_plates, well_factory: :empty_well, well_count: num_samples_per_plate }
      end

      # set sanger_sample_id on samples
      after(:build) do |sample_manifest, evaluator|
        evaluator.plates.flat_map(&:wells).each do |well|
          create(:sample_manifest_asset, asset: well, sample_manifest: sample_manifest)
        end
      end
    end
  end

  factory :supplier do
    name { 'Test supplier' }
  end
end
