FROM alpine:3.16

RUN apk add --no-cache ffmpeg poppler-utils

RUN \
echo -e "#!/bin/sh\nfind *.pdf | sed 's/\.[^/\.]*$//' | xargs -P4 -i sh -c 'rm -f \"/tmp/{}/*.png\" && mkdir -p \"/tmp/{}\" && pdftoppm -progress -scale-to-x 1280 -scale-to-y 720 -png \"{}.pdf\" \"/tmp/{}/p\" && ffmpeg -y -pattern_type glob -r 1/2 -i \"/tmp/{}/p-*.png\" -c:v libx264 -r 30 -pix_fmt yuv420p \"{}.720p.mp4\" && rm -f \"/tmp/{}/*.png\"'" > /usr/local/bin/allpdf2vrclt && \
echo -e "#!/bin/sh\nfind *.pdf | sed 's/\.[^/\.]*$//' | xargs -P4 -i sh -c 'rm -f \"/tmp/{}/*.png\" && mkdir -p \"/tmp/{}\" && pdftoppm -progress -scale-to-x 1280 -scale-to-y 720 -png \"{}.pdf\" \"/tmp/{}/p\" && ffmpeg -y -pattern_type glob -r 1/2 -i \"/tmp/{}/p-*.png\" -c:v libx264 -r 30 -pix_fmt yuv420p \"{}.720p.mp4\" && rm -f \"/tmp/{}/*.png\"'" > /usr/local/bin/allpdf2vrclt_720p && \
echo -e "#!/bin/sh\nfind *.pdf | sed 's/\.[^/\.]*$//' | xargs -P4 -i sh -c 'rm -f \"/tmp/{}/*.png\" && mkdir -p \"/tmp/{}\" && pdftoppm -progress -scale-to-x 1920 -scale-to-y 1080 -png \"{}.pdf\" \"/tmp/{}/p\" && ffmpeg -y -pattern_type glob -r 1/2 -i \"/tmp/{}/p-*.png\" -c:v libx264 -r 30 -pix_fmt yuv420p \"{}.1080p.mp4\" && rm -f \"/tmp/{}/*.png\"'" > /usr/local/bin/allpdf2vrclt_1080p && \
echo -e "#!/bin/sh\nfind *.pdf | sed 's/\.[^/\.]*$//' | xargs -P4 -i sh -c 'rm -f \"/tmp/{}/*.png\" && mkdir -p \"/tmp/{}\" && pdftoppm -progress -scale-to-x 3840 -scale-to-y 2160 -png \"{}.pdf\" \"/tmp/{}/p\" && ffmpeg -y -pattern_type glob -r 1/2 -i \"/tmp/{}/p-*.png\" -c:v libx264 -r 30 -pix_fmt yuv420p \"{}.2160p.mp4\" && rm -f \"/tmp/{}/*.png\"'" > /usr/local/bin/allpdf2vrclt_2160p && \
echo -e "#!/bin/sh\nrm -f \"/tmp/\$1/*.png\" && mkdir -p \"/tmp/\$1\" && pdftoppm -progress -scale-to-x 1280 -scale-to-y 720 -png \"\$1.pdf\" \"/tmp/\$1/p\" && ffmpeg -y -pattern_type glob -r 1/2 -i \"/tmp/\$1/p-*.png\" -c:v libx264 -r 30 -pix_fmt yuv420p \"\$1.720p.mp4\" && rm -f \"/tmp/\$1/*.png\"" > /usr/local/bin/pdf2vrclt && \
echo -e "#!/bin/sh\nrm -f \"/tmp/\$1/*.png\" && mkdir -p \"/tmp/\$1\" && pdftoppm -progress -scale-to-x 1280 -scale-to-y 720 -png \"\$1.pdf\" \"/tmp/\$1/p\" && ffmpeg -y -pattern_type glob -r 1/2 -i \"/tmp/\$1/p-*.png\" -c:v libx264 -r 30 -pix_fmt yuv420p \"\$1.720p.mp4\" && rm -f \"/tmp/\$1/*.png\"" > /usr/local/bin/pdf2vrclt_720p && \
echo -e "#!/bin/sh\nrm -f \"/tmp/\$1/*.png\" && mkdir -p \"/tmp/\$1\" && pdftoppm -progress -scale-to-x 1920 -scale-to-y 1080 -png \"\$1.pdf\" \"/tmp/\$1/p\" && ffmpeg -y -pattern_type glob -r 1/2 -i \"/tmp/\$1/p-*.png\" -c:v libx264 -r 30 -pix_fmt yuv420p \"\$1.1080p.mp4\" && rm -f \"/tmp/\$1/*.png\"" > /usr/local/bin/pdf2vrclt_1080p && \
echo -e "#!/bin/sh\nrm -f \"/tmp/\$1/*.png\" && mkdir -p \"/tmp/\$1\" && pdftoppm -progress -scale-to-x 3840 -scale-to-y 2160 -png \"\$1.pdf\" \"/tmp/\$1/p\" && ffmpeg -y -pattern_type glob -r 1/2 -i \"/tmp/\$1/p-*.png\" -c:v libx264 -r 30 -pix_fmt yuv420p \"\$1.2160p.mp4\" && rm -f \"/tmp/\$1/*.png\"" > /usr/local/bin/pdf2vrclt_2160p && \
chmod +x /usr/local/bin/allpdf2vrclt* /usr/local/bin/pdf2vrclt*

WORKDIR /opt/work
