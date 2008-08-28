class AbSplitTestHit < ActiveRecord::Base
  validates_presence_of :action, :campaign_name
end