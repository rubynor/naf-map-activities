# -*- encoding : utf-8 -*-
class Region
  include Mongoid::Document
  field :name, :type => String

  validates_presence_of  :name

  has_many :locations
end
