def current_user
  User.find session[:current_user_id] rescue nil
end
ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard.main") }

  content title: proc{ I18n.t("active_admin.dashboard.main") } do
    div "Version: #{$VERSION}", class: 'version'
  end
end
