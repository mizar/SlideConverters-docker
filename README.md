# SlideConverters for VRC-LT/UnaSlides 

[VRC-LT](https://vrc-lt.org/)会システム/[UnaSlides](https://booth.pm/ja/items/4141632) 向けのスライドpdf→mp4動画変換用Dockerfileです。

- [VRC-LT](https://vrc-lt.org/)会システム向けには スライド1ページあたり、2秒間の静止画像として動画への変換を行います。
- [UnaSlides](https://booth.pm/ja/items/4141632)向けには スライド1ページあたり、1秒間の静止画像として動画への変換を行います。

## Usage

- dockerイメージの更新・ダウンロード

```
docker pull mizarjp/slideconverters:latest
docker pull mizarjp/slideconverters:extfonts
```

- pdfファイルをmp4に変換
    - `${fileDirname}` : ファイルの存在するディレクトリ名に置き換える
    - `${fileBasenameNoExtension}` : （拡張子無しの）ファイル名に置き換える

```
docker run -t --rm -v ${fileDirname}:/opt/work -w /opt/work mizarjp/slideconverters:latest pdf2vrclt ${fileBasenameNoExtension}
docker run -t --rm -v ${fileDirname}:/opt/work -w /opt/work mizarjp/slideconverters:extfonts pdf2vrclt ${fileBasenameNoExtension}
docker run -t --rm -v ${fileDirname}:/opt/work -w /opt/work mizarjp/slideconverters:latest pdf2unaslides ${fileBasenameNoExtension}
docker run -t --rm -v ${fileDirname}:/opt/work -w /opt/work mizarjp/slideconverters:extfonts pdf2unaslides ${fileBasenameNoExtension}
```

`:extfonts` イメージはpdfファイルに埋め込みされていないフォントグリフを補完するためのフォントファイルを幾つか追加しています。

- カレントディレクトリの全てのpdfをmp4に変換
    - `${PWD}` : カレントディレクトリ名に置き換える

```
docker run -t --rm -v ${PWD}:/opt/work mizarjp/slideconverters:latest allpdf2vrclt
docker run -t --rm -v ${PWD}:/opt/work mizarjp/slideconverters:extfonts allpdf2vrclt
docker run -t --rm -v ${PWD}:/opt/work mizarjp/slideconverters:latest allpdf2unaslides
docker run -t --rm -v ${PWD}:/opt/work mizarjp/slideconverters:extfonts allpdf2unaslides
```
