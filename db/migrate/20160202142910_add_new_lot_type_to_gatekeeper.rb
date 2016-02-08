class AddNewLotTypeToGatekeeper < ActiveRecord::Migration
  def change
    ActiveRecord::Base.transaction do
      pstp = QcablePlatePurpose.create!(:name=>'Pre Stamped Tag Plate', :target_type=>'Plate', :default_state=>'pending')
      LotType.create!(:name=>'Pre Stamped Tags', :template_class=>'TagLayoutTemplate', :target_purpose=>pstp)
      Purpose::Relationship.create!(:parent=>Purpose.find_by_name('Pre Stamped Tag Plate'),:child=>Purpose.find_by_name('Tag PCR'),:transfer_request_type=>RequestType.transfer)
    end
  end
end