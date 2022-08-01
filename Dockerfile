FROM alpine AS builder

RUN apk add --no-cache alpine-sdk bash cmake nasm yasm

RUN \
git clone --depth 1 https://github.com/madler/zlib.git ~/zlib && \
git clone --depth 1 https://code.videolan.org/videolan/x264.git ~/x264 && \
git clone --depth 1 https://git.ffmpeg.org/ffmpeg.git ~/ffmpeg && \
cd ~/zlib && \
./configure --static && \
make clean && \
make -j$(nproc) && \
make install && \
cd ~/x264 && \
./configure --enable-static --disable-opencl && \
make clean && \
make -j$(nproc) && \
make install && \
cd ~/ffmpeg && \
./configure --disable-shared --enable-static --pkg-config-flags=--static --extra-libs=-static --extra-cflags=--static --disable-doc --disable-debug --enable-small --enable-zlib --enable-libx264 --enable-gpl --enable-nonfree && \
make clean && \
make -j$(nproc) && \
make install

FROM alpine AS runner

RUN apk add --no-cache poppler-utils

COPY --from=builder /root/ffmpeg/ffmpeg /usr/local/bin/

RUN \
echo -e "#!/bin/sh\nfind *.pdf | sed 's/\.[^/\.]*$//' | xargs -P4 -i sh -c 'rm -f \"/tmp/{}/*.png\" && mkdir -p \"/tmp/{}\" && pdftoppm -progress -scale-to-x 1280 -scale-to-y 720 -png \"{}.pdf\" \"/tmp/{}/p\" && ffmpeg -y -pattern_type glob -r 1/2 -i \"/tmp/{}/p-*.png\" -c:v libx264 -r 30 -pix_fmt yuv420p \"{}.720p.mp4\" && rm -f \"/tmp/{}/*.png\"'" > /usr/local/bin/allpdf2vrclt && \
echo -e "#!/bin/sh\nfind *.pdf | sed 's/\.[^/\.]*$//' | xargs -P4 -i sh -c 'rm -f \"/tmp/{}/*.png\" && mkdir -p \"/tmp/{}\" && pdftoppm -progress -scale-to-x 1280 -scale-to-y 720 -png \"{}.pdf\" \"/tmp/{}/p\" && ffmpeg -y -pattern_type glob -r 1/2 -i \"/tmp/{}/p-*.png\" -c:v libx264 -r 30 -pix_fmt yuv420p \"{}.720p.mp4\" && rm -f \"/tmp/{}/*.png\"'" > /usr/local/bin/allpdf2vrclt_720p && \
echo -e "#!/bin/sh\nfind *.pdf | sed 's/\.[^/\.]*$//' | xargs -P4 -i sh -c 'rm -f \"/tmp/{}/*.png\" && mkdir -p \"/tmp/{}\" && pdftoppm -progress -scale-to-x 1920 -scale-to-y 1080 -png \"{}.pdf\" \"/tmp/{}/p\" && ffmpeg -y -pattern_type glob -r 1/2 -i \"/tmp/{}/p-*.png\" -c:v libx264 -r 30 -pix_fmt yuv420p \"{}.1080p.mp4\" && rm -f \"/tmp/{}/*.png\"'" > /usr/local/bin/allpdf2vrclt_1080p && \
echo -e "#!/bin/sh\nfind *.pdf | sed 's/\.[^/\.]*$//' | xargs -P4 -i sh -c 'rm -f \"/tmp/{}/*.png\" && mkdir -p \"/tmp/{}\" && pdftoppm -progress -scale-to-x 2560 -scale-to-y 1440 -png \"{}.pdf\" \"/tmp/{}/p\" && ffmpeg -y -pattern_type glob -r 1/2 -i \"/tmp/{}/p-*.png\" -c:v libx264 -r 30 -pix_fmt yuv420p \"{}.1440p.mp4\" && rm -f \"/tmp/{}/*.png\"'" > /usr/local/bin/allpdf2vrclt_1440p && \
echo -e "#!/bin/sh\nfind *.pdf | sed 's/\.[^/\.]*$//' | xargs -P4 -i sh -c 'rm -f \"/tmp/{}/*.png\" && mkdir -p \"/tmp/{}\" && pdftoppm -progress -scale-to-x 3840 -scale-to-y 2160 -png \"{}.pdf\" \"/tmp/{}/p\" && ffmpeg -y -pattern_type glob -r 1/2 -i \"/tmp/{}/p-*.png\" -c:v libx264 -r 30 -pix_fmt yuv420p \"{}.2160p.mp4\" && rm -f \"/tmp/{}/*.png\"'" > /usr/local/bin/allpdf2vrclt_2160p && \
echo -e "#!/bin/sh\nrm -f \"/tmp/\$1/*.png\" && mkdir -p \"/tmp/\$1\" && pdftoppm -progress -scale-to-x 1280 -scale-to-y 720 -png \"\$1.pdf\" \"/tmp/\$1/p\" && ffmpeg -y -pattern_type glob -r 1/2 -i \"/tmp/\$1/p-*.png\" -c:v libx264 -r 30 -pix_fmt yuv420p \"\$1.720p.mp4\" && rm -f \"/tmp/\$1/*.png\"" > /usr/local/bin/pdf2vrclt && \
echo -e "#!/bin/sh\nrm -f \"/tmp/\$1/*.png\" && mkdir -p \"/tmp/\$1\" && pdftoppm -progress -scale-to-x 1280 -scale-to-y 720 -png \"\$1.pdf\" \"/tmp/\$1/p\" && ffmpeg -y -pattern_type glob -r 1/2 -i \"/tmp/\$1/p-*.png\" -c:v libx264 -r 30 -pix_fmt yuv420p \"\$1.720p.mp4\" && rm -f \"/tmp/\$1/*.png\"" > /usr/local/bin/pdf2vrclt_720p && \
echo -e "#!/bin/sh\nrm -f \"/tmp/\$1/*.png\" && mkdir -p \"/tmp/\$1\" && pdftoppm -progress -scale-to-x 1920 -scale-to-y 1080 -png \"\$1.pdf\" \"/tmp/\$1/p\" && ffmpeg -y -pattern_type glob -r 1/2 -i \"/tmp/\$1/p-*.png\" -c:v libx264 -r 30 -pix_fmt yuv420p \"\$1.1080p.mp4\" && rm -f \"/tmp/\$1/*.png\"" > /usr/local/bin/pdf2vrclt_1080p && \
echo -e "#!/bin/sh\nrm -f \"/tmp/\$1/*.png\" && mkdir -p \"/tmp/\$1\" && pdftoppm -progress -scale-to-x 2560 -scale-to-y 1440 -png \"\$1.pdf\" \"/tmp/\$1/p\" && ffmpeg -y -pattern_type glob -r 1/2 -i \"/tmp/\$1/p-*.png\" -c:v libx264 -r 30 -pix_fmt yuv420p \"\$1.1440p.mp4\" && rm -f \"/tmp/\$1/*.png\"" > /usr/local/bin/pdf2vrclt_1440p && \
echo -e "#!/bin/sh\nrm -f \"/tmp/\$1/*.png\" && mkdir -p \"/tmp/\$1\" && pdftoppm -progress -scale-to-x 3840 -scale-to-y 2160 -png \"\$1.pdf\" \"/tmp/\$1/p\" && ffmpeg -y -pattern_type glob -r 1/2 -i \"/tmp/\$1/p-*.png\" -c:v libx264 -r 30 -pix_fmt yuv420p \"\$1.2160p.mp4\" && rm -f \"/tmp/\$1/*.png\"" > /usr/local/bin/pdf2vrclt_2160p && \
chmod +x /usr/local/bin/allpdf2vrclt* /usr/local/bin/pdf2vrclt*

WORKDIR /opt/work
