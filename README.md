# Dockerfile for VRC-LT PDF Convert 

[VRC-LT](https://vrc-lt.org/)会システム向けのスライドpdf→mp4動画変換用Dockerfileです。

スライド1ページあたり、2秒間の静止画像としてmp4動画への変換を行います。

## Usage

- dockerイメージの更新・ダウンロード

```
docker pull mizarjp/vrclt-pdfconv:latest
docker pull mizarjp/vrclt-pdfconv:extfonts
```

- pdfファイルをmp4に変換
    - `${fileDirname}` : ファイルの存在するディレクトリ名に置き換える
    - `${fileBasenameNoExtension}` : （拡張子無しの）ファイル名に置き換える

```
docker run -t --rm -v ${fileDirname}:/opt/work mizarjp/vrclt-pdfconv:latest pdf2vrclt ${fileBasenameNoExtension}
docker run -t --rm -v ${fileDirname}:/opt/work mizarjp/vrclt-pdfconv:extfonts pdf2vrclt ${fileBasenameNoExtension}
```

`:extfonts` イメージはpdfファイルに埋め込みされていないフォントグリフを補完するためのフォントファイルを幾つか追加しています。

- カレントディレクトリの全てのpdfをmp4に変換
    - `${PWD}` : カレントディレクトリ名に置き換える

```
docker run -t --rm -v ${PWD}:/opt/work mizarjp/vrclt-pdfconv:latest allpdf2vrclt
docker run -t --rm -v ${PWD}:/opt/work mizarjp/vrclt-pdfconv:extfonts allpdf2vrclt
```
