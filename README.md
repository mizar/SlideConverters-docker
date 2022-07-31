# Dockerfile for VRC-LT PDF Convert 

[VRC-LT](https://vrc-lt.org/)会システム向けのスライドpdf→mp4動画変換用Dockerfileです。

スライド1ページあたり、2秒間の静止画像としてmp4動画への変換を行います。

## Usage

- pdfファイルをmp4に変換
    - `${fileDirname}` : ファイルの存在するディレクトリ名に置き換える
    - `${fileBasenameNoExtension}` : （拡張子無しの）ファイル名に置き換える

```
docker run -t --rm -v ${fileDirname}:/opt/work mizarjp/vrclt-pdfconv pdf2vrclt ${fileBasenameNoExtension}
```

- カレントディレクトリの全てのpdfをmp4に変換
    - `${PWD}` : カレントディレクトリ名に置き換える

```
docker run -t --rm -v ${PWD}:/opt/work mizarjp/vrclt-pdfconv allpdf2vrclt
```
