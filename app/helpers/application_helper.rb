module ApplicationHelper
    def bootstrap_alert_class(type)
      case type.to_sym
      when :notice, :success then 'success'
      when :alert, :error then 'danger'
      else type.to_s
      end
    end
    
    
    def status_badge_class(status)
      case status.to_sym
      when :draft then 'secondary'
      when :submitted then 'info'
      when :in_progress then 'primary'
      when :delivered then 'success'
      when :cancelled then 'danger'
      else 'secondary'
      end
    end
  
    def active_class(link_path)
      current_page?(link_path) ? 'active' : ''
    end
  
    def nav_link_to(text, path, options = {})
      link_to(text, path, options.merge(class: "nav-link #{active_class(path)}"))
    end

  end