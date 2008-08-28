module AbSplitTestSystem
  def self.included(base_class)
    base_class.extend ClassMethods
  end
  
  private 
  def assign_names
    @action_name = (params['action'] || 'index')
    if self.class.respond_to?(:ab_split_tests) && self.class.ab_split_tests.keys.include?(@action_name)
      @action_name = get_ab_name(self.class.ab_split_tests[@action_name])
    end
  end
  
  def get_ab_name(ab_hash)
    campaign_name = ab_hash[:campaign_name]
    filtered_action = ab_hash[:filtered_action]
    treatment_actions = ab_hash[:treatment_actions]
    
    last_hit = AbSplitTestHit.find_by_campaign_name(campaign_name, :order => 'created_at DESC')
    if last_hit
      last_action_index = treatment_actions.index(last_hit.action)
      new_action_index = (last_action_index == treatment_actions.size - 1) ? 0 : last_action_index.to_i + 1
      new_action = treatment_actions[new_action_index]
    else
      new_action = filtered_action
    end

    AbSplitTestHit.create(:campaign_name => campaign_name, :action => new_action)

    @ab_split_test_treatment = campaign_name + "/" + new_action #for google analytics
    new_action
  end
  
  module ClassMethods    
    #dipping into Rails internals, probably bad idea, but it works!
    #would be better to figure out how to achieve this through routing.
    
    def ab_split_test(campaign_name, filtered_action, *treatment_actions)
      self.module_eval <<-"end;"
        cattr_accessor :ab_split_tests
      end;
      
      treatment_actions.unshift(filtered_action)
      self.ab_split_tests ||= {}
      self.ab_split_tests[filtered_action] = {:campaign_name => campaign_name, :filtered_action => filtered_action, :treatment_actions => treatment_actions}    
    end
  end
  
  # Uses proc which you have to call from within the default action. Is it more efficient to use this technique?
  # def ab_split_test
  #   #necessary to use a proc because it can make the calling method (action) return when necessary
  #   Proc.new do |campaign_name, current_action, *treatment_actions|
  #     treatment_actions.unshift(current_action)
  #     last_hit = AbSplitTestHit.find_by_campaign_name(campaign_name, :order => 'created_at DESC')
  #     if last_hit
  #       last_action_index = treatment_actions.index(last_hit.action)
  #       new_action_index = (last_action_index == treatment_actions.size - 1) ? 0 : last_action_index + 1
  #       new_action = treatment_actions[new_action_index]
  #     else
  #       new_action = current_action
  #     end
  #     
  #     AbSplitTestHit.create(:campaign_name => campaign_name, :action => new_action)
  #     
  #     @ab_split_test_treatment = "#{campaign_name}-#{new_action}"
  #     if new_action != current_action
  #       return self.send(new_action)
  #     end
  #   end
  # end
end