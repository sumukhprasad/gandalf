require "sequel"

class VerificationSource < Sequel::Model
	many_to_one :verification

	SOURCE_TYPES = %w[
		book
		webpage
		document
		textbook
		lecture_material
		other
	].freeze

	RELATIONS = %w[
		supports
		contradicts
		context
	].freeze

	def validate
		super

		errors.add(:title, "is required") if title.to_s.strip.empty?

		unless SOURCE_TYPES.include?(source_type)
			errors.add(:source_type, "is invalid")
		end

		unless RELATIONS.include?(relation)
			errors.add(:relation, "is invalid")
		end
	end
end