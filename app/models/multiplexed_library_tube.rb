require_dependency 'tube/purpose'

class MultiplexedLibraryTube < Tube
  include ModelExtensions::MultiplexedLibraryTube
  include Api::MultiplexedLibraryTubeIO::Extensions
  include Transfer::Associations

  self.library_prep = true
  self.sequenceable = true

  has_many :order_roles, ->() { distinct }, through: :requests_as_target

  # Transfer requests into a tube are direct requests where the tube is the target.
  def transfer_requests
    transfer_requests_as_target
  end

  # Returns the type of asset that can be considered appropriate for request types.
  def asset_type_for_request_types
    LibraryTube
  end

  def creation_requests
    direct = requests_as_target.where_is_a?(Request::LibraryCreation)
    return direct unless direct.empty?

    parents.includes(:creation_request).map(&:creation_request)
  end

  def team
    creation_requests.first&.product_line
  end

  def library_source_plates
    purpose.library_source_plates(self)
  end

  def role
    order_roles.first.try(:role)
  end

  def self.stock_asset_type
    StockMultiplexedLibraryTube
  end

  def self.stock_asset_purpose
    Tube::Purpose.stock_mx_tube
  end

  extend Asset::Stock::CanCreateStockAsset
end
