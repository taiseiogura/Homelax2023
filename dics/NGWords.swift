import Foundation


var NGs: [String] = [
    "いざり",
    "いなくなればいい",
    "消え",
    "地獄",
    "亡",
    "うざ",
    "ウザ",
    "うんこ",
    "うんち",
    "おかしい",
    "あたおか",
    "アタオカ",
    "かたわ",
    "きしょ",
    "きも",
    "キモ",
    "汚",
    "きたな",
    "きちがい",
    "ぎっちょ",
    "きらい",
    "くさい",
    "臭",
    "嫌",
    "けつ",
    "最低",
    "つんぼ",
    "でべそ",
    "びっこ",
    "めくら",
    "アスペ",
    "アホ",
    "あほ",
    "カス",
    "かす",
    "ガイジ",
    "キチガイ",
    "きちがい",
    "クソ",
    "くそ",
    "クソくらえ",
    "クソアマ",
    "クソガキ",
    "クソゴミ",
    "ジジイ",
    "しっこ",
    "シッコ",
    "死",
    "死ね",
    "しね",
    "ﾀﾋ",
    "タヒ",
    "ステハゲ",
    "デブ",
    "ナマポ",
    "ネトウヨ",
    "ハゲ",
    "バカ",
    "ばーか",
    "バーカ",
    "バカヤロウ",
    "バカヤロー",
    "ババア",
    "パヨク",
    "ピネガキ",
    "ブス",
    "ボケ",
    "ポリ公",
    "マヌケ",
    "老害",
    "唖",
    "土方",
    "尻軽",
    "支那",
    "支那人",
    "池沼",
    "畜生",
    "白痴",
    "糖質",
    "糞",
    "糞食らえ",
    "統失",
    "木偶の坊",
    "でくのぼう",
    "豚野郎",
    "非国民",
    "馬鹿野郎",
    "野郎",
    "ばか",
    "馬鹿",
    "3P",
    "AV女優",
    "Gスポット",
    "NTR",
    "SEX",
    "SM",
    "SOD",
    "Tバック",
    "いやらしい",
    "えっち",
    "おちんちん",
    "おっπ",
    "おっぱい",
    "おなにー",
    "おねショタ",
    "おぼこ",
    "おまんこ",
    "おめこ",
    "お掃除フェラ",
    "きんたま",
    "さかさ椋鳥",
    "しぼり芙蓉",
    "すけべ",
    "せきれい本手",
    "せっくす",
    "だいしゅきホールド",
    "ちんこ",
    "ちんちん",
    "ちんぽ",
    "ひとりえっち",
    "ふたなり",
    "まんぐり返し",
    "まんこ",
    "まんまん",
    "むらむら",
    "アクメ",
    "アゲマン",
    "アダルトビデオ",
    "アナニー",
    "アナル",
    "アナルセックス",
    "アナルビーズ",
    "アナルプラグ",
    "アナル拡張",
    "アナル開発",
    "アナルＳＥＸ",
    "アヘ顔",
    "イク",
    "イチモツ",
    "イチャイチャセックス",
    "イチャラブセックス",
    "イメクラ",
    "イメージビデオ",
    "イラマチオ",
    "インポ",
    "インポテンツ",
    "エクスタシー",
    "エッチ",
    "エロ",
    "工口",
    "エロい",
    "エロ同人",
    "エロ同人誌",
    "エロ本",
    "オナニー",
    "オナペ",
    "オナペット",
    "オナホ",
    "オナホール",
    "オーガズム",
    "カウパー",
    "カントン包茎",
    "キンタマ",
    "ギャグボール",
    "クスコ",
    "クソガキ",
    "クリトリス",
    "クンニリングス",
    "クンニ",
    "ケツマンコ",
    "コンドーム",
    "サゲマン",
    "ザーメン",
    "シックスナイン",
    "ショタおね",
    "スカトロ",
    "スケベ",
    "スケベ椅子",
    "スペルマ",
    "スワッピング",
    "セックス",
    "セフレ",
    "センズリ",
    "ソフト・オン・デマンド",
    "ソープランド",
    "ソープ嬢",
    "ダッチワイフ",
    "ダブルピース",
    "チンコ",
    "チンチン",
    "チンポ",
    "ディルド",
    "ディープスロート",
    "デカチン",
    "デリバリーヘルス",
    "デリヘル",
    "トロ顔",
    "ナンパ",
    "ノーパン",
    "ハメ撮り",
    "ハーレム",
    "バイアグラ",
    "バキュームフェラ",
    "パイズリ",
    "パイパン",
    "パパ活",
    "パンチラ",
    "ビッチ",
    "フィストファック",
    "フェラ",
    "フェラチオ",
    "フェラ抜き",
    "ブルセラ",
    "ペッティング",
    "ペニバン",
    "ホ別",
    "ボテ腹",
    "ポコチン",
    "ポルチオ",
    "マスターベーション",
    "マンコ",
    "ムラムラ",
    "ヤリチン",
    "ヤリマン",
    "ラブドール",
    "ラブホ",
    "ラブホテル",
    "リフレ",
    "レイプ",
    "ロリコン",
    "一人Ｈ",
    "中出し",
    "乙π",
    "乱れ牡丹",
    "乱交",
    "乳房",
    "乳首",
    "亀甲縛り",
    "亀頭",
    "二穴",
    "二穴同時",
    "仮性包茎",
    "体位",
    "個人撮影",
    "催眠",
    "兜合わせ",
    "入船本手",
    "円光",
    "処女",
    "包茎",
    "口内射精",
    "口内発射",
    "唐草居茶臼",
    "喘ぎ声",
    "四十八手",
    "太ももコキ",
    "姫始め",
    "媚薬",
    "孕ませ",
    "寝取られ",
    "寝取り",
    "寿本手",
    "射精",
    "屍姦",
    "巨乳",
    "巨尻",
    "巨根",
    "帆かけ茶臼",
    "座位",
    "強姦",
    "後背位",
    "微乳",
    "忍び居茶臼",
    "快楽堕ち",
    "性交",
    "性処理",
    "性奴隷",
    "性感",
    "性感マッサージ",
    "性感帯",
    "性欲",
    "性行為",
    "愛人",
    "愛撫",
    "愛液",
    "成人向け",
    "我慢汁",
    "手コキ",
    "手マン",
    "手淫",
    "抱き地蔵",
    "揚羽本手",
    "援交",
    "援助交際",
    "放尿",
    "放置プレイ",
    "早漏",
    "時雨茶臼",
    "月見茶臼",
    "朝勃ち",
    "朝起ち",
    "松葉崩し",
    "機織茶臼",
    "正常位",
    "汁男優",
    "泡姫",
    "洞入り本手",
    "淫乱",
    "淫行",
    "淫語",
    "淫靡",
    "熟女",
    "爆乳",
    "獣姦",
    "玉舐め",
    "生ハメ",
    "男娼",
    "痴女",
    "発情",
    "真性包茎",
    "睡姦",
    "睾丸",
    "種付け",
    "種付けプレス",
    "穴兄弟",
    "立ちんぼ",
    "童貞",
    "笠舟本手",
    "筆おろし",
    "筏本手",
    "粗チン",
    "素股",
    "素股",
    "絶倫",
    "網代本手",
    "緊縛",
    "肉便器",
    "胸チラ",
    "脇コキ",
    "自慰",
    "菊門",
    "蟻の戸渡り",
    "裏筋",
    "貝合わせ",
    "貧乳",
    "足コキ",
    "輪姦",
    "近親相姦",
    "逆アナル",
    "逆レイプ",
    "遅漏",
    "金玉",
    "陰唇",
    "陰嚢",
    "陰核",
    "陰毛",
    "陰茎",
    "陰部",
    "陵辱",
    "雁が首",
    "電マ",
    "青姦",
    "顔射",
    "食糞",
    "飲尿",
    "首引き恋慕",
    "騎乗位",
    "鶯の谷渡り",
    "黄金水",
    "黒ギャル",
    "ＳＭプレイ",
    "ﾁﾝﾁﾝ",
    "shit",
    "Shit",
    "fuck",
    "Fuck",
    "hell",
]
