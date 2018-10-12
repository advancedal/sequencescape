class Search::FindRobotByBarcode < Search
  def scope(criteria)
    Robot.with_barcode(criteria['barcode'])
  end
end
