
ids = Consumer.where(:company_name => /途风/).map(&:id)

a = Booking.where(:paid_at.ne => nil,:status.ne => "退单完成", :consumer_id.in =>  [338, 339, 3862, 3899] )

res = a.map_reduce(
  %Q{
    function(){

       var day = new Date(this.paid_at* 1 + 1000 * 3600 * 8);
       var key_string = day.getFullYear() + "-" + (((day.getMonth() + 1) < 10 ? '0' : '') + (day.getMonth() + 1));

       var pirce = this.total_rmb;
       var name = this.consumer_company;
       emit({date: key_string, consumer: name }, {price: this.total_rmb, count: 1});
    }
  },
  %Q{
    function(key,items){
       var r = {price: 0, count: 0};
       items.forEach(function(item){
         r.price += item.price;
         r.count += item.count;
       });
       return r;
    }
  }).out(:inline => true).to_a


send = [["时间", "公司名称", "支付金额(不含退单)", "订单量"]]

res.each do |n|
  send << [n["_id"]["date"], n['_id']["consumer"], n["value"]["price"], n["value"]["count"]]
end

Emailer.send_custom_file(['jinxue@haihuilai.com','zhouhong@haihuilai.com' ,'chenyilin@haihuilai.com'], "成都途风国际旅行社有限公司历史账单信息", XlsGen.gen(send), "成都途风国际旅行社有限公司历史账单信息.xls").deliver_now




$mongo_qspider['day_ctrip_casper.js'].find(:created_at => {:$gte => Time.parse(Time.now.to_date.to_s),:$lt => Time.now}).map{|n| n["data"]["city_cn"]}
"易途8"
城市 车型 日期 价格
send = [["", "", ""]]




time_span = (Time.now.tomorrow.to_date..Time.parse("2017-06-15")).map{|n| n.to_s}
result = {}
car_info = []
time_span.each do |span|
  $mongo_qspider['day_ctrip_casper.js'].find(:created_at => {:$gte => Time.parse(Time.now.to_date.to_s),:$lt => Time.now}).each do |n|

    cars = n['data']['data'].map{|m| m["name"]}
    base = n['data']['data']
    car_info.concat(cars)
    city_cn = n['data']["city_cn"]
    result[span] ||= {}
    result[span][city_cn] ||= {}
    cars.each do |m|
      info = base.select{|x| x["name"] == m }
      if info.present? 
        if info.first["datas"].select{|f| f["supply"] == "易途8"}.present?
          p  info.first["datas"].select{|f| f["supply"] == "易途8"}
          result[span][city_cn][m] = info.first["datas"].select{|f| f["supply"] == "易途8"}.first["sprice"] 
        else
          result[span][city_cn][m] = nil 
        end
      else
        result[span][city_cn][m] = nil
      end
    end
  end
end



city = ["爱丁堡", "伯明翰", "伦敦", "曼彻斯特", "尼斯", "马赛", "布拉格", "法兰克福", "杜赛尔多夫", "都灵", "雅典", "布鲁塞尔", "里斯本", "巴黎"]
out = [["时间", "国家"]]
out[0].concat(car_info.uniq)

cars = car_info.uniq

time_span.each do |t|
  city.each do |city|
    info = result[t][city]
    next unless info.present?
    p info
    inside = []
    inside = [t, city]
    p info
    cars.each do |car|
      p info[car]
      inside.push(info[car])
    end
    out << inside
  end
end



time_span.each do |t|
  car_info.uniq.each do |n|

    out << []


  end
end


"2016-10-3" => {
  "巴黎" => {
    "车型" => pirce
  }
}
Emailer.send_custom_file(['jinxue@haihuilai.com', 'chenyilin@haihuilai.com'], "携程易途8数据一日包车数据", XlsGen.gen(out), "携程易途8包车数据数据.xls").deliver_now
Emailer.send_custom_file(['jinxue@haihuilai.com','zhouhong@haihuilai.com' ,'chenyilin@haihuilai.com'], "成都途风国际旅行社有限公司历史账单信息", XlsGen.gen(send), "成都途风国际旅行社有限公司历史账单信息.xls").deliver_now




# 接团名义筛选 => 所有真是订单中， consumer_name 中不包含 company 信息的订单 
send = [["订单号", "接团名义", "采购商", "下单人", "op", "责任BD" ]]

Booking.real_order.each do |n|
  if n.consumer_name.include?(n.consumer_company) == false
    send << [n.booking_param, n.type , n.consumer_name, n.consumer_company, n.creater_name, n.op, n.sell_name]
  end
