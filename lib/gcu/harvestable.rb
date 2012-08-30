# Module giving functionality to add oai harvesting data to an object

module Gcu::Harvestable
  extend ActiveSupport::Concern

	def harvesting_set_membership
		self.relationships(:is_member_of_collection)
	end

  def harvesting_set
    ids = harvesting_set_membership
    return unless ids.present?
    (ids & HarvestingSet.harvesting_set_pids).first
  end

	# Associate the given harvesting set with the object, removing old associations first.
  # @param [Array] sets to set associations with. Should be URIs.
	def apply_harvesting_set_membership(sets)
		#We delete previous set memberships and move to new set
    old_sets = harvesting_set_membership.dup
    old_sets.each { |s| self.remove_relationship(:is_member_of_collection, s) }
    sets.delete_if { |s| s == ""}.each { |s| self.add_relationship :is_member_of_collection, s }
	end

	#Add OAI Item id to RELS-EXT eg.
	#<oai:itemID>oai:hull.ac.uk:hull:4649</oai:itemID>
	def add_oai_item_id
		#literal specifies that it should be in the form of...<oai:itemID>...</oai:itemID>
 		self.add_relationship :oai_item_id, "oai:gcu.ac.uk:" + self.pid, :literal => true
	end

end
