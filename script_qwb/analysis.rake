#计算利润率
#
a =  [63780.34, 3863.26, 110785.31, 79408.5, 83180.1, 138293.0, 174685.62, 17196.13]


b = [1145.0, 1674.22, 12524.5, 30519.0, 50502.0, 14702.66, 76424.8, 63499.0, 23035.71, 7464.7, 48183.29, 79431.99]


c = b + a


# 计算利润率变化
def growth_rate(data)
  x = []
  (0..(data.count - 1)).each do |n|
    if n - 1 >= 0
      x << (data[n] == 0 ? 0 : (data[n].to_f - data[n-1].to_f) / data[n].to_f * 100).round(2)
    else
      x << 0
    end
  end

  out1 = x[0..11]
  out2 = x[12..24]
  return [out1, out2]
end




Booking.where(:paid_at => Time.parse("2017-07-01")..Time.parse("2017-08-01"), :sell_name => "刘燕", :status.ne => "退单完成")
