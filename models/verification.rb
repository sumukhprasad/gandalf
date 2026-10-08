require "sequel"

class Verification < Sequel::Model
	many_to_one :assignment

	one_to_many :sources,
			  class: :VerificationSource,
			  key: :verification_id

	one_to_many :issues,
			  class: :VerificationIssue,
			  key: :verification_id

	VERDICTS = %w[
		supported
		contradicted
		inconclusive
	].freeze

	CONFIDENCES = %w[
		high
		medium
		low
	].freeze

	def validate
		super

		errors.add(:verdict, "is invalid") unless VERDICTS.include?(verdict)
		errors.add(:confidence, "is invalid") unless CONFIDENCES.include?(confidence)

		errors.add(:interpreted_claim, "is required") if interpreted_claim.to_s.strip.empty?
		errors.add(:explanation, "is required") if explanation.to_s.strip.empty?
	end
end