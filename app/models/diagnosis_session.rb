class DiagnosisSession < ApplicationRecord
  ANIMAL_TYPES = %w[gorilla crab fox frog penguin].freeze
  CREDO_KEYS = %w[be_open move_fast give_first geek_out take_ownership].freeze
  # 定数定義
  TOTAL_QUESTIONS = 10

  validates :session_token, presence: true, uniqueness: true, length: { is: 32 }
  validates :expires_at, presence: true
  validates :result_animal_type, inclusion: { in: ANIMAL_TYPES, allow_blank: true }
  validate  :answers_must_be_array_within_range

# === 質問（10問） ===
# 各選択肢は対応CREDOに5点を付与（他は0）でシンプルに判定します。
QUESTIONS = [
  {
    id: 1,
    text: "チームでの情報共有、まず何をする？",
    options: [
      { text: "判断の背景や懸念を率直に公開する",               scores: { be_open: 5, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 0 } },
      { text: "タスクを切ってすぐ動き、途中で共有する",           scores: { be_open: 0, move_fast: 5, give_first: 0, geek_out: 0, take_ownership: 0 } },
      { text: "自分の知見をノート化し、全員が使える形で配る",     scores: { be_open: 0, move_fast: 0, give_first: 5, geek_out: 0, take_ownership: 0 } },
      { text: "技術的根拠を徹底調査してから共有する",             scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 5, take_ownership: 0 } },
      { text: "責任者としてリスク/スケジュールを明確化し主導",     scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 5 } }
    ]
  },
  {
    id: 2,
    text: "障害対応で最初に取る行動は？",
    options: [
      { text: "現状と方針を全員に即共有し、透明性を担保",         scores: { be_open: 5, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 0 } },
      { text: "暫定回避策を即時に適用し被害拡大を止める",         scores: { be_open: 0, move_fast: 5, give_first: 0, geek_out: 0, take_ownership: 0 } },
      { text: "ユーザー連絡やFAQ整備など支援を先に行う",           scores: { be_open: 0, move_fast: 0, give_first: 5, geek_out: 0, take_ownership: 0 } },
      { text: "原因を深掘り・再現性確認・恒久対応案を詰める",       scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 5, take_ownership: 0 } },
      { text: "オーナーとして役割分担と意思決定を引き受ける",       scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 5 } }
    ]
  },
  {
    id: 3,
    text: "仕様変更の連絡が遅れて入った。あなたは？",
    options: [
      { text: "前提や影響をオープンにし、議論の場を作る",         scores: { be_open: 5, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 0 } },
      { text: "影響の少ない所からすぐ修正に取り掛かる",           scores: { be_open: 0, move_fast: 5, give_first: 0, geek_out: 0, take_ownership: 0 } },
      { text: "関係者向けの手順・テンプレを配って支援する",         scores: { be_open: 0, move_fast: 0, give_first: 5, geek_out: 0, take_ownership: 0 } },
      { text: "差分の技術的妥当性を検証して最適解を探る",           scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 5, take_ownership: 0 } },
      { text: "責任を持って優先順位・スケジュールを再定義する",     scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 5 } }
    ]
  },
  {
    id: 4,
    text: "コードレビューで一番重視することは？",
    options: [
      { text: "指摘の意図を丁寧に言語化し、対話を促す",           scores: { be_open: 5, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 0 } },
      { text: "小さく頻繁に出して回転を上げる",                   scores: { be_open: 0, move_fast: 5, give_first: 0, geek_out: 0, take_ownership: 0 } },
      { text: "Tipsやサンプルコードを添えて相手の生産性を上げる",   scores: { be_open: 0, move_fast: 0, give_first: 5, geek_out: 0, take_ownership: 0 } },
      { text: "根拠のある設計議論・計測結果に基づく指摘",           scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 5, take_ownership: 0 } },
      { text: "品質・納期の責任を担い、必要なら方針を決める",       scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 5 } }
    ]
  },
  {
    id: 5,
    text: "学習や知見共有、どう進める？",
    options: [
      { text: "学びの過程・失敗も含めて公開し続ける",             scores: { be_open: 5, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 0 } },
      { text: "必要最低限を素早くキャッチアップして実装",         scores: { be_open: 0, move_fast: 5, give_first: 0, geek_out: 0, take_ownership: 0 } },
      { text: "社内勉強会や資料を作り、まず与える",               scores: { be_open: 0, move_fast: 0, give_first: 5, geek_out: 0, take_ownership: 0 } },
      { text: "原理・仕組みを掘り下げて深く理解する",               scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 5, take_ownership: 0 } },
      { text: "目標を自分ごと化し、結果に責任を持つ",               scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 5 } }
    ]
  },
  {
    id: 6,
    text: "リリース直前に軽微な改善アイデアが浮かんだ。",
    options: [
      { text: "影響や判断理由を公開して合意を取りに行く",           scores: { be_open: 5, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 0 } },
      { text: "安全にローリスクで入れられる範囲だけ即対応",         scores: { be_open: 0, move_fast: 5, give_first: 0, geek_out: 0, take_ownership: 0 } },
      { text: "ユーザー価値が高いなら他タスクを巻き取って支援",     scores: { be_open: 0, move_fast: 0, give_first: 5, geek_out: 0, take_ownership: 0 } },
      { text: "計測して効果を検証し、次のサイクルに回す提案",       scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 5, take_ownership: 0 } },
      { text: "スコープ管理者として品質・納期を優先して判断",       scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 5 } }
    ]
  },
  {
    id: 7,
    text: "朝会で昨日できなかったことがあった。",
    options: [
      { text: "ブロッカーや背景を率直に共有し助けを仰ぐ",         scores: { be_open: 5, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 0 } },
      { text: "今日やる最小タスクに素早く切り替える",             scores: { be_open: 0, move_fast: 5, give_first: 0, geek_out: 0, take_ownership: 0 } },
      { text: "他の人の進捗を助ける行動を先にする",                 scores: { be_open: 0, move_fast: 0, give_first: 5, geek_out: 0, take_ownership: 0 } },
      { text: "詰まった箇所を技術的に深掘りして解法を共有",         scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 5, take_ownership: 0 } },
      { text: "自分のコミットメントを見直し、責任を明確化",         scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 5 } }
    ]
  },
  {
    id: 8,
    text: "ユーザーから改善要望が多数。どう反応する？",
    options: [
      { text: "ロードマップと優先度を公開し透明性を上げる",         scores: { be_open: 5, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 0 } },
      { text: "小さな改善から素早く出してフィードバック回収",       scores: { be_open: 0, move_fast: 5, give_first: 0, geek_out: 0, take_ownership: 0 } },
      { text: "まずはヘルプやテンプレでユーザー支援を手厚く",       scores: { be_open: 0, move_fast: 0, give_first: 5, geek_out: 0, take_ownership: 0 } },
      { text: "計測基盤を整備し、効果検証の仕組みを作る",           scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 5, take_ownership: 0 } },
      { text: "責任者としてKPI/デッドラインを設定して推進",         scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 5 } }
    ]
  },
  {
    id: 9,
    text: "社内勉強会のテーマを選ぶなら？",
    options: [
      { text: "組織の課題や学びをオープンに話せるテーマ",           scores: { be_open: 5, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 0 } },
      { text: "短時間で成果に直結するハンズオン",                   scores: { be_open: 0, move_fast: 5, give_first: 0, geek_out: 0, take_ownership: 0 } },
      { text: "社内に還元できるベストプラクティス共有",             scores: { be_open: 0, move_fast: 0, give_first: 5, geek_out: 0, take_ownership: 0 } },
      { text: "低レイヤや内部実装を徹底的に解説する深掘り会",       scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 5, take_ownership: 0 } },
      { text: "成果の責任を持つプロジェクト運営ノウハウ",           scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 5 } }
    ]
  },
  {
    id: 10,
    text: "大きな失敗をした後、最初にやることは？",
    options: [
      { text: "原因・判断・学びを包み隠さず共有する",               scores: { be_open: 5, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 0 } },
      { text: "すぐに復旧・再発防止の短期対策を回す",               scores: { be_open: 0, move_fast: 5, give_first: 0, geek_out: 0, take_ownership: 0 } },
      { text: "関係者へのサポートやお詫び対応を最優先する",         scores: { be_open: 0, move_fast: 0, give_first: 5, geek_out: 0, take_ownership: 0 } },
      { text: "技術的なポストモーテムを書き、知見を残す",           scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 5, take_ownership: 0 } },
      { text: "オーナーとして責任を引き受け、仕組みを改める",       scores: { be_open: 0, move_fast: 0, give_first: 0, geek_out: 0, take_ownership: 5 } }
    ]
  }
].freeze

  # 動物キャラクター設定
  ANIMAL_CREDO_MAPPING = {
    gorilla: {
      primary_credo: 'take_ownership',
      name: 'ゴリラ',
      emoji: '🦍',
      title: 'オーナーシップ全開！責任感ゴリラ',
      description: '物事を自分ごと化し、最後までやり切るリーダータイプ。課題の優先度とリスクを整理し、迷いなく前に進める。',
      characteristics: [
        '目的と成果に強くコミットする',
        '問題を自分ごととして引き受ける',
        '必要な意思決定を率先して行う',
        'リスクと優先順位を整理して推進する'
      ],
      advice: '強い当事者意識でチームを前に進める推進役になれます。責任範囲を明確にし、成果に直結する行動に集中しましょう。'
    },
    frog: {
      primary_credo: 'be_open',
      name: 'カエル',
      emoji: '🐸',
      title: 'まっすぐオープン！透明性カエル',
      description: '情報・判断の背景・学びを率直に共有し、心理的安全性を高めるタイプ。対話を通じて合意形成を進める。',
      characteristics: [
        '判断の背景や懸念をオープンに共有する',
        '失敗も学びとして率直に話す',
        'フィードバックを歓迎し双方向の対話を促す',
        '透明性で信頼と連帯感を育てる'
      ],
      advice: 'オープンな姿勢がチームの信頼と学習を加速させます。情報の非対称を減らし、意思決定を軽くしていきましょう。'
    },
    penguin: {
      primary_credo: 'move_fast',
      name: 'ペンギン',
      emoji: '🐧',
      title: '素早くスイスイ！ムーブファストペンギン',
      description: '小さく作って早く出し、検証サイクルを回すタイプ。完璧よりも学びの速度を重視して前進する。',
      characteristics: [
        'MVPで素早くリリースして検証する',
        'タスクを分割し高頻度にデプロイする',
        '迷ったら実験と計測で確かめる',
        '完璧主義よりも学習速度を優先する'
      ],
      advice: '短いサイクルで仮説検証を回せます。品質は自動化と計測で担保しつつ、価値の届け方を高速に最適化しましょう。'
    },
    crab: {
      primary_credo: 'give_first',
      name: 'カニ',
      emoji: '🦀',
      title: 'まず与える！ギブファーストカニ',
      description: '先に与える姿勢で周囲の成功確率を高め、自身の成長にもつなげるタイプ。ナレッジ共有と支援を惜しまない。',
      characteristics: [
        'ノウハウを文書化して公開する',
        'レビューやメンタリングを積極的に行う',
        '困っている人を最優先でサポートする',
        'コミュニティやチームに継続的に貢献する'
      ],
      advice: '与える行動が長期的な信頼と機会を生みます。仕組み化（テンプレ・ガイド）で価値提供をスケールさせましょう。'
    },
    fox: {
      primary_credo: 'geek_out',
      name: 'キツネ',
      emoji: '🦊',
      title: '没頭の賢者！ギークアウトキツネ',
      description: '技術を深く掘り下げ、検証と計測で本質をつかむタイプ。新しい概念やツールを試し、知の探索を楽しむ。',
      characteristics: [
        '仕組みや原理を徹底的に理解する',
        '計測・検証で根拠を示すのが得意',
        '新しいツールや手法を率先して試す',
        'ハック精神と遊び心を持って学ぶ'
      ],
      advice: '深い知識と洞察で技術の羅針盤になれます。学びを翻訳してチームに還元し、意思決定の質を底上げしましょう。'
    }
  }.freeze

  # コールバック
  before_create :generate_session_token
  before_create :initialize_progress
  before_create :set_expiration

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
    top_credo = credo_totals.max_by { |(k, v)| v }&.first&.to_s
    return nil unless top_credo

    # credo -> animal の逆引き
    credo_to_animal = ANIMAL_CREDO_MAPPING.map { |animal, h| [h[:primary_credo], animal.to_s] }.to_h
    credo_to_animal[top_credo]
  end

  private
  
  def finalize_result!
    self.completed_at       ||= Time.current
    self.result_animal_type ||= computed_result_animal_type
    save!
  end

  def generate_session_token = self.session_token = SecureRandom.hex(16)
  
  def initialize_progress    = self.answers ||= []

  def set_expiration         = self.expires_at ||= 1.hour.from_now
  
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
      errors.add(:answers, 'must be an array')
      return
    end
    if answers.length > TOTAL_QUESTIONS
      errors.add(:answers, 'too many answers')
    end

    answers.each_with_index do |idx, i|
      q = QUESTIONS[i]
      unless q && idx.is_a?(Integer) && idx.between?(0, q[:options].length - 1)
        errors.add(:answers, "invalid option index at Q#{i + 1}")
      end
    end
  end
end
