module ApplicationHelper
  def my_current_path(params={})
    url_for(request.params.merge(params))
  end
end
