res = Supplier.where(:country_name.ne => nil).map(&:country_name).uniq



out = [["司导国家", "服务区域"]]
res.each do |n|

  city = []
  x = Supplier.where(:country_name => n)

  x.each{|m| city.concat(m.services_locations)}

  out << [n, city.uniq]
end


Emailer.send_custom_file(['wudi@haihuilai.com'],  "可服务国家地区信息", XlsGen.gen(out), "可服务国家信息.xls" ).deliver
