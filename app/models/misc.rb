class Misc < ActiveRecord::Base
  def self.value(key, default=nil)
    return Misc.exists?(:key => key) ? Misc.find_by_key(key).value : default
  end
end