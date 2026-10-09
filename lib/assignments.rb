module Assignments
	WINDOW = 30 * 24 * 60 * 60

	def self.eligible_verifiers(claim)
		claim.group
			.memberships_dataset
			.eager(:user)
			.where(is_verifier: true)
			.exclude(user_id: claim.user_id)
			.all
			.map(&:user)
	end

	def self.assignment_counts(candidates, since:)
		counts = Hash.new(0)
		ids = candidates.map(&:id)

		ids.each do |id|
			counts[id] = 0
		end

		Assignment
			.where(verifier_id: ids)
			.where { assigned_at >= since }
			.exclude(status: "rescinded")
			.group(:verifier_id)
			.select(
				:verifier_id,
				Sequel.function(:count, :id).as(:count)
			)
			.all
			.each do |row|
				counts[row[:verifier_id]] = row[:count]
			end

		counts
	end

	def self.recommend(claim)
		candidates = eligible_verifiers(claim)

		return nil if candidates.empty?

		counts = assignment_counts(
			candidates,
			since: Time.now - WINDOW
		)

		lowest = counts.values.min

		candidates
			.select { |user| counts[user.id] == lowest }
			.sample
	end
	
	def self.auto_assign(claim, actor:)
		verifier = recommend(claim)
		return nil unless verifier

		assign_to(
			claim,
			verifier,
			actor: actor,
			reason: "automatic assignment"
		)
	end

	def self.assign_to(claim, verifier, actor:, reason: nil)
		raise ArgumentError, "Verifier does not exist" unless verifier
		raise ArgumentError, "Actor does not exist" unless actor

		unless eligible_verifiers(claim).any? { |user| user.id == verifier.id }
			raise ArgumentError, "Verifier is not eligible for this claim"
		end

		raise "Claim already assigned!" if claim.active_assignment

		DB.transaction do
			assignment = Assignment.create(
				claim_id: claim.id,
				verifier_id: verifier.id,
				assigned_at: Time.now,
				created_by: actor.id,
				status: "active",
				reason: reason
			)
			
		     Notifications.enqueue(
		     	recipient: verifier.email,
		     	kind: "assignment_created",
		     	payload: {
		     		"assignment_id" => assignment.id,
		     		"reason" => reason,
		     		"claim_id" => claim.id
		     	}
		     )

			claim.update(status: "assigned")

			assignment
		end
	end

	def self.rescind(assignment, actor:, reason:)
		raise ArgumentError, "Assignment is not active" unless assignment.status == "active"

		DB.transaction do
			assignment.update(
				status: "rescinded",
				rescinded_at: Time.now,
				reason: reason
			)

			assignment.claim.update(status: "pending")
		end
	end

	def self.auto_assign?
		ENV.fetch("AUTO_ASSIGN", "0") == "1"
	end
end