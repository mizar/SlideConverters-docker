FROM alpine:3.16.2 AS builder-base

FROM builder-base as builder-poppler

# * popplerビルド
# `apk add --no-cache poppler-utils` としても実行できるが、依存ライブラリを含めたファイルサイズが大きくなるため、
# 最終的なイメージの容量節約のために自前の static ビルドを行う

RUN apk add --no-cache \
alpine-sdk cmake \
brotli-dev bzip2-dev expat-dev fontconfig-dev freetype-dev lcms2-dev libjpeg-turbo-dev libpng-dev libwebp-dev openjpeg-dev tiff-dev zlib-dev zstd-dev \
brotli-static bzip2-static expat-static fontconfig-static freetype-static libjpeg-turbo-static libpng-static libwebp-static zlib-static zstd-static

RUN git clone --depth 1 https://anongit.freedesktop.org/git/poppler/poppler.git ~/poppler

RUN \
mkdir -p ~/poppler/build && \
cd ~/poppler/build && \
git clean -dfx && \
cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DENABLE_BOOST=OFF .. && \
# cmakeの段階でもっとスマートな依存ライブラリの指定方法は有りそうだが…
echo "/usr/bin/c++ -Wall -Wextra -Wpedantic -Wno-unused-parameter -Wcast-align -Wformat-security -Wframe-larger-than=65536 -Wlogical-op -Wmissing-format-attribute -Wnon-virtual-dtor -Woverloaded-virtual -Wmissing-declarations -Wundef -Wzero-as-null-pointer-constant -Wshadow -Wsuggest-override -fno-exceptions -fno-check-new -fno-common -fno-operator-names -D_DEFAULT_SOURCE -O2 -DNDEBUG -static -static-libgcc -static-libstdc++ -Wl,--as-needed -Wl,-s CMakeFiles/pdftoppm.dir/parseargs.cc.o CMakeFiles/pdftoppm.dir/Win32Console.cc.o CMakeFiles/pdftoppm.dir/pdftoppm.cc.o CMakeFiles/pdftoppm.dir/sanitychecks.cc.o -o pdftoppm ../libpoppler.a -llcms2 -lfontconfig -lfreetype -lbrotlidec -lbrotlicommon -ljpeg -lm -lopenjp2 -lpng -ltiff -lbz2 -lexpat -llzma -lwebp -lwebpdecoder -lwebpdemux -lwebpmux -lz -lzstd" > ~/poppler/build/utils/CMakeFiles/pdftoppm.dir/link.txt && \
make -j$(nproc) pdftoppm

FROM builder-base AS builder-ffmpeg

# * ffmpegビルド
# `apk add --no-cache ffmpeg` としても実行できるが、依存ライブラリを含めたファイルサイズが大きくなるため、
# 最終的なイメージの容量節約のために自前の static ビルドを行う

RUN apk add --no-cache alpine-sdk cmake nasm x264-dev zlib-dev zlib-static

RUN git clone --depth 1 https://git.ffmpeg.org/ffmpeg.git ~/ffmpeg

RUN \
cd ~/ffmpeg && \
./configure --disable-shared --enable-static --pkg-config-flags=--static --extra-libs=-static --extra-cflags=--static --disable-doc --disable-debug --enable-gpl --enable-small --enable-libx264 --enable-zlib && \
make clean && \
make -j$(nproc)

FROM builder-base AS runner

# builder-ffmpeg でビルドした ffmpeg のバイナリをコピー
COPY --from=builder-ffmpeg /root/ffmpeg/ffmpeg /usr/local/bin/

# ハードウェア非依存の高い各種ライブラリ込み込みの static-ffmpeg ビルド https://github.com/wader/static-ffmpeg も存在するけど、その分ファイルサイズは大きい
#COPY --from=mwader/static-ffmpeg:5.1 /ffmpeg /usr/local/bin/

