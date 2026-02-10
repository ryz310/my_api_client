# 開発とリリース

## ローカル開発

```sh
bin/setup
rake spec
bin/console
```

## ローカルインストール

```sh
bundle exec rake install
```

## リリース

```sh
bundle exec rake release
```

タグ作成、push、RubyGems への公開までを実行します。
