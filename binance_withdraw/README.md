
binance 指定coin 脚本提币工具



- 安装依赖包

    pip install -r requirements.txt 




1. 手动安装binance-connector 包
    pip install binance-connector



使用方法

1. 修改config.ini 

api_key=biance api key 
api_secret=binance secret

coin= 需要提币的币种 大写  ex. BETH

address=ajklsdfjadsljfs  # 提币地址 无需添加双引号


2.  文件执行 
    
    $ python withdraw.py 

    - 1. 显示币种信息
    - 2. 按回车继续
    - 3. 获取钱包中coin信息 确认划转余额信息
    - 4. 如果小于最小划转数量提示后退出
    - 5. 确认后10s 执行划转操作
    