end
Emailer.send_custom_file(['wudi@haihuilai.com'], "接团名义与采购商公司名称不一致的订单信息", XlsGen.gen(send), "接团名义信息.xls").deliver_now






x = Booking.where(:paid_at.ne => nil,:type => /包车/,:status.ne => "退单完成", :memo.nin => [/门票/,/酒店/, /餐费/, /车票/, /超时费/]).count







a = Booking.real_order.where(:paid_at => Time.parse("2015-12-01")..Time.parse("2017-01-01")).where(:status.ne => "退单完成")
b = Booking.real_order.where(:paid_at => Time.parse("2017-01-01")..Time.now).where(:status.ne => "退单完成")




   all_booking_data = a.map_reduce(
      %Q{
        function(){
            var price = this.total_rmb;
            var name = this.consumer_company;


            emit( {name: name}, {price: price} )
        }
      },
        %Q{
        function(key, items){
            var r = {price: 0}
            items.forEach( function(item) {
              r.price += item.price;
            });
            return r;
        }
      }).out(:inline => true).to_a


   next_info = b.map_reduce(
      %Q{
        function(){
            var price = this.total_rmb;
            var name = this.consumer_company;


            emit( {name: name}, {price: price} )
        }
      },
        %Q{
        function(key, items){
            var r = {price: 0}
            items.forEach( function(item) {
              r.price += item.price;
            });
           return r;
        }
      }).out(:inline => true).to_a



first = all_booking_data.sort_by{|n| -n["value"]["price"]}[0,10].map{|n| [n["_id"]["name"], n["value"]["price"].to_f.round(2)]}
second = next_info.sort_by{|n| -n["value"]["price"]}[0,10].map{|n| [n["_id"]["name"], n["value"]["price"].to_f.round(2)]}


Emailer.send_custom_file(['wudi@haihuilai.com'], "销售额前十采购商统计", XlsGen.gen(first,second), "销售额前十采购商统计.xls").deliver_now



send = [["机场", "目的地", "类型", "供应商", "价格"]]
$mongo_qspider['air_ctrip_casper.js'].find().each do |n|
  data = n["data"]
  airport = data["airport_cn"]

  address = data["address_cn"]
  type = data["type_cn"]
  list = data["data"]
  list.each do |m|

    p m
    info = m["datas"]
    p info
    if info.present? 
      info.each do |x|
        supply = x["supply"]
        sprice = x["sprice"]
        p supply
        send << [airport, address, type, supply, sprice]
      end
    else
      p "jlasjdf"
      send << [airport, address, type, nil, nil]
    end

  end

end


## 采购商流水够10W


Booking.real_order.map_reduce



next_info = Booking.real_order.where(:paid_at => Time.parse("2016-10-01")..Time.parse("2017-09-01"), :status.ne => "退单完成" ).map_reduce(
  %Q{
        function(){
            var price = this.total_rmb;
            var name = this.consumer_company;


            emit( {name: name, sell_name: this.sell_name}, {price: price} )
        }
  },
    %Q{
        function(key, items){
            var r = {price: 0}
            items.forEach( function(item) {
              r.price += item.price;
            });
           return r;
        }
  }).out(:inline => true).to_a


out = [["销售" , "采购商", "最后支付时间", "金额"]]
next_info.select{|n| n["value"]["price"] >= 100000}.sort_by{|m| -m["value"]["price"]}.each do |n|
  last_paid = Booking.where(:consumer_company => n["_id"]["name"], :paid_at.ne => nil, :status.ne => "退单完成").last.try(:paid_at).to_date
  out << [n["_id"]["sell_name"], n["_id"]["name"], last_paid, n["value"]["price"].round(2)]
end

out2 = [["销售" , "采购商", "最后支付时间", "金额"]]

next_info.select{|n|  n["value"]["price"] >= 50000 && n["value"]["price"] <= 100000 }.sort_by{|m| -m["value"]["price"]}.each do |n|
  last_paid = Booking.where(:consumer_company => n["_id"]["name"], :paid_at.ne => nil, :status.ne => "退单完成").last.try(:paid_at).to_date
  out2 << [n["_id"]["sell_name"], n["_id"]["name"], last_paid, n["value"]["price"].round(2)]
end


out3 = [["销售" , "采购商", "最后支付时间", "金额"]]

next_info.select{|n|  n["value"]["price"] >= 0 && n["value"]["price"] <= 50000}.sort_by{|m| -m["value"]["price"]}.each do |n|
  p n
  last_paid = Booking.where(:consumer_company => n["_id"]["name"], :paid_at.ne => nil, :status.ne => "退单完成").last.try(:paid_at).to_date
  out3 << [n["_id"]["sell_name"], n["_id"]["name"], last_paid, n["value"]["price"].round(2)]
