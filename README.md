# DebugShaders

Unity でメッシュやテクスチャのデバッグに使用する小さなシェーダー集です。

## セットアップ

### Git サブモジュールとして追加

Unity プロジェクトのルートで次のコマンドを実行します。

```bash
git submodule add https://github.com/HarukaKajita/DebugShaders.git Packages/DebugShaders
git submodule update --init --recursive
```

クローン後、`Packages/DebugShaders` 以下に配置されたパッケージを Unity が自動認識します。

### パッケージ URL から追加

`Packages/manifest.json` に直接記述して参照することもできます。

```json
{
  "dependencies": {
    "com.harukakajita.debugshaders": "https://github.com/HarukaKajita/DebugShaders.git?path=Assets/DebugShaders"
  }
}
```

この URL は Unity の **Add package from git URL** に入力することも可能です。
Package Managerから`https://github.com/HarukaKajita/DebugShaders.git?path=Assets/DebugShaders`を追加することでもインポートできます。

## 同梱シェーダー

- **Unlit/BoneIndexWeight**: スキニングのブレンドインデックスを色として表示します。
- **Debug/Position**: 頂点位置を可視化します。整数部を無視し小数部のみを使用するオプションもあります。
- **Debug/Normal**: 法線をオブジェクト空間またはワールド空間で表示し、圧縮や Half‑Lambert シェーディングの有無を選択できます。
- **Debug/UVColor**: 選択した UV 座標を RGB 値として出力します。
- **Debug/VertexColor**: 頂点カラーの各成分を個別にオン / オフできます。

これらのシェーダーはマテリアルの `Debug` カテゴリから選択してください。

## ライセンス

本リポジトリにはライセンスファイルが含まれていません。利用に関しては作者へお問い合わせください。
