class DiagnosisSession < ApplicationRecord
  require "digest"
  def to_param = session_token
  ANIMAL_TYPES = %w[gorilla crab fox frog penguin].freeze
  CREDO_KEYS = %w[be_open move_fast give_first geek_out take_ownership].freeze
  # 定数定義
  TOTAL_QUESTIONS = 10

  before_validation :set_expiration, on: :create
  before_validation :generate_session_token, on: :create

  before_create :initialize_progress

  validates :session_token, presence: true, uniqueness: true, length: { is: 32 }
  validates :expires_at, presence: true
  validates :result_animal_type, inclusion: { in: ANIMAL_TYPES, allow_blank: true }
  validate  :answers_must_be_array_within_range

# === 質問（10問） ===
# 各選択肢は対応CREDOに5点を付与（他は0）でシンプルに判定します。
QUESTIONS = [
  {
    id: 1,
    text: "初めてのエンジニア生活!、あなたはどんな会社で働いてみたい？",
    options: [
      { text: "好きな技術やツールの話を熱く語りあえるチーム",
        scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 5, take_ownership: 0 } },
      { text: "アウトプット会など、知識や経験を惜しみなく共有し合うチーム",
        scores: { be_open: 0, move_fast: 0, give_first: 5, geek_out: 0, take_ownership: 0 } },
      { text: "役割をしっかりと任せてもらえて、責任を持って仕事ができるチーム",
        scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 5 } },
      { text: "初めてのことや分からないことでも積極的に挑戦させてもらえる",
        scores: { be_open: 0, move_fast: 5, give_first: 0, geek_out: 0, take_ownership: 0 } },
      { text: "分からないことや不安を素直に共有でき、支えてくれるチーム",
        scores: { be_open: 5, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 0 } }
    ]
  },
  {
    id: 2,
    text: "文化祭の準備であなたが自然にやっていたことは？",
    options: [
      { text: "新しいアイデアや演出を提案する",
        scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 5, take_ownership: 0 } },
      { text: "進捗や困っていることをみんなに共有する",
        scores: { be_open: 5, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 0 } },
      { text: "裏方作業を率先して引き受ける",
        scores: { be_open: 0, move_fast: 0, give_first: 5, geek_out: 0, take_ownership: 0 } },
      { text: "班をまとめて全体の進行を仕切る",
        scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 5 } },
      { text: "道具をどんどん買い出しに行き、形にする",
        scores: { be_open: 0, move_fast: 5, give_first: 0, geek_out: 0, take_ownership: 0 } }
    ]
  },
  {
    id: 3,
    text: "旅行の計画を立てるときのあなたの役割は？",
    options: [
      { text: "計画を整理して旅程表にまとめる",
        scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 5 } },
      { text: "穴場スポットやそこでしかできない体験を調べる",
        scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 5, take_ownership: 0 } },
      { text: "全員の希望を聞いてまとめる",
        scores: { be_open: 0, move_fast: 0, give_first: 5, geek_out: 0, take_ownership: 0 } },
      { text: "すぐに調べて、プランにまとめたり予約を進める",
        scores: { be_open: 0, move_fast: 5, give_first: 0, geek_out: 0, take_ownership: 0 } },
      { text: "行きたい場所やしたいことなど自分の意見を伝える",
        scores: { be_open: 5, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 0 } }
    ]
  },
  {
    id: 4,
    text: "チームで成果物を発表するとき、あなたは？",
    options: [
      { text: "発表の進行役やリーダーを務める",
        scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 5 } },
      { text: "工夫した技術的ポイントやこだわりを語る",
        scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 5, take_ownership: 0 } },
      { text: "失敗も含めて正直に話す",
        scores: { be_open: 5, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 0 } },
      { text: "短時間でも形にして発表を優先する",
        scores: { be_open: 0, move_fast: 5, give_first: 0, geek_out: 0, take_ownership: 0 } },
      { text: "他チームの成果にもコメントや拍手を送る",
        scores: { be_open: 0, move_fast: 0, give_first: 5, geek_out: 0, take_ownership: 0 } }
    ]
  },
  {
    id: 5,
    text: "アルバイトでトラブルが発生! あなたの行動は？",
    options: [
      { text: "みんなを集めて対応を指示する",
        scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 5 } },
      { text: "原因を突き止めるためにデータを調べる",
        scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 5, take_ownership: 0 } },
      { text: "状況や影響をすぐに共有する",
        scores: { be_open: 5, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 0 } },
      { text: "当事者を責めずフォローする",
        scores: { be_open: 0, move_fast: 0, give_first: 5, geek_out: 0, take_ownership: 0 } },
      { text: "まずは応急処置で被害を止める",
        scores: { be_open: 0, move_fast: 5, give_first: 0, geek_out: 0, take_ownership: 0 } }
    ]
  },
  {
    id: 6,
    text: "SNSで発信するときに意識するのは？",
    options: [
      { text: "失敗や学びなど自分のことをオープンに発信",
        scores: { be_open: 5, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 0 } },
      { text: "気になる技術やアプリをすぐに試してレビュー投稿",
        scores: { be_open: 0, move_fast: 5, give_first: 0, geek_out: 0, take_ownership: 0 } },
      { text: "技術記事やツールの紹介を投稿",
        scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 5, take_ownership: 0 } },
      { text: "他の人の投稿にコメントやいいねをする",
        scores: { be_open: 0, move_fast: 0, give_first: 5, geek_out: 0, take_ownership: 0 } },
      { text: "イベントを募ったり、人を巻き込む",
        scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 5 } }
    ]
  },
  {
    id: 7,
    text: "新しい技術を学ぶことに！あなたはどうする？",
    options: [
      { text: "詳しい人に教えてもらえるように勉強会を企画する",
        scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 5 } },
      { text: "その技術の仕組みや原理を徹底的に調べる",
        scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 5, take_ownership: 0 } },
      { text: "まずは自分の手でチュートリアルを動かしてみる",
        scores: { be_open: 0, move_fast: 5, give_first: 0, geek_out: 0, take_ownership: 0 } },
      { text: "分からないことがあれば使っている人に相談する",
        scores: { be_open: 5, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 0 } },
      { text: "使い方をまとめて技術記事にする",
        scores: { be_open: 0, move_fast: 0, give_first: 5, geek_out: 0, take_ownership: 0 } }
    ]
  },
  {
    id: 8,
    text: "勉強会に参加したときのあなたは？",
    options: [
      { text: "質問や回答を深堀りして議論を盛り上げる",
        scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 5, take_ownership: 0 } },
      { text: "会の進行やまとめ役を買って出る",
        scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 5 } },
      { text: "質問や不安をオープンにする",
        scores: { be_open: 5, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 0 } },
      { text: "他の人の質問にも答えてあげる",
        scores: { be_open: 0, move_fast: 0, give_first: 5, geek_out: 0, take_ownership: 0 } },
      { text: "学んだことをすぐに試してみる",
        scores: { be_open: 0, move_fast: 5, give_first: 0, geek_out: 0, take_ownership: 0 } }
    ]
  },
  {
    id: 9,
    text: "友達の誕生日サプライズであなたがすることは？",
    options: [
      { text: "ばれないように友達の好きなものをリサーチする",
        scores: { be_open: 0, move_fast: 0, give_first: 5, geek_out: 0, take_ownership: 0 } },
      { text: "その友達が喜びそうなサプライズ案を考える",
        scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 5, take_ownership: 0 } },
      { text: "サプライズの計画を立てて実行に移す",
        scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 5 } },
      { text: "みんなにこっそり計画を共有して協力を募る",
        scores: { be_open: 5, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 0 } },
      { text: "場所や時間をすぐに決めて準備を始める",
        scores: { be_open: 0, move_fast: 5, give_first: 0, geek_out: 0, take_ownership: 0 } }
    ]
  },
  {
    id: 10,
    text: "将来エンジニアとして働く自分を想像したら？",
    options: [
      { text: "プロジェクトを引っ張るリーダー",
        scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 5 } },
      { text: "技術が好きでずっと学び続ける人",
        scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 5, take_ownership: 0 } },
      { text: "周りを助けて感謝される人",
        scores: { be_open: 0, move_fast: 0, give_first: 5, geek_out: 0, take_ownership: 0 } },
      { text: "わからないことを率直に質問できる人",
        scores: { be_open: 5, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 0 } },
      { text: "プロトタイプをすぐ作って試す人",
        scores: { be_open: 0, move_fast: 5, give_first: 0, geek_out: 0, take_ownership: 0 } }
    ]
  }
].freeze

  # 動物キャラクター設定
  ANIMAL_CREDO_MAPPING = {
    gorilla: {
      primary_credo: "take_ownership",
      name: "ごりら",
      emoji: "🦍",
      color: "bg-red-400",
      title: "俺に任せろ！みんなのリーダー!",
      description: "責任感を持ち、最後までやり切るリーダー。課題の優先度とリスクを整理し、迷いなく前に進めるあなたはごりらタイプです！",
      image: "results/detail/take_ownership-600.png",
      characteristics: [
        "目的と成果に強くコミットする",
        "問題を自分ごととして引き受ける",
        "必要な意思決定を率先して行う",
        "リスクと優先順位を整理して推進する"
      ],
      advice: "強い当事者意識でチームを前に進める推進役になれます。責任範囲を明確にし、成果に直結する行動に集中しましょう。"
    },
    frog: {
      primary_credo: "be_open",
      name: "かえる",
      emoji: "🐸",
      title: "素直で柔軟！オープン＆ポジティブ！",
      description: "自分の課題や失敗も率直に共有し、アドバイスを受け入れて前向きに改善につなげられる。変化を恐れず柔軟に学び、成長するあなたはかえるタイプです！",
      image: "results/detail/be_open-600.png",
      characteristics: [
        "自分の課題やできていないことを素直に認める",
        "アドバイスを歓迎し、すぐに行動に移す",
        "失敗も学びとして共有し、改善の工夫を試みる",
        "変化を成長のチャンスと捉えて柔軟に受け入れる"
      ],
      advice: "素直に学ぶ姿勢は成長の加速装置です。アドバイスを前向きに取り入れて行動することで、信頼が深まり、チームでの活躍の場も広がっていきます。"
    },
    penguin: {
      primary_credo: "move_fast",
      name: "ぺんぎん",
      emoji: "🐧",
      title: "素早く飛び込め！ファーストぺんぎん！",
      description: "素早く動き、短いサイクルで学びを得て改善を続けられる。失敗を恐れず一歩を踏み出し、学びを得られるあなたはぺんぎんタイプです！",
      image: "results/detail/move_fast-600.png",
      characteristics: [
        "MVPで素早くリリースして検証する",
        "タスクを分割し高頻度にデプロイする",
        "迷ったら実験と計測で確かめる",
        "完璧主義よりも学習速度を優先する"
      ],
      advice: "素早く動くことで学びの機会が増えます。小さな成功体験を積み重ねて自信をつけ、チームのムーブメントメーカーになりましょう。"
    },
    crab: {
      primary_credo: "give_first",
      name: "かに",
      emoji: "🦀",
      title: "誰かのために強くなれる！仲間思いのサポーター！",
      description: "誰かのために動くことで、自身の成長にもつなげるタイプ。知識共有を欠かさないあなたはかにタイプ。",
      image: "results/detail/give_first-600.png",
      characteristics: [
        "ノウハウを文書化して公開する",
        "レビューやメンタリングを積極的に行う",
        "困っている人を最優先でサポートする",
        "コミュニティやチームに継続的に貢献する"
      ],
      advice: "与える行動が長期的な信頼と機会を生みます。仕組み化（テンプレ・ガイド）で価値提供をスケールさせましょう。"
    },
    fox: {
      primary_credo: "geek_out",
      name: "きつね",
      emoji: "🦊",
      title: "エンジニアの探求者！技術を深く楽しむ！",
      description: "技術を深く掘り下げ、検証と計測で本質をつかむタイプ。新しい概念やツールを試し、知の探索を楽しむ。",
      image: "results/detail/geek_out-600.png",
      characteristics: [
        "仕組みや原理を徹底的に理解する",
        "計測・検証で根拠を示すのが得意",
        "新しいツールや手法を率先して試す",
        "ハック精神と遊び心を持って学ぶ"
      ],
      advice: "深い知識と洞察で技術の羅針盤になれます。学びを翻訳してチームに還元し、意思決定の質を底上げしましょう。"
    }
  }.freeze

  # ビジネスロジックメソッド集
  def current_question
    return nil if completed?
    QUESTIONS[current_question_index]
  end

  def current_question_number = current_question_index + 1

  def current_question_index  = (answers || []).length

  def completed?              = current_question_index >= TOTAL_QUESTIONS

  # 回答を1つ進める。完了したら結果を確定保存
  def process_answer(answer_value)
    return false if completed? || answer_value.blank?

    idx = answer_value.to_i
    q   = QUESTIONS[current_question_index]
    return false unless q && idx.between?(0, q[:options].length - 1)

    updated = (answers || []).dup
    updated << idx
    self.answers = updated

    if completed?
      finalize_result!  # ここで result_animal_type と completed_at を保存
    else
      save!
    end
    true
  end

  # 計算だけしたいとき（保存はしない）
  def computed_result_animal_type
    return nil unless completed?
    credo_totals = aggregate_credo_scores
    top_credo = pick_top_credo(credo_totals)&.to_s
    return nil unless top_credo

    # credo -> animal の逆引き
    credo_to_animal = ANIMAL_CREDO_MAPPING.map { |animal, h| [ h[:primary_credo], animal.to_s ] }.to_h
    credo_to_animal[top_credo]
  end

  def pick_top_credo(credo_totals)
    return nil if credo_totals.blank?

    max   = credo_totals.values.max
    ties  = credo_totals.select { |_k, v| v == max }.keys
    return ties.first if ties.size == 1

    rng = deterministic_rng("#{session_token}-tiebreak")
    ties.sample(random: rng)
  end

  private

  # 結果を確定して保存
  def finalize_result!
    self.completed_at       ||= Time.current
    self.result_animal_type ||= computed_result_animal_type
    save!
  end

  def generate_session_token = self.session_token = SecureRandom.hex(16)

  def initialize_progress    = self.answers ||= []

  def set_expiration         = self.expires_at ||= 1.hour.from_now

  # CREDOごとの点数を集計
  def aggregate_credo_scores
    # 点数の初期化
    totals = CREDO_KEYS.index_with { 0 }
    # 回答集計、各質問の選択肢に応じた点数を加算
    (answers || []).each_with_index do |option_index, q_idx|
      q = QUESTIONS[q_idx]
      next unless q && q[:options][option_index]

      q[:options][option_index][:scores].each do |k, v|
        totals[k.to_s] = (totals[k.to_s] || 0) + v.to_i
      end
    end
    totals
  end

  def answers_must_be_array_within_range
    return if answers.nil?
    unless answers.is_a?(Array)
      errors.add(:answers, "must be an array")
      return
    end
    if answers.length > TOTAL_QUESTIONS
      errors.add(:answers, "too many answers")
    end

    answers.each_with_index do |idx, i|
      q = QUESTIONS[i]
      unless q && idx.is_a?(Integer) && idx.between?(0, q[:options].length - 1)
        errors.add(:answers, "invalid option index at Q#{i + 1}")
      end
    end
  end

  # セッション内で再現可能な乱数生成器
  def deterministic_rng(seed_str)
    int_seed = Digest::MD5.hexdigest(seed_str).to_i(16) % 2**31
    Random.new(int_seed)
  end
end
