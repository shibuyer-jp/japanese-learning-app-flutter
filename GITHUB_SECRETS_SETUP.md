# GitHub Secrets セットアップガイド

T-08 完全自動化を実現するため、GitHub リポジトリに Secrets を設定してください。

## 🔐 設定手順

1. GitHub リポジトリにアクセス
2. **Settings** → **Secrets and variables** → **Actions**
3. **New repository secret** をクリック
4. 以下の Secrets を追加（値は環境に応じて入力）

---

## 📋 必須 Secrets

### 1. Supabase 認証情報

**Name**: `SUPABASE_URL`  
**Value**: `https://your-project.supabase.co`  
取得元: https://app.supabase.com → Project Settings → API

**Name**: `SUPABASE_ANON_KEY`  
**Value**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`  
取得元: https://app.supabase.com → Project Settings → API

---

## 📋 iOS 配布用 Secrets（TestFlight）

### 2. Apple ID 認証情報

**Name**: `FASTLANE_USER`  
**Value**: `your-apple-id@example.com`  
Apple ID メールアドレス

**Name**: `FASTLANE_PASSWORD`  
**Value**: `abcd-efgh-ijkl-mnop`  
App-specific password（Apple ID で生成）
取得元: https://appleid.apple.com/account/security

### 3. Code Signing 認証情報

**Name**: `MATCH_PASSWORD`  
**Value**: `your-secure-password`  
Fastlane Match 用パスワード（任意の複雑なパスワード）

**Name**: `MATCH_GIT_TOKEN`  
**Value**: `ghp_xxxxxxxxxxxx`  
GitHub Personal Access Token（private リポジトリアクセス用）

---

## 📋 Android 配布用 Secrets（Firebase App Distribution）

### 4. Android キーストア

**Name**: `ANDROID_KEYSTORE`  
**Value**: `base64 エンコードされたキーストア`  
生成方法:
```bash
# キーストア生成（未実施の場合）
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Base64 エンコード（GitHub Secrets に貼り付け）
base64 -i upload-keystore.jks
```

**Name**: `KEYSTORE_PASSWORD`  
**Value**: `your-keystore-password`  
キーストア生成時に設定したパスワード

**Name**: `KEY_PASSWORD`  
**Value**: `your-key-password`  
キー生成時に設定したパスワード

### 5. Firebase 認証情報

**Name**: `FIREBASE_APP_ID`  
**Value**: `1:123456789:android:abcdef1234567890`  
取得元: https://console.firebase.google.com → Project Settings

**Name**: `FIREBASE_SERVICE_ACCOUNT`  
**Value**: `base64 エンコードされた JSON`  
生成方法:
```bash
# Firebase Console → Project Settings → Service Accounts → Generate key
# 生成された JSON ファイルを Base64 エンコード
base64 -i google-services.json
```

---

## ✅ チェックリスト

- [ ] SUPABASE_URL を設定
- [ ] SUPABASE_ANON_KEY を設定
- [ ] FASTLANE_USER を設定（iOS）
- [ ] FASTLANE_PASSWORD を設定（iOS）
- [ ] MATCH_PASSWORD を設定（iOS）
- [ ] MATCH_GIT_TOKEN を設定（iOS）
- [ ] ANDROID_KEYSTORE を設定（Android）
- [ ] KEYSTORE_PASSWORD を設定（Android）
- [ ] KEY_PASSWORD を設定（Android）
- [ ] FIREBASE_APP_ID を設定（Android）
- [ ] FIREBASE_SERVICE_ACCOUNT を設定（Android）

---

## 🚀 設定後

すべての Secrets を設定したら：

1. `main` ブランチに新しい commit をプッシュ
2. GitHub Actions → Workflows で自動ビルド確認
3. ビルド成功 → TestFlight/Firebase App Distribution に自動配布

ユーザーはテスト配布リンクをクリックして確認テストのみ！

