module WorkPackageDisplay
  def display_id
    "#{(kind.is_standard) ? "" : "#{kind.name}"} ##{id}"
  end
end
