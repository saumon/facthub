class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  layout :layout_by_resource

  def after_sign_in_path_for(resource)
    resource.is_a?(Admin) ? admin_facts_path : super
  end

  private

  def layout_by_resource
    devise_controller? ? "devise" : "application"
  end
end