end

Emailer.send_custom_file(['jinxue@haihuilai.com','tongchang@haihuilai.com'], "201610月至今流水统计-区分销售", XlsGen.gen(out, out2, out3), "区分销售-三挡流水统计.xls").deliver_now


bds = Storage::Base::MG_AREA_BD

r = Booking.where(:paid_at => Time.parse("2016-10-01")..Time.parse("2016-10-01"), :status.ne => "退单完成").map_reduce(
  %Q{
        function(){
            var price = this.total_rmb;
            var name = this.sell_name;


            emit( name, {price: price} )
        }
  },
    %Q{
        function(key, items){
            var r = {price: 0}
            items.forEach( function(item) {
              r.price += item.price;
            });
           return r;
        }
  }).out(:inline => true).to_a

out = [["区域", "BD", "金额"]]
bds.each do |x, y|
  s_name = y[:name].first
  out << [x, s_name , r.select{|m| m["_id"] == s_name}.first["value"]["price"]]
end




Booking.where(:paid_at => Time.parse("2017-08-01")..Time.parse("2017-09-01"),:status.ne => '退单完成', :zone => /欧洲/,:sell_name.in => ["刘燕", "卢刚", "张海英"]).map(&:profit_company).reduce(:+)
Emailer.send_custom_file(['wangxuezheng@haihuilai.com','jasmine@haihuilai.com' ,'tongchang@haihuilai.com'], "首汽历史城市查询统计", XlsGen.gen(out), "首汽历史城市查询统计.xls").deliver_now




out = [["公司名称", "账号类型", "创建人", "总支付", "实际成交金额", "退款金额", "订单量", "实际成交量", "退款单量", 
        "历史登陆次数", 
        "多日包车金额", "多日包车单量",  
        "一日包车金额", "一日包车单量",
        "接机金额", "接机单量", "送机金额",
        "送机单量", "接站金额", "接站单量", 
        "送站金额", "送站单量",
        "精品线路金额", "精品路线单量", "半日包车金额", "半日包车单量"
]]


Consumer.where(:review_status => "审核通过").each do |n|
  name = n.company_name
  type = n.manager_id.nil? ? "主账号": "子账号"
  fullname = n.fullname
  consumer_id = n.id
  base_book = Booking.where(:consumer_id => consumer_id)

  sign_in_count = n.sign_in_count
  p n
  base_book_paid = base_book.where(:paid_at.ne => nil)
  if  base_book_paid.present? 

    first_res = []
    book_paid_count = base_book_paid.count 

    all_paid = base_book_paid.map(&:total_rmb).reduce(:+).to_f.round(2) 

    base_real_all_paid = base_book_paid.where(:status.ne => "退单完成")
    real_all_paid = base_real_all_paid.map(&:total_rmb).reduce(:+).to_f.round(2)

    real_all_count = base_real_all_paid.count

    base_drawback = base_book_paid.where(:status => "退单完成")

    drawback_price = base_drawback.map(&:total_rmb).reduce(:+).to_f.round(2)

    reduce_paid = base_book_paid.without_drawback.map_reduce(
      %Q{
           function(){
               var price = this.total_rmb;
               var type = this.type;


               emit( type, {price: price, count: 1} )
           }
      },
        %Q{
           function(key, items){
               var r = {price: 0, count: 0}
               items.forEach( function(item) {
                 r.price += item.price;
                 r.count += item.count;
               });
              return r;
           }
      }).out(:inline => true).to_a


    all_type =  ["多日包车", "一日包车", "接机", "送机", "接站", "送站", "精品线路", "半日包车"]

    data_type = []
    all_type.each do |n|
      r = reduce_paid.select{|m| m["_id"] == n}.first
      data_type << (r.present? ? r["value"]["price"].to_f : 0.to_f)
      data_type << (r.present? ? r["value"]["count"].to_i : 0)
    end

    
    p all_paid
    p real_all_paid
    first_res = [name, type, fullname, all_paid, real_all_paid,  drawback_price, book_paid_count, real_all_count, base_drawback.count, sign_in_count]
    out << first_res.concat(data_type)
  else
    out << [name, type, fullname  , nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,]

     
  end 



end


Emailer.send_custom_file(['wudi@haihuilai.com',], "采购商信息统计", XlsGen.gen(out), "采购商统计信息.xls").deliver_now





a = Booking.real_order.where(:paid_at => Time.parse("2016-10-01")..Time.parse("2017-01-01"),:status.ne => "退单完成" )

