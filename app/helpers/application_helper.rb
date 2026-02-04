module ApplicationHelper
  def human_review_date(value)
    return nil if value.nil? || value.to_s.strip.empty?

    time =
      if value.is_a?(Time)
        value
      else
        Time.zone ? Time.zone.parse(value.to_s) : Time.parse(value.to_s)
      end

    return nil unless time

    days = %w[Domingo Lunes Martes Miércoles Jueves Viernes Sábado]
    months = %w[enero febrero marzo abril mayo junio julio agosto septiembre octubre noviembre diciembre]

    "#{days[time.wday]}, #{time.day} de #{months[time.month - 1]} de #{time.year}"
  rescue ArgumentError, TypeError
    nil
  end
end
