info = File.read("/tmp/city.json");nil


json_city = JSON.parse(info);nil
send = [["id", "城市", "国家"]]
json_city["bizCs"].each do |n|
  send << [n["cid"], n["cNm"], n["ctNm"]]
end;nil
File.open('/tmp/ctrip_city.csv', 'w+') {|f| f.write(send)}





# 将csv 转化为hash

ds = CSV.read('data/ctrip_city.csv')

res = []
ds.each do |n|
  res << {
    "city" => n[1],
    "id" => n[0],
    "country" => n[2],
  }
end

