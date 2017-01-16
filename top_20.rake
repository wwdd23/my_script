#当前区间分红收益
@start_day = params[:start_day] || 1.week.ago.to_date.to_s
@end_day = params[:end_day] || 1.day.ago.to_date.to_s

@start_day = 1.week.ago.to_date.to_s
@end_day = 1.day.ago.to_date.to_s

# [["2016-03-03", "2016-03-09"], ["2016-02-25", "2016-03-02"], 7]
time_array = get_date_time(@start_day,@end_day)

span_title1 = "当前区间#{time_array[2]}天订单量"
span_title2 = "之前#{time_array[2]}天订单量"
top_low = ['top','low']


span_now = time_array[0][0].to_date..time_array[0][1].to_date
span_prev = time_array[1][0].to_date..time_array[1][1].to_date
user_ids = User.where(:referral_id.ne => nil).map(&:referral_id).uniq

diviend_array = {}
user_ids.each do |n|
  diviend_array[n] ||= []
end
# 镜像文件为昨日数据，查询日期 + 1
snapshot_now_first = user_span(span_now.first.tomorrow.to_date.to_s)
snapshot_now_last = user_span(span_now.last.tomorrow.to_date.to_s)
snapshot_prev_first = user_span(span_prev.first.tomorrow.to_date.to_s)
snapshot_prev_last = user_span(span_prev.last.tomorrow.to_date.to_s)

# 点击量数据汇总  通过 enc_id判断
# [{:enc_id=>587681955, :count=>1}, {:enc_id=>587681955, :count=>1}]
tracker_now = tracker_info(span_now.first.to_date.to_s,span_now.last.tomorrow.to_date.to_s)
tracker_prev = tracker_info(span_prev.first.to_date.to_s,span_prev.last.tomorrow.to_date.to_s)


# 订单数据
#
order_now = HouseOrder.where(:created_at => span_now,:referral.ne => nil).group_by{|n| n[:referral]}
order_prev = HouseOrder.where(:created_at => span_prev,:referral.ne => nil).group_by{|n| n[:referral]}


user_ids.each do |n|
  #七日分后收益 / 差值
  if snapshot_now_last["#{n}"].blank?
    next
  else
    nickname = snapshot_now_last["#{n}"][:nickname]
    enc_id = snapshot_now_last["#{n}"][:user_enc_id]
    # 收益相关
    diviend_now = snapshot_now_last["#{n}"].try(:[],:div_gain ).to_f - snapshot_now_first["#{n}"].try(:[],:div_gain).to_f
    diviend_prev = snapshot_prev_last["#{n}"].try(:[],:div_gain).to_f - snapshot_prev_first["#{n}"].try(:[],:div_gain).to_f

    diviend_diff = (diviend_now - diviend_prev).round(2)
    # 新增用户相关
    user_count_now = snapshot_now_last["#{n}"].try(:[],:user_count ).to_i - snapshot_now_first["#{n}"].try(:[],:user_count).to_i
    user_count_prev = snapshot_prev_last["#{n}"].try(:[],:user_count).to_i - snapshot_prev_first["#{n}"].try(:[],:user_count).to_i
    user_count_diff = (user_count_now - user_count_prev)

    #点击量相关

    count_base_now = tracker_now.select{|n| n[:enc_key] == enc_id.to_i}
    tracker_count_now = count_base_now.present? ? count_base_now.first[:count] : 0
    count_base_prev = tracker_prev.select{|n| n[:enc_key] == enc_id.to_i}
    tracker_count_prev = count_base_prev.present? ? count_base_prev.first[:count] : 0
    tracker_count_diff = tracker_count_now - tracker_count_prev
    # 订单相关
    #  a["阿宝爱旅游"].select{|n| n["paid_at"] != nil}.count

    base_refer_order_now = order_now[nickname]
    base_refer_order_prev = order_prev[nickname]
    if base_refer_order_now.present?
      # 提交间夜
      sub_order_night_now = base_refer_order_now.map(&:number_night_count).reduce(:+)
      # 成交间夜
      paid_order_night_now = base_refer_order_now.select{|n| n["paid_at"] != nil}.map(&:number_night_count).reduce(:+)
    else
      sub_order_night_now = 0
    end
    if base_refer_order_prev.present?
      sub_order_night_prev = base_refer_order_prev.map(&:number_night_count).reduce(:+)
      paid_order_night_prev = base_refer_order_prev.select{|n| n["paid_at"] != nil}.map(&:number_night_count).reduce(:+)
    else
      sub_order_night_prev = 0
    end
    sub_night_diff = sub_order_night_now.to_i - sub_order_night_prev.to_i
    paid_night_diff = paid_order_night_now.to_i - paid_order_night_prev.to_i

    #diviend_array[n] = [nickname, diviend_now.round(2), diviend_prev.round(2), diviend_diff,user_count_diff, tracker_count_diff, sub_night_diff, paid_night_diff]
    diviend_array <<  [nickname, diviend_now.round(2), diviend_prev.round(2), diviend_diff,user_count_diff, tracker_count_diff, sub_night_diff, paid_night_diff]
  end
