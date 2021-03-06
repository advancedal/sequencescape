class MultiplexedCherrypickingTask < Task
  include Tasks::PlatePurposeBehavior

  belongs_to :purpose

  def partial
    'assign_wells_to_wells'
  end

  def included_for_do_task
    [{ requests: [:request_metadata, { asset: :aliquots }, :target_asset] }, :pipeline]
  end

  def included_for_render_task
    [{ requests: { asset: [:samples, { plate: :barcodes }, :map] } }]
  end

  def render_task(workflow, params)
    super
    workflow.plate_purpose_options = plate_purpose_options
  end

  def plate_purpose_options(_ = nil)
    PlatePurpose.cherrypickable_as_target.order(name: :asc).pluck(:name, :size, :id)
  end

  def do_task(workflow, params)
    destination_plate = target_plate(params[:existing_plate_barcode], params[:plate_purpose_id])
    workflow.do_assign_requests_to_multiplexed_wells_task(self, params, destination_plate) &&
      workflow.do_assign_pick_volume_task(self, params)
  end

  def target_plate(barcode, plate_purpose_id)
    return Plate.with_barcode(barcode).first if barcode.present?

    PlatePurpose.find(plate_purpose_id).create!
  end
end
