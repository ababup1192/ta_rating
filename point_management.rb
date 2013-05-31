class PointManagement
  def initialize(mailing_list)
    @mailing_list = mailing_list
    self.reset_points
  end
  def reset_points
    zero_points = []
    zero_points.fill(0,0,@mailing_list.size)
    arr = [@mailing_list,zero_points].transpose
    @point_hash = Hash[*arr.flatten]
  end
  def set_point(key,point)
    @point_hash[key] = point
  end
  attr_accessor :mailing_list,:point_hash
end

