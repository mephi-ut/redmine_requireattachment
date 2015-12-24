module Requireattachment
	class Hooks < Redmine::Hook::ViewListener
		render_on :view_issues_edit_notes_bottom, :partial => 'js/update_issue_edit_form_on_attachments_change'
	end
end
