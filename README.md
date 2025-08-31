# 🐾 あにまるCREDO

10問の質問に答えることで、あなたの **エンジニアマインドの強み** を診断する Web アプリです。  
診断結果は動物キャラクター（ゴリラ / カニ / ペンギン / キツネ / カエル）で表現され、それぞれの CREDO（価値観）に対応しています。  

---

## 🚀 特徴

- **10問の設問**に直感で回答するだけ
- **CREDOスコア**を自動集計し、あなたに合った動物タイプを診断
- **診断結果ページ**では：
  - 動物のイラスト
  - 特徴（characteristics）
  - アドバイス（advice）
  - CREDOのレーダーチャート（五角形グラフ）  
  を表示
- **Twitter シェア機能**付き  
  診断結果ごとに OGP 画像が切り替わり、リンクカードとして動物イラストが表示されます  

---

## 🛠️ 技術スタック

- **フレームワーク**: Ruby on Rails 7
- **言語**: Ruby 3.3.6
- **データベース**: PostgreSQL
- **フロントエンド**: Tailwind CSS
- **認証**: なし（匿名診断）
- **Docker 対応**: `docker compose up` で環境を構築可能

---

## 📂 ディレクトリ構成（抜粋）

```
app/
  models/
    diagnosis_session.rb   # 診断セッションのモデル・集計ロジック
  controllers/
    diagnosis_sessions_controller.rb
  views/
    diagnosis_sessions/    # new, show, result のビュー
    layouts/application.html.erb
app/assets/
  images/
    title.png
    header.png
    logo-white.png
    results/detail/*.png   # 動物ごとの診断画像
```

---

## ⚙️ セットアップ手順

```bash
# リポジトリを clone
git clone https://github.com/yourname/animal-credo.git
cd animal-credo

# Dockerで起動
docker compose up --build
```

起動後にブラウザで  
👉 http://localhost:3000 を開いてください。

---

## 🌐 OGP/Twitter シェアの設定

開発環境で OGP を確認するには [ngrok](https://ngrok.com/) を利用します。

```bash
ngrok http --host-header=rewrite http://localhost:3000
```

- `config/environments/development.rb` に ngrok ドメインを追加  
- meta タグに `twitter:card`, `twitter:title`, `twitter:description`, `twitter:image` を出力済み  
- Tweet Composer で ngrok URL を貼れば診断結果ごとにカード画像が変わります  