# builder-poppler でビルドした pdftoppm のバイナリをコピー
COPY --from=builder-poppler /root/poppler/build/utils/pdftoppm /usr/local/bin/

# シェルスクリプト群の生成
RUN \
echo -e "#!/bin/sh\nYPX=720; if expr \"\$1\" : '\([1-9][0-9]\|[1-9][0-9][0-9]\+\)\$' > /dev/null; then YPX=\$(expr \\( \$1 + 9 \\) / 18 \\* 18 ); fi; find *.pdf | sed 's/\\.[^/\\.]*\$//' | xargs -P4 -i sh -c \"rm -f \\\"/tmp/{}/\${YPX}p-*.png\\\" && mkdir -p \\\"/tmp/{}\\\" && pdftoppm -progress -png -r 150 \\\"{}.pdf\\\" \\\"/tmp/{}/\${YPX}p\\\" && ffmpeg -y -pattern_type glob -r 1/2 -i \\\"/tmp/{}/\${YPX}p-*.png\\\" -vf \\\"crop=min(ih*16/9\\,iw):ih,scale=-2:\${YPX}:flags=lanczos,pad=x=-2:aspect=16/9\\\" -c:v libx264 -r 30 -pix_fmt yuv420p \\\"{}.\${YPX}p.mp4\\\" && rm -f \\\"/tmp/{}/\${YPX}p-*.png\\\"\"" > /usr/local/bin/allpdf2vrclt && \
echo -e "#!/bin/sh\n/usr/local/bin/allpdf2vrclt 720" > /usr/local/bin/allpdf2vrclt_720p && \
echo -e "#!/bin/sh\n/usr/local/bin/allpdf2vrclt 1080" > /usr/local/bin/allpdf2vrclt_1080p && \
echo -e "#!/bin/sh\n/usr/local/bin/allpdf2vrclt 1440" > /usr/local/bin/allpdf2vrclt_1440p && \
echo -e "#!/bin/sh\n/usr/local/bin/allpdf2vrclt 2160" > /usr/local/bin/allpdf2vrclt_2160p && \
echo -e "#!/bin/sh\nYPX=720; YDPI=150; if expr \"\$2\" : '\([1-9][0-9]\|[1-9][0-9][0-9]\+\)\$' > /dev/null; then YPX=\$(expr \\( \$2 + 9 \\) / 18 \\* 18 ); YDPI=\$(expr \$YPX \* 150 / 720); fi; rm -f \"/tmp/\$1/\${YPX}p-*.png\" && mkdir -p \"/tmp/\$1\" && pdftoppm -progress -png -r \$YDPI \"\$1.pdf\" \"/tmp/\$1/\${YPX}p\" && ffmpeg -y -pattern_type glob -r 1/2 -i \"/tmp/\$1/\${YPX}p-*.png\" -vf \"crop=min(ih*16/9\,iw):ih,scale=-2:\${YPX}:flags=lanczos,pad=x=-2:aspect=16/9\" -c:v libx264 -r 30 -pix_fmt yuv420p \"\$1.\${YPX}p.mp4\" && rm -f \"/tmp/\$1/\${YPX}p-*.png\"" > /usr/local/bin/pdf2vrclt && \
echo -e "#!/bin/sh\n/usr/local/bin/pdf2vrclt \"\$1\" 720" > /usr/local/bin/pdf2vrclt_720p && \
echo -e "#!/bin/sh\n/usr/local/bin/pdf2vrclt \"\$1\" 1080" > /usr/local/bin/pdf2vrclt_1080p && \
echo -e "#!/bin/sh\n/usr/local/bin/pdf2vrclt \"\$1\" 1440" > /usr/local/bin/pdf2vrclt_1440p && \
echo -e "#!/bin/sh\n/usr/local/bin/pdf2vrclt \"\$1\" 2160" > /usr/local/bin/pdf2vrclt_2160p && \
chmod +x /usr/local/bin/allpdf2vrclt* /usr/local/bin/pdf2vrclt*

WORKDIR /opt/work
