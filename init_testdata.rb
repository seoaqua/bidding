require 'redis'
require 'json'
jobs = JSON.parse('
    [{
      "id": 654615,
      "name": "昆明学院人民西路校区周围住宿",
      "account_id": 2,
      "se_id": 349818000,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "0000-00-00 00:00:00"
    },
    {
      "id": 654614,
      "name": "昆明学院周围住宿",
      "account_id": 2,
      "se_id": 349809552,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "0000-00-00 00:00:00"
    },
    {
      "id": 654613,
      "name": "锦州师范高等专科学校周围住宿",
      "account_id": 2,
      "se_id": 584699280,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "0000-00-00 00:00:00"
    },
    {
      "id": 654612,
      "name": "健雄职业技术学院周围住宿",
      "account_id": 2,
      "se_id": 584695952,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "0000-00-00 00:00:00"
    },
    {
      "id": 654611,
      "name": "建华中学周围住宿",
      "account_id": 2,
      "se_id": 584696976,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "0000-00-00 00:00:00"
    },
    {
      "id": 654610,
      "name": "建华学校周围住宿",
      "account_id": 2,
      "se_id": 584697744,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "0000-00-00 00:00:00"
    },
    {
      "id": 654609,
      "name": "嘉兴学院周围住宿",
      "account_id": 2,
      "se_id": 584703120,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "0000-00-00 00:00:00"
    },
    {
      "id": 654608,
      "name": "惠州西湖周围住宿",
      "account_id": 2,
      "se_id": 601454480,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "0000-00-00 00:00:00"
    },
    {
      "id": 654607,
      "name": "惠州商业学校周围住宿",
      "account_id": 2,
      "se_id": 601443216,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "0000-00-00 00:00:00"
    },
    {
      "id": 654606,
      "name": "湖南信息科学职业学院周围住宿",
      "account_id": 2,
      "se_id": 601481872,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "0000-00-00 00:00:00"
    },
    {
      "id": 654605,
      "name": "湖南现代物流职业技术学院周围住宿",
      "account_id": 2,
      "se_id": 601482640,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "0000-00-00 00:00:00"
    },
    {
      "id": 654604,
      "name": "湖南外国语职业学院周围住宿",
      "account_id": 2,
      "se_id": 601487760,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "0000-00-00 00:00:00"
    },
    {
      "id": 654603,
      "name": "湖南交通职业技术学院周围住宿",
      "account_id": 2,
      "se_id": 601480080,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "0000-00-00 00:00:00"
    },
    {
      "id": 654602,
      "name": "湖南环境生物职业技术学院周围住宿",
      "account_id": 2,
      "se_id": 601480592,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "0000-00-00 00:00:00"
    },
    {
      "id": 654601,
      "name": "湖北广播电视大学周围住宿",
      "account_id": 2,
      "se_id": 953758353,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "0000-00-00 00:00:00"
    },
    {
      "id": 654415,
      "name": "南京师范大学随园校区周围住宿",
      "account_id": 2,
      "se_id": 4141418641,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654414,
      "name": "威海实验中学周围住宿",
      "account_id": 2,
      "se_id": 4107899025,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654413,
      "name": "浙江医学高等专科学校周围住宿",
      "account_id": 2,
      "se_id": 2061100432,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654412,
      "name": "日照职业技术学院周围住宿",
      "account_id": 2,
      "se_id": 2061100944,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654411,
      "name": "烟台国际博览中心周围住宿",
      "account_id": 2,
      "se_id": 2061105552,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654410,
      "name": "厦门湖滨南路周围住宿",
      "account_id": 2,
      "se_id": 2061106832,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654409,
      "name": "北京西单周围住宿",
      "account_id": 2,
      "se_id": 4124664465,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654408,
      "name": "罗芳中学周围住宿",
      "account_id": 2,
      "se_id": 4124665745,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654407,
      "name": "安徽新闻出版职业技术学院周围住宿",
      "account_id": 2,
      "se_id": 4124670353,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654406,
      "name": "佛山惠景中学周围住宿",
      "account_id": 2,
      "se_id": 4124670865,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654405,
      "name": "鄂东职业技术学院周围住宿",
      "account_id": 2,
      "se_id": 4124646289,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654404,
      "name": "滁州职业技术学院周围住宿",
      "account_id": 2,
      "se_id": 4124692369,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654403,
      "name": "周口师范学院周围住宿",
      "account_id": 2,
      "se_id": 4124692113,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654402,
      "name": "福州杨桥中学周围住宿",
      "account_id": 2,
      "se_id": 4124688529,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654401,
      "name": "广西机电工业学校周围住宿",
      "account_id": 2,
      "se_id": 4124675985,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654400,
      "name": "上海立信会计学院周围住宿",
      "account_id": 2,
      "se_id": 4124673169,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654399,
      "name": "郑州交通职业学院周围住宿",
      "account_id": 2,
      "se_id": 2061093264,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654398,
      "name": "日照实验高中周围住宿",
      "account_id": 2,
      "se_id": 2061094800,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654397,
      "name": "武大周围住宿",
      "account_id": 2,
      "se_id": 2061097872,
      "max_price": 13,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 12,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654396,
      "name": "吉林化工学院周围住宿",
      "account_id": 2,
      "se_id": 4124678289,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654395,
      "name": "山东现代职业学院周围住宿",
      "account_id": 2,
      "se_id": 3940137105,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654394,
      "name": "上沙中学周围住宿",
      "account_id": 2,
      "se_id": 3940138897,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654393,
      "name": "云南师范大学呈贡校区周围住宿",
      "account_id": 2,
      "se_id": 3956894097,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654392,
      "name": "乌镇周围住宿",
      "account_id": 2,
      "se_id": 2077850768,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654391,
      "name": "泸州职业技术学院周围住宿",
      "account_id": 2,
      "se_id": 2077851280,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654390,
      "name": "西安康复路周围住宿",
      "account_id": 2,
      "se_id": 2077848464,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654389,
      "name": "福州延安中学周围住宿",
      "account_id": 2,
      "se_id": 3956869777,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654388,
      "name": "张家界航空工业职业技术学院周围住宿",
      "account_id": 2,
      "se_id": 3956931217,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654387,
      "name": "天津青年职业学院周围住宿",
      "account_id": 2,
      "se_id": 3956931985,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654386,
      "name": "佛山荣山中学周围住宿",
      "account_id": 2,
      "se_id": 3923322257,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654385,
      "name": "石家庄外语翻译职业学院周围住宿",
      "account_id": 2,
      "se_id": 3822668945,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654384,
      "name": "中国矿业大学银川学院周围住宿",
      "account_id": 2,
      "se_id": 3772347793,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654383,
      "name": "青岛鞍山二路小学周围住宿",
      "account_id": 2,
      "se_id": 3789152401,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654382,
      "name": "江西工程职业学院周围住宿",
      "account_id": 2,
      "se_id": 2077849232,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654381,
      "name": "重庆求精中学周围住宿",
      "account_id": 2,
      "se_id": 2077843344,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654380,
      "name": "黄石理工学院周围住宿",
      "account_id": 2,
      "se_id": 3889795217,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654379,
      "name": "佛山第三中学周围住宿",
      "account_id": 2,
      "se_id": 3839434897,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654378,
      "name": "广东省旅游职业技术学校周围住宿",
      "account_id": 2,
      "se_id": 3856249745,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654377,
      "name": "烟台清泉学校周围住宿",
      "account_id": 2,
      "se_id": 2597915793,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654376,
      "name": "云南师范大学商学院周围住宿",
      "account_id": 2,
      "se_id": 2597913745,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654375,
      "name": "吉林农业科技学院周围住宿",
      "account_id": 2,
      "se_id": 2597914257,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654374,
      "name": "浙江警官职业学院周围住宿",
      "account_id": 2,
      "se_id": 2597919121,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654373,
      "name": "洛阳龙门石窟周围住宿",
      "account_id": 2,
      "se_id": 2597919633,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654372,
      "name": "安徽艺术职业学院周围住宿",
      "account_id": 2,
      "se_id": 2597976465,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654371,
      "name": "博雅中学周围住宿",
      "account_id": 2,
      "se_id": 2077840784,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654370,
      "name": "华南理工大学五山校区周围住宿",
      "account_id": 2,
      "se_id": 2077830544,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654369,
      "name": "湖北汽车工业学院周围住宿",
      "account_id": 2,
      "se_id": 2077831056,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654368,
      "name": "枣庄科技职业学院周围住宿",
      "account_id": 2,
      "se_id": 2597974417,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654367,
      "name": "湖南商务职业技术学院周围住宿",
      "account_id": 2,
      "se_id": 2614711441,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654366,
      "name": "湖南艺术职业学院周围住宿",
      "account_id": 2,
      "se_id": 2614700433,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },

    {
      "id": 654265,
      "name": "长春职业技术学院周围住宿",
      "account_id": 2,
      "se_id": 2648288913,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654264,
      "name": "苏州大学东校区周围住宿",
      "account_id": 2,
      "se_id": 1708732561,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654263,
      "name": "西华师范大学周围住宿",
      "account_id": 2,
      "se_id": 1708724881,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654262,
      "name": "南京汉中门周围住宿",
      "account_id": 2,
      "se_id": 1708769681,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654261,
      "name": "西安翻译学院周围住宿",
      "account_id": 2,
      "se_id": 450461329,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654260,
      "name": "金陵科技学院周围住宿",
      "account_id": 2,
      "se_id": 450486673,
      "max_price": 9,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 8,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654259,
      "name": "中州大学周围住宿",
      "account_id": 2,
      "se_id": 450477457,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654258,
      "name": "南京大学仙林校区周围住宿",
      "account_id": 2,
      "se_id": 2648279441,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654257,
      "name": "青岛科技大学周围住宿",
      "account_id": 2,
      "se_id": 2648279953,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654256,
      "name": "上饶师范学院周围住宿",
      "account_id": 2,
      "se_id": 2463703185,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654255,
      "name": "滨州职业学院周围住宿",
      "account_id": 2,
      "se_id": 2463698577,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654254,
      "name": "宁波诺丁汉大学周围住宿",
      "account_id": 2,
      "se_id": 2480496273,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654253,
      "name": "吉林师范大学周围住宿",
      "account_id": 2,
      "se_id": 2430184081,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654252,
      "name": "沈阳医学院周围住宿",
      "account_id": 2,
      "se_id": 2430179473,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654251,
      "name": "郑州世纪欢乐园周围住宿",
      "account_id": 2,
      "se_id": 2430178193,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654250,
      "name": "新乡医学院周围住宿",
      "account_id": 2,
      "se_id": 2430178705,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654249,
      "name": "吉林动画学院周围住宿",
      "account_id": 2,
      "se_id": 2430178449,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654248,
      "name": "山西医科大学周围住宿",
      "account_id": 2,
      "se_id": 2430179217,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654247,
      "name": "南阳师范学院周围住宿",
      "account_id": 2,
      "se_id": 2446944657,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654246,
      "name": "东华理工大学周围住宿",
      "account_id": 2,
      "se_id": 2446944401,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654245,
      "name": "安徽工业大学周围住宿",
      "account_id": 2,
      "se_id": 467222417,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654244,
      "name": "泉州师范学院周围住宿",
      "account_id": 2,
      "se_id": 467254417,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654243,
      "name": "沈阳职业技术学院周围住宿",
      "account_id": 2,
      "se_id": 467251345,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654242,
      "name": "内蒙古科技大学周围住宿",
      "account_id": 2,
      "se_id": 467251857,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654241,
      "name": "厦门理工学院周围住宿",
      "account_id": 2,
      "se_id": 416904593,
      "max_price": 21,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 20,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654240,
      "name": "广西财经学院周围住宿",
      "account_id": 2,
      "se_id": 416905105,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654239,
      "name": "泰山学院周围住宿",
      "account_id": 2,
      "se_id": 2446945169,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654238,
      "name": "安徽师范大学周围住宿",
      "account_id": 2,
      "se_id": 2446940561,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654237,
      "name": "宝鸡文理学院周围住宿",
      "account_id": 2,
      "se_id": 2446940305,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654236,
      "name": "南昌工程学院周围住宿",
      "account_id": 2,
      "se_id": 2446939025,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654235,
      "name": "湛江师范学院周围住宿",
      "account_id": 2,
      "se_id": 2446932113,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654234,
      "name": "漳州师范学院周围住宿",
      "account_id": 2,
      "se_id": 2530824337,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654233,
      "name": "河北工程大学周围住宿",
      "account_id": 2,
      "se_id": 2530824849,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654232,
      "name": "潍坊医学院周围住宿",
      "account_id": 2,
      "se_id": 2547601297,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654231,
      "name": "郑州航院周围住宿",
      "account_id": 2,
      "se_id": 2547634833,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654230,
      "name": "大连海事大学周围住宿",
      "account_id": 2,
      "se_id": 2497310353,
      "max_price": 9,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 8,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654229,
      "name": "沈阳五爱市场周围住宿",
      "account_id": 2,
      "se_id": 2497312145,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654228,
      "name": "青岛中山路周围住宿",
      "account_id": 2,
      "se_id": 2497311889,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654227,
      "name": "吉林警察学院周围住宿",
      "account_id": 2,
      "se_id": 2514059153,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654226,
      "name": "广东海洋大学周围住宿",
      "account_id": 2,
      "se_id": 2514058897,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654225,
      "name": "戏剧学院周围住宿",
      "account_id": 2,
      "se_id": 2514055569,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654224,
      "name": "海口经济学院周围住宿",
      "account_id": 2,
      "se_id": 2514057105,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654223,
      "name": "湖北民族学院周围住宿",
      "account_id": 2,
      "se_id": 416894865,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654222,
      "name": "西北民族大学周围住宿",
      "account_id": 2,
      "se_id": 416891025,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654221,
      "name": "西安财经学院周围住宿",
      "account_id": 2,
      "se_id": 416890257,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654220,
      "name": "南京中医药大学周围住宿",
      "account_id": 2,
      "se_id": 416890001,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654219,
      "name": "虹桥机场周围住宿",
      "account_id": 2,
      "se_id": 416890769,
      "max_price": 9,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 8,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654218,
      "name": "安徽工程大学周围住宿",
      "account_id": 2,
      "se_id": 416886929,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654217,
      "name": "青岛理工大学周围住宿",
      "account_id": 2,
      "se_id": 416887441,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    },
    {
      "id": 654216,
      "name": "长沙医学院周围住宿",
      "account_id": 2,
      "se_id": 416888721,
      "max_price": 6,
      "runtime": "0000-00-00 00:00:00",
      "min_price": 0.8,
      "price": 5,
      "side": 1,
      "position": 1,
      "status": 0,
      "updated_at": "2014-01-21 15:00:55"
    }
]
')

# p bargin({:side => 2,:position=>1},{'name'=>'x','status'=>0,'price'=>1,'side'=>1,'position'=>1,'max_price'=>3.3})
redis = Redis.new
# threads = []
# 10.times do
#   threads << Thread.new do
#     loop do
#     job = redis.lpop('jobs')
#     break if job.nil?
#     p JSON.parse(job)['name']
#     end
#   end
# end
# threads.each{|t|t.join}
# exit
jobs.each do |job|
  redis.lpush('jobs',job['name'])
  redis.set(job['name'],job.to_json)
end