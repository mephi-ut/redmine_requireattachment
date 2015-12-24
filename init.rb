require 'redmine'

require 'requireattachment/patches/issues_controller'
require 'requireattachment/patches/issue'
require 'requireattachment/hooks/view_issues_edit_notes_bottom'

Redmine::Plugin.register :redmine_requireattachment do
  name 'Require attachment to close'
  author 'Dmitry Yu Okunev'
  description "Plugin adds role-based permission to control who can close issues without any attachment. Yes, it's very specific use case."
  version '0.1'
  project_module :requireattachment do
    permission :close_without_attachment, :projects => :close_without_attachment
  end
end

