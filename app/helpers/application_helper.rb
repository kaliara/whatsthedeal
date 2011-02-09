# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def link_away(name, options = {}, html_options = nil)
    link_to(name, { :return_uri => url_for(:only_path => true) }.update(options.symbolize_keys), html_options)
  end
  
  def redirect_away(*params)
    session[:return_uri] = request.request_uri
    redirect_to(*params)
  end

  # promotions
  def has_cents?(price)
    (price - price.to_i.to_f).abs > 0
  end
  
  # reminders
  def reminder_exists?(reminder_email, promotion_id)
    !reminder_email.blank? and Reminder.exists?(:email => reminder_email, :promotion_id  => promotion_id)
  end

  # simple cms method
  def render_content(name, rotation_category=0)
    content = rotation_category.to_i > 0 ? name + rotation_category.to_s : name
    Content.find_by_name(content).blank? ? "" : Content.find_by_name(content).value
  end
  
  def content_exists?(name)
    Content.find_by_name(name) and !Content.find_by_name(name).value.blank?
  end
  
  def content_rotation_exists?(rotation_category)
    !Content.find_by_rotation_category(Content::ROTATION_CATEGORIES[rotation_category]).nil?
  end
  
  def display_error_messages(errors)
    unless errors.blank?
      content_for :errors do
        "<div class='flash'>#{errors}</div>"
      end
    end
  end
  
  def distance_of_time_in_words_to_now(from_time, to_time = Time.now, include_seconds = false, options = {})
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_minutes = (((to_time - from_time).abs)/60).round
  
    I18n.with_options :locale => options[:locale], :scope => 'datetime.distance_in_words''datetime.distance_in_words' do |locale|
      case distance_in_minutes
        when 0..119      then locale.t :x_minutes, :count => distance_in_minutes
        when 120..2790   then locale.t :x_hours,   :count => (distance_in_minutes.to_f / 60.0).round
        when 2791..43199 then locale.t :x_days,    :count => (distance_in_minutes.to_f / 1440.0).round
        else
          "Tons of time"
      end
    end
  end

end