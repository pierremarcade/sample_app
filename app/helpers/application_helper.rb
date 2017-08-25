module ApplicationHelper
  # Retourner un titre basé sur la page.
  def title
    default_title = "Simple App du Tutoriel Ruby on Rails"
    if @title.nil?
      default_title
    else
      "#{default_title} | #{@title}"
    end
  end
  # Retourner paramètres url
  def params_link(options = nil)
    if options.nil?
      return :locale => (I18n.locale != :fr ? I18n.locale : nil)
    else
      return options , :locale => (I18n.locale != :fr ? I18n.locale : nil)
    end
  end
  # Retourne l'url courante
  def current_path(params = {})
    if params[:locale].nil?
      url_for(request.query_parameters.except(:locale))
    else
      url_for(request.params.merge(params))
    end
  end
end
