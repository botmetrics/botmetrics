module ApplicationHelper
  def menu_class(link)
    if (controller.controller_name == 'dashboards' ||
       (controller.controller_name == 'bots' && controller.action_name == 'show')) &&
       link == 'metrics'
      'active'
    elsif controller.controller_name == 'bots' && controller.action_name == 'edit' && link == 'bot-settings'
      'active'
    elsif (controller.controller_name == 'notifications' || controller.controller_name == 'new_notification') && link == 'notifications'
      'active'
    elsif controller.controller_name == 'users' && controller.action_name == 'show' && link == 'my-profile'
      'active'
    elsif controller.controller_name == 'insights' && link == 'analyze'
      'active'
    elsif controller.controller_name == 'retention' && link == 'retention'
      'active'
    end
  end

  def body_classes(classes=nil)
    ary = [Rails.application.class.to_s.split("::").first.downcase]
    ary << controller.controller_name
    ary << controller.action_name

    unless classes.nil?
      method = classes.is_a?(Array) ? :concat : :<<
      ary.send method, classes
    end

    ary.join(' ').strip
  end

  def show_bots_dropdown?
    controller.controller_name == 'bot_instances' ||
    (controller.controller_name == 'bots' && controller.action_name == 'show')
  end
end
