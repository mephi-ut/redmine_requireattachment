require 'redmine'

module Requireattachment
	module IssuePatch
		def self.included(base)
			base.extend(ClassMethods)
			base.send(:include, InstanceMethods)
			base.class_eval do
				unloadable

				alias_method_chain :new_statuses_allowed_to, :requireattachment
			end
		end

		module ClassMethods
		end

		module InstanceMethods
			def can_close_check_attachment(user = User.current, force_has_attachments=false)
				# Don't do anything if the module is disabled
				return true unless project.module_enabled?("requireattachment")

				# If already closed then there's nothing to do, just run the old method
				return true if status.is_closed

				# If current user is the author of the issue then he CAN close the issue
				return true if user.id == author_id

				# Checking if the user has right to close the issue without attachments.
				return true if user.allowed_to?(:close_without_attachment, @project)

				# If attachments are already uploaded then don't do anything.
				return true if attachments.count != 0 or force_has_attachments

				# Seems cannot
				return false
			end

			def new_statuses_allowed_to_with_requireattachment(user=User.current, include_default=false, force_has_attachments=false)
				@statuses_allowed_to = new_statuses_allowed_to_without_requireattachment(user, include_default)
				return @statuses_allowed_to if can_close_check_attachment(user, force_has_attachments)
				return @statuses_allowed_to.reject {|s| s.is_closed}
			end
		end
	end
end

Issue.send(:include, Requireattachment::IssuePatch)
