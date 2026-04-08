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

  def review_number_font_size(review)
    text_length = review.review.to_s.squish.length
    image_bonus = Array(review.images).count * 180
    effective_length = [text_length + image_bonus, 1800].min

    min_size = 1100.0
    max_size = 3200.0
    scaled_size = min_size + (effective_length / 1800.0) * (max_size - min_size)

    "#{scaled_size.round}%"
  end
end
