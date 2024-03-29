# -*- encoding : utf-8 -*-

#
# All specs for search on activities (sunspot is turned of in activities controller specs - here it is not)
#
require 'spec_helper'

def json_decoded(input)
  ActiveSupport::JSON.decode(input)
end

def search_results_for(response)
  json_decoded(response.body)["activities"]
end

describe Admin::ActivitiesController do
 it "finds activities based on words in summary (this is real search)", :solr => true do
    get :search, :text => "dance", :format => :json
    search_results_for(response).should == json_decoded([].to_json)
    activity = Fabricate(:activity, :summary => "Learn to slow dance in the jungle")
    Sunspot.commit
    get :search, :text => "dance", :format => :json
    search_results_for(response).should == json_decoded([activity].to_json)
  end
  
  it "finds activities based on words in description", :solr => true do
    activity = Fabricate(:activity, :summary => "Learn to slow dance in the jungle", :description => "great stuff")
    Sunspot.commit
    get :search, :text => "stuff", :format => :json
    search_results_for(response).should == json_decoded([activity].to_json)
  end
  
  it "finds activities based on an array of categories", :solr => true do
    category1 = Fabricate(:category)
    category2 = Fabricate(:category)
    category3 = Fabricate(:category)
    activity1 = Fabricate(:activity, :summary => "Learn to slow dance in the jungle1",:category_id => category1.id)
    activity2 = Fabricate(:activity, :summary => "Learn to slow dance in the jungle2", :category_id => category2.id)
    activity3 = Fabricate(:activity, :summary => "Learn to slow dance in the jungle3", :category_id => category3.id)
    Sunspot.commit
    
    get :search, :text => "jungle1", :category_ids => ["bogus"], :format => :json
    search_results_for(response).should == json_decoded([].to_json)
    
    get :search, :text => "jungle1", :category_ids => ["#{category1.id}"], :format => :json
    search_results_for(response).should == json_decoded([activity1].to_json)
    
    get :search, :text => "", :category_ids => ["#{category1.id}"], :format => :json
    search_results_for(response).should == json_decoded([activity1].to_json)
    
    get :search, :text => "", :category_ids => ["#{category1.id}", "#{category2.id}"], :format => :json
    search_results_for(response).should == json_decoded([activity1, activity2].to_json)
    
    get :search, :text => "jungle2", :category_ids => ["#{category1.id}", "#{category2.id}"], :format => :json
    search_results_for(response).should == json_decoded([activity2].to_json)
  end
  
  it "finds activities based on target audience", :solr => true do
    activity1 = Fabricate(:activity, :summary => "Learn to slow dance in the jungle1",:age_from => 0, :age_to => 14)
    activity2 = Fabricate(:activity, :summary => "Learn to slow dance in the jungle2", :age_from => 25, :age_to => 40)
    activity3 = Fabricate(:activity, :summary => "Learn to slow dance in the jungle3", :age_from => 66, :age_to => 100)
    Sunspot.commit
    get :search, :text => "no match", :targets => [], :format => :json
    search_results_for(response).should == json_decoded([].to_json)
    get :search, :text => "", :targets => ["Barn 0 - 14"], :format => :json
    search_results_for(response).should == json_decoded([activity1].to_json)
    get :search, :text => "", :targets => ["Barn 0 - 14", "Voksen 25 - 65"], :format => :json
    search_results_for(response).should == json_decoded([activity1, activity2].to_json)
    get :search, :text => "", :targets => ["Eldre 65 +"], :format => :json
    search_results_for(response).should == json_decoded([activity3].to_json)
  end
  
  it "finds activities based on target audience, with range over more intevals", :solr => true do
    activity = Fabricate(:activity, :summary => "Learn to slow dance in the jungle3", :age_from => 15, :age_to => 70)
    Sunspot.commit
    get :search, :text => "no match", :targets => [], :format => :json
    search_results_for(response).should == json_decoded([].to_json)
    get :search, :text => "", :targets => ["Barn 0 - 14"], :format => :json
    search_results_for(response).should == json_decoded([].to_json)
    get :search, :text => "", :targets => ["Ung 15 - 24"], :format => :json
    search_results_for(response).should == json_decoded([activity].to_json)
  end
  
  it "finds activities based on tags", :solr => true do
    activity1 = Fabricate(:activity, :summary => "Learn to slow dance in the jungle1",:tags=> "tag1")
    activity2 = Fabricate(:activity, :summary => "Learn to slow dance in the jungle2", :tags => "tag1, tag2")
    Sunspot.commit
    get :search, :text => "tag1", :format => :json
    search_results_for(response).should == json_decoded([activity1, activity2].to_json)
    get :search, :text => "tag2", :format => :json
    search_results_for(response).should == json_decoded([activity2].to_json)
  end
  
  it "finds activities based on veichles", :solr => true do
    activity1 = Fabricate(:activity, :summary => "Learn to slow dance in the jungle1",:vehicle => "MC")
    activity2 = Fabricate(:activity, :summary => "Learn to slow dance in the jungle2", :vehicle => "sykkel")
    Sunspot.commit
    get :search, :text => "mc", :format => :json
    search_results_for(response).should == json_decoded([activity1].to_json)
    get :search, :text => "sykkel", :format => :json
    search_results_for(response).should == json_decoded([activity2].to_json)
  end
  
  it "finds only activites starting after start date", :solr => true do
    activity1 = Fabricate(:activity, :summary => "Learn stuff", :dtstart => DateTime.new(2011, 4, 5), :dtend => DateTime.new(2011, 4, 8))
    activity2 = Fabricate(:activity, :summary => "Learn stuff", :dtstart => DateTime.new(2011, 6, 5), :dtend => DateTime.new(2011, 6, 8))
    Sunspot.commit
    get :search, :text => "", :dtstart => "1.4.2011", :format => :json
    search_results_for(response).should == json_decoded([activity1, activity2].to_json)
    get :search, :text => "", :dtstart => "6.4.2011", :format => :json
    search_results_for(response).should == json_decoded([activity2].to_json)
  end
  
  it "finds only activites starting before end date", :solr => true do
    activity1 = Fabricate(:activity, :summary => "Learn stuff", :dtstart => DateTime.new(2011, 4, 5), :dtend => DateTime.new(2011, 4, 8))
    activity2 = Fabricate(:activity, :summary => "Learn stuff", :dtstart => DateTime.new(2011, 4, 10), :dtend => DateTime.new(2011, 6, 8))
    Sunspot.commit
    get :search, :text => "", :dtend => "10.4.2011", :format => :json
    search_results_for(response).should == json_decoded([activity1, activity2].to_json)
    get :search, :text => "", :dtend => "9.4.2011", :format => :json
    search_results_for(response).should == json_decoded([activity1].to_json)
  end
  
  it "should order the search with closest in time first", :solr => true do
    activity1 = Fabricate(:activity, :summary => "Learn stuff", :dtstart => DateTime.new(2011, 4, 5))
    activity2 = Fabricate(:activity, :summary => "Learn stuff", :dtstart => DateTime.new(2011, 2, 5))
    Sunspot.commit
    get :search, :text => "", :format => :json
    search_results_for(response).should == json_decoded([activity2, activity1].to_json)
  end
  
  it "should find activities based on name of location", :solr => true do
    location1 = Fabricate(:location, :name => "Oslo")
    location2 = Fabricate(:location, :name => "Trondheim")
    activity1 = Fabricate(:activity, :summary => "Learn stuff", :location_id => location1.id.to_s)
    activity2 = Fabricate(:activity, :summary => "Learn stuff", :location_id => location2.id.to_s)
    Sunspot.commit
    get :search, :text => "Oslo", :format => :json
    search_results_for(response).should == json_decoded([activity1].to_json)
    get :search, :text => "Trondheim", :format => :json
    search_results_for(response).should == json_decoded([activity2].to_json)
  end
  
  it "should find activities based on region", :solr => true do
    
    region1 = Fabricate(:region, :name => "Nord")
    region2 = Fabricate(:region, :name => "Sør")
    
    location1 = Fabricate(:location, :region => region1)
    location2 = Fabricate(:location, :region => region2)
    location3 = Fabricate(:location, :region => region2)
    
    activity1 = Fabricate(:activity, :summary => "Learn stuff", :location_id => location1.id)
    activity2 = Fabricate(:activity, :summary => "Learn stuff", :location_id => location2.id)
    activity3 = Fabricate(:activity, :summary => "Learn stuff", :location_id => location2.id)
    
    Sunspot.commit
    get :search, :text => "", :region_id => region1.id.to_s, :format => :json
    search_results_for(response).should == json_decoded([activity1].to_json)
    get :search, :text => "", :region_id => region2.id.to_s, :format => :json
    search_results_for(response).should == json_decoded([activity2, activity3].to_json)
  end
  
  it "finds only active activities", :solr => true do
    activity1 = Fabricate(:activity, :summary => "Learn stuff", :active => true)
    activity2 = Fabricate(:activity, :summary => "Learn stuff", :active => false)
    Sunspot.commit
    get :search, :text => "", :format => :json
    search_results_for(response).should == json_decoded([activity1].to_json)
  end
  
  it "includes inactive activities if admin flag is true", :solr => true do
    activity1 = Fabricate(:activity, :summary => "Learn stuff", :active => true)
    activity2 = Fabricate(:activity, :summary => "Learn stuff", :active => false)
    Sunspot.commit
    get :search, :text => "", :admin => true, :format => :json
    search_results_for(response).should == json_decoded([activity1, activity2].to_json)
  end
  
end
