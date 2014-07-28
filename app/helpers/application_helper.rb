module ApplicationHelper

  def tsshow(datetime)
    "#{datetime.in_time_zone('Zulu')} (#{datetime.in_time_zone('Berlin').strftime('%T.%L')})"
  end
end
