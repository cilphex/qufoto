module Update3Helper
  
  def page_url(page)
    if page[:path]
      page[:path]
    elsif page[:controller] && page[:action]
      url_for(:controller => page[:controller], :action => page[:action])
    elsif page[:action]
      url_for(:action => page[:action])
    else
      "/"
    end
  end
  
end
