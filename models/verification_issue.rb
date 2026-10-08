require "sequel"

class VerificationIssue < Sequel::Model
	many_to_one :verification

	ISSUES = %w[
		vague_claim
		insufficient_context
		conflicting_sources
		insufficient_evidence
		source_unavailable
		source_inaccessible
		translation_issue
		other
	].freeze

	def validate
		super

		errors.add(:issue, "is invalid") unless ISSUES.include?(issue)
	end
end