module Requireattachment
	module IssuesControllerPatch
		def self.included(base)
			base.send(:include, InstanceMethods)

			base.class_eval do
				unloadable

				alias_method_chain :update,      :requireattachment
				alias_method_chain :update_form, :requireattachment
			end
		end

		module InstanceMethods
			def can_close_check_attachment
				# Model's can_close_check_attachment checks
				return true if @issue.can_close_check_attachment(User.current)
				# Additional checks:

				# If attachments are already provided then just run the old method.
				return true if not params[:attachments].nil?

				# If all the above failed then seems the user cannot close the issue
				return false
			end

			def update_with_requireattachment
				# If can close without attachment then close
				return update_without_requireattachment if can_close_check_attachment

				# Checking if it is issues closing event or it's a forbidded issue status via the plugins settings. Otherwise just run the old method
				@oldstatus = @issue.status
				@newstatus = IssueStatus.find(params[:issue][:status_id])
				return update_without_requireattachment unless (@oldstatus.is_closed == false and @newstatus.is_closed == true) or not Setting.plugin_redmine_requireattachment["requireattachment_forbidstatus_#{@newstatus.id.to_s}"].nil?

				# If not then it's time to disappoint the user and tell him to make an attachment
				#@issue.errors.add :attachments, :issue_requires_attachment
				#respond_to do |format|
				#	format.html { render :action => 'edit' }
				#	format.api  { render_validation_errors(@issue) }
				#end 
				render_403
			end

			def update_form_with_requireattachment
				update_form_without_requireattachment
				return unless @project.module_enabled?("requireattachment")
				return if params[:attachments_count].nil? or params[:attachments_count] == '0'

				puts "params[:attachments_count] == #{params[:attachments_count]}"

				@allowed_statuses = @issue.new_statuses_allowed_to_with_requireattachment(User.current, false, true)
				#puts "@allowed_statuses == [#{@issue.attachments.count}] #{@allowed_statuses.to_yaml}"
			end
		end
	end
end

IssuesController.send(:include, Requireattachment::IssuesControllerPatch)
