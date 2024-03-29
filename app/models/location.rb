# -*- encoding : utf-8 -*-
class Location
  include Mongoid::Document
  include NafLocations
  field :name, :type => String
  field :longitude, :type => Float
  field :latitude, :type => Float

  validates_presence_of :longitude, :latitude, :name, :region

  belongs_to :region
  belongs_to :location

  has_many :locations

  scope :by_region, all(sort: [[ :region_id, :asc ]])
  scope :by_name, all(sort: [[ :name, :asc ]])

  def to_marker
    {
      :name => name,
      :lat => latitude,
      :lng => longitude
    }
  end

end