end


# 排序
sort_arr_top = diviend_array.select{|n| n[3] >= 0}
sort_arr_low = diviend_array.select{|n| n[3] < 0}

@content_top = [[span_title1, span_title2, "收益金额变化", "新增用户数变化", "点击量变化", '提交间夜变化', '成交间夜变化']]
@content_low = [[span_title1, span_title2, "收益金额变化", "新增用户数变化", "点击量变化", '提交间夜变化', '成交间夜变化']]
if sort_arr_top.present?
  @content_top.contect(sort_arr_top.sort{|n,m|} m[3].to_i <=> n[3].to_i)
  @content_low.contect(sort_arr_low.sort{|n,m|} n[3].to_i <=> m[3].to_i)
end



def get_date_time(start_day,end_day)
  span = (end_day.to_date - start_day.to_date).to_i + 1
  start = Time.parse(end_day)
  date_bow = [start_day,end_day] #before one week
  date_btw = [(start_day.to_time - 1.weeks).to_date.to_s, (start_day.to_time - 1.days).to_date.to_s] # before two week
  return [date_bow,date_btw,span]
end


def user_span(day)
  out = {}
  ShareholderSnapshot.where(:day => day).each do |n|
    id = n.user_id
    nickname = n.nickname
    div_gain = n.div_gain
    user_enc_id = n.user_enc_id
    user_count = n.user_count
    out[id] = {
      :nickname => nickname,
      :div_gain => div_gain,
      :user_count => user_count,
      :user_enc_id => user_enc_id,
    }
  end
  return out
end

#start_day = span_now.first.to_date.to_s
#end_day = span_now.last.tomorrow.to_date.to_s
def tracker_info(start_day,end_day)
   q = {
      :size => 0,
      :query => {
        :bool => {
          :must => [
            {:regexp => {:lc => ".*referral_id=.*"}},
            #{:range => {:created_at => {:gt => day-1.week,:lt => day }}}
            {:range => {:created_at => {:gt => Time.parse(start_day), :lt => Time.parse(end_day)}}}
          ]
        }
      },
      :aggs => {
        :tracker => {
          :terms => {
            :size => 0,
            :field => "lc"
          }
        }
      }
   }
   referral_aggs = Tracker.aggs(q).tracker.buckets

   info = referral_aggs.map do |n|
     enc_key = n['key'].match(/referral_id=(\w+)/)
     next unless enc_key
     count = n['doc_count']
     {
       :enc_id => enc_key[1].to_i,
       :count => count
     }
   end
   enc_ids = info.compact.map {|n| {:enc_key => n[:enc_id]}}.uniq
   # 统计所有包含股东ID 点击的链接
   tracker_enc = enc_ids.map do |n|
     count = info.compact.map{ |k| k[:count] if n[:enc_key] == k[:enc_id]}.compact.reduce(:+)
     n.merge!({:count => count})
   end
   return tracker_enc
end
