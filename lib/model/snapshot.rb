require File.join(File.dirname(__FILE__), 'base')

class Vixen::Model::Snapshot < Vixen::Model::Base
  def display_name
    return @display_name unless @display_name.nil?
    @display_name = get_string_property VixPropertyId[:snapshot_displayname]
  end

  def description
    return @description unless @description.nil?
    @description = get_string_property VixPropertyId[:snapshot_description]
  end

  def to_s
    display_name
  end
end
