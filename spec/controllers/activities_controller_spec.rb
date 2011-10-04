require 'spec_helper'

describe ActivitiesController do
  
  before(:each) do
    @request.env["HTTP_ACCEPT"] = "application/json"
    @category = Fabricate(:category)
    @location = Fabricate(:location)
  end
  
  it "creates an activity and return it as JSON" do
    post :create, {:activity => {:name => "Learn to ride a car", :location_id => @location.id, :category_id => @category.id} }
    Activity.first.name.should == "Learn to ride a car"
    ActiveSupport::JSON.decode(response.body) == ActiveSupport::JSON.decode(Activity.first.to_json)
  end
  
  it "updates an activity and returns it as JSON" do
    activity = Fabricate(:activity, :name => "Learn to slow dance")
    Activity.first.name.should == "Learn to slow dance"
    put :update, {:activity => {:name => "Learn to dance fast"}, :id => activity.id }
    Activity.first.name.should == "Learn to dance fast"
    ActiveSupport::JSON.decode(response.body) == ActiveSupport::JSON.decode(Activity.first.to_json)
  end
  
  it "should find and activity based on id" do
    activity = activity = Fabricate(:activity, :name => "Learn to ride a horse")
    get :show, {:id => activity.id }
    ActiveSupport::JSON.decode(response.body) == ActiveSupport::JSON.decode(Activity.first.to_json)
  end
  
  it "should find all activities" do
    activity1 = Fabricate(:activity, :name => "Learn to slow dance")
    activity2 = Fabricate(:activity, :name => "Learn to slow dance fast")
    get :index
    ActiveSupport::JSON.decode(response.body) == ActiveSupport::JSON.decode([activity1, activity2].to_json)
  end
  
  it "should destroy an activity" do
    activity = Fabricate(:activity, :name => "Learn to slow dance in the jungle")
    Activity.all.size.should == 1
    delete :destroy, {:id => activity.id }
    Activity.all.size.should == 0
  end
  
end