res = a.map_reduce(
  %Q{
    function(){

       var day = new Date(this.paid_at* 1 + 1000 * 3600 * 8);
       var key_string = day.getFullYear() + "-" + (((day.getMonth() + 1) < 10 ? '0' : '') + (day.getMonth() + 1));

       var pirce = this.total_rmb;
       var name = this.consumer_company;
       emit({date: key_string, consumer: name ,type: this.type}, {price: this.total_rmb, count: 1});
    }
  },
  %Q{
    function(key,items){
       var r = {price: 0, count: 0};
       items.forEach(function(item){
         r.price += item.price;
         r.count += item.count;
       });
       return r;
    }
  }).out(:inline => true).to_a

types = a.pluck(&:type)

span = (Time.parse("2017-07-01").to_date..Time.parse("2017-09-01").to_date).map{|n| n.strftime("%Y-%m")}.uniq
c = a.map{|n|n.consumer_company}.uniq

out = [[ "2016-10", "2016-11", "2016-12", "2017-01", "接机", "送机", "多日包车", "一日包车", "送站"]]


out = [["采购商", "最后登陆时间",
        "2016-10",
        "2016-10接机",
        "2016-10送机",
        "2016-10多日包车",
        "2016-10一日包车",
        "2016-10送站",
        "2016-11",
        "2016-11接机",
        "2016-11送机",
        "2016-11多日包车",
        "2016-11一日包车",
        "2016-11送站",
        "2016-12",
        "2016-12接机",
        "2016-12送机",
        "2016-12多日包车",
        "2016-12一日包车",
        "2016-12送站",
        "2017-01",
        "2017-01接机",
        "2017-01送机",
        "2017-01多日包车",
        "2017-01一日包车",
        "2017-01送站"
]]

w = []
span.each do |n|
  types.each do |m|
    w <<   "#{n}, #{n}#{m}"
  end
end

out.first.concat(w)
c.each do |con|

  tmp1 = [con, Consumer.where(:company_name => con, :last_sign_in_at.ne => nil).map(&:last_sign_in_at).last, ]
  span_out= []
  span.each do |d|
    p con
    p d

    base_data = res.select{|x| x["_id"]["consumer"] == con && x["_id"]["date"] == d}
    span_out << (base_data.present? ? base_data.map{|m| m["value"]["price"]}.reduce(:+).to_f.round(2) : 0)
    types_out = []
    types.each do |t|
      p t
      if base_data.present? 
        e = base_data.select{|m| m["_id"]["type"] == t}.first
        types_out << (e.present? ?  e["value"]["price"].to_f.round(2) : 0)
      else
        types_out << 0
      end
    end
    span_out.concat(types_out)
  end
  tmp1.concat(span_out)
  out << tmp1
end

Emailer.send_custom_file(['wudi@haihuilai.com'], "2016/11~12月采购商统计", XlsGen.gen(out), "2016/11~12月采购商统计.xls").deliver_now

a = Booking.real_order.where(:paid_at => Time.parse("2017-7-01")..Time.parse("2017-10-01"),:status.ne => "退单完成" )

res = a.map_reduce(
  %Q{
    function(){

       var day = new Date(this.paid_at* 1 + 1000 * 3600 * 8);
       var key_string = day.getFullYear() + "-" + (((day.getMonth() + 1) < 10 ? '0' : '') + (day.getMonth() + 1));

       var pirce = this.total_rmb;
       var name = this.consumer_company;
       emit({date: key_string, consumer: name}, {price: this.total_rmb, count: 1});
    }
  },
  %Q{
    function(key,items){
       var r = {price: 0, count: 0};
       items.forEach(function(item){
         r.price += item.price;
         r.count += item.count;
       });
       return r;
    }
  }).out(:inline => true).to_a

country_out = [["国家", "单量"]]
city_out = [["城市", "单量"]]


out = [["采购商", "成交金额"]]
out2 = [["201707~09","采购商", "成交金额"]]

res.sort_by{|n| -n["value"]["price"]}[0,10].each do |m|
  #city_out << [m["_id"]["consumer"], m["value"]["price"]]
  out2 << [nil, m["_id"]["consumer"], m["value"]["price"]]
  #country_out << [m["_id"]["country"], m["value"]["count"]]
end


out = [["月份", "多日包车", "一日包车", "接机", "送机", "送站", "接站"]]
types = a.map(&:type).uniq

span.each do |n|
  t = [n]
  types.each do |m|
    base = res.select{|x| x["_id"]["date"] == n && x["_id"]["type"] == m}.first
    p m
    p n
    t << (base.present? ? base["value"]["count"].to_i : 0)
  end
  out<< t
end

Emailer.send_custom_file(['jinxue@haihuilai.com'], "201607~10订单类型数量统计", XlsGen.gen(out), "201607~-10订单类型数量统计.xls").deliver_now

Emailer.send_custom_file(['jinxue@haihuilai.com'], "07-09采购商同期流水统计", XlsGen.gen(out,out2), "07-09采购商同期流水统计.xls").deliver_now




# 9月top 10 城市信息
#
res = Booking.where(:created_at => Time.parse("2017-09-01")..Time.parse("2017-10-01"),:status.ne => "退单完成", :paid_at.ne => nil).map_reduce(
  %Q{
    function(){
      var country = this.from_country;
      var city = this.from_city;
      var price = this.total_rmb;
      //emit({country: country, city:city }, {price: this.total_rmb, count: 1})
      emit({country: country }, {price: this.total_rmb, count: 1})
    }
  },
  %Q{ 
    function(key, items){
      var r = {price: 0, count:0}
      items.forEach(function(item){
        r.price += item.price;
        r.count += item.count;
      })
      return r;
    }
  }
).out(:inline => true).to_a

out = [["国家", "成交额", "单量", "平均单价"]]
res.sort_by{|x| -x["value"]["count"]}[0,20].each do |n|
  out << [n["_id"]["country"], n["value"]["price"],  n["value"]["count"].to_i, (n["value"]["price"] / n["value"]["count"]).to_f.round(2)]
end

send = [["单号", "下单时间", "出发时间", "结束时间", "出发城市", "用车时长(天)", "类型"]]
Booking.where(:created_at => Time.parse("2017-09-01")..Time.parse("2017-10-01"),:status.ne => "退单完成", :paid_at.ne => nil).each do |n|

  num = n.booking_param
  start_date = n.from_date
  end_date = n.to_date
  send << [num, n.created_at.to_date, start_date, end_date, n.from_city, n.day_count, n.type]
end



Emailer.send_custom_file(['wudi@haihuilai.com',], "Top10国家信息及9月成交订单用车时长统计", XlsGen.gen(out,send), "Top10国家信息及9月成交订单用车时长统计.xls").deliver_now

Emailer.send_custom_file(['wudi@haihuilai.com',], "Top20国家信息", XlsGen.gen(out), "Top20国家信息.xls").deliver_now

       var day = new Date(this.paid_at* 1 + 1000 * 3600 * 8);
res = Booking.paid.where(:paid_at => Time.parse("2017-01-01")..Time.parse("2017-10-01"),:status.ne => "退单完成",).map_reduce(
  %Q{
    function(){
       var day = new Date(this.paid_at);
       var key_string = day.getFullYear() + "-" + ( (day.getMonth() + 1));
       var k = day.getFullYear() + "-" + ( (day.getMonth() + 1)) + '-' + (day.getDate() );

      emit({date: key_string, k:k, time: day, type: this.type }, {price: this.total_rmb, supplier_price: this.supplier_total_rmb, count: 1})
    }
  },
  %Q{ 
    function(key, items){
      var r = {price: 0, supplier_price:0 ,count:0}
      items.forEach(function(item){
        r.price += item.price;
        r.supplier_price += item.supplier_price;
        r.count += item.count;
      })
      return r;
    }
  }
).out(:inline => true).to_a



out = [["月度", "订单类型", "汇总金额", "供应总价", "单量", "客单价", "毛利"]]
res.each do |n|
  out << [n["_id"]["date"], n["_id"]["type"], n["value"]["price"].round(2), n["value"]["supplier_price"].round(2), 
          n["value"]["count"].to_i, (n["value"]["price"] / n["value"]["count"]).round(2), 
          (n["value"]["price"].round(2) -  n["value"]["supplier_price"].round(2)).round(2)

  ]
end
Emailer.send_custom_file(['hanguang@haihuilai.com',], "2017各月已成交订单类型毛利", XlsGen.gen(out), "2017各月已成交订单类型毛利统计.xls").deliver_now



Time.parse("2017-01-01").to_date..Time.parse("2017-10-01").to_date.to_date
Time.now.beginning_of_year.to_date..Time.parse("2017-10-01").to_date




# 卢刚名下采购商列表
#
send = [["id", "公司名称", "注册人", "账户类型", "支付方式", "联系方式", "审核状态"]]
Consumer.where(:admin_user => "卢钢").each do |n|
  type = n.manager_id.nil? ? "主账号": "子账号"
  send << [n.id, n.company_name, n.fullname, type, n.payment_type, n.email, n.review_status]

end
Emailer.send_custom_file(['wudi@haihuilai.com'], "卢钢名下采购商信息", XlsGen.gen(send), "卢刚名下采购商信息.xls").deliver_now
