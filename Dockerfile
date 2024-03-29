FROM alpine:latest AS builder-base

FROM builder-base AS runner

COPY --from=mwader/static-ffmpeg:latest /ffmpeg /usr/local/bin/

RUN apk add --no-cache poppler-utils

# シェルスクリプト群の生成
RUN \
echo -e "#!/bin/sh\nYPX=720; if expr \"\$1\" : '\([1-9][0-9]\|[1-9][0-9][0-9]\+\)\$' > /dev/null; then YPX=\$(expr \\( \$1 + 9 \\) / 18 \\* 18 ); fi; find *.pdf | sed 's/\\.[^/\\.]*\$//' | xargs -P4 -i sh -c \"rm -f \\\"/tmp/{}/\${YPX}p-*.png\\\" && mkdir -p \\\"/tmp/{}\\\" && pdftoppm -progress -png -scale-to-x -1 -scale-to-y \$YPX \\\"{}.pdf\\\" \\\"/tmp/{}/\${YPX}p\\\" && ffmpeg -y -pattern_type glob -r 1/2 -i \\\"/tmp/{}/\${YPX}p-*.png\\\" -vf \\\"crop=min(ih*16/9\\,iw):ih,scale=-2:\${YPX}:flags=lanczos,pad=x=-2:aspect=16/9\\\" -c:v libx264 -r 30 -pix_fmt yuv420p \\\"{}.\${YPX}p.vrclt.mp4\\\" && rm -f \\\"/tmp/{}/\${YPX}p-*.png\\\"\"" > /usr/local/bin/allpdf2vrclt && \
echo -e "#!/bin/sh\nYPX=720; if expr \"\$1\" : '\([1-9][0-9]\|[1-9][0-9][0-9]\+\)\$' > /dev/null; then YPX=\$(expr \\( \$1 + 9 \\) / 18 \\* 18 ); fi; find *.pdf | sed 's/\\.[^/\\.]*\$//' | xargs -P4 -i sh -c \"rm -f \\\"/tmp/{}/\${YPX}p-*.png\\\" && mkdir -p \\\"/tmp/{}\\\" && pdftoppm -progress -png -scale-to-x -1 -scale-to-y \$YPX \\\"{}.pdf\\\" \\\"/tmp/{}/\${YPX}p\\\" && ffmpeg -y -pattern_type glob -r 1 -i \\\"/tmp/{}/\${YPX}p-*.png\\\" -vf \\\"crop=min(ih*16/9\\,iw):ih,scale=-2:\${YPX}:flags=lanczos,pad=x=-2:aspect=16/9\\\" -c:v libx264 -r 30 -pix_fmt yuv420p \\\"{}.\${YPX}p.unaslides.mp4\\\" && rm -f \\\"/tmp/{}/\${YPX}p-*.png\\\"\"" > /usr/local/bin/allpdf2unaslides && \
echo -e "#!/bin/sh\n/usr/local/bin/allpdf2vrclt 720" > /usr/local/bin/allpdf2vrclt_720p && \
echo -e "#!/bin/sh\n/usr/local/bin/allpdf2vrclt 1080" > /usr/local/bin/allpdf2vrclt_1080p && \
echo -e "#!/bin/sh\n/usr/local/bin/allpdf2vrclt 1440" > /usr/local/bin/allpdf2vrclt_1440p && \
echo -e "#!/bin/sh\n/usr/local/bin/allpdf2vrclt 2160" > /usr/local/bin/allpdf2vrclt_2160p && \
echo -e "#!/bin/sh\n/usr/local/bin/allpdf2unaslides 720" > /usr/local/bin/allpdf2unaslides_720p && \
echo -e "#!/bin/sh\n/usr/local/bin/allpdf2unaslides 1080" > /usr/local/bin/allpdf2unaslides_1080p && \
echo -e "#!/bin/sh\n/usr/local/bin/allpdf2unaslides 1440" > /usr/local/bin/allpdf2unaslides_1440p && \
echo -e "#!/bin/sh\n/usr/local/bin/allpdf2unaslides 2160" > /usr/local/bin/allpdf2unaslides_2160p && \
echo -e "#!/bin/sh\nYPX=720; if expr \"\$2\" : '\([1-9][0-9]\|[1-9][0-9][0-9]\+\)\$' > /dev/null; then YPX=\$(expr \\( \$2 + 9 \\) / 18 \\* 18 ); fi; rm -f \"/tmp/\$1/\${YPX}p-*.png\" && mkdir -p \"/tmp/\$1\" && pdftoppm -progress -png -scale-to-x -1 -scale-to-y \$YPX \"\$1.pdf\" \"/tmp/\$1/\${YPX}p\" && ffmpeg -y -pattern_type glob -r 1/2 -i \"/tmp/\$1/\${YPX}p-*.png\" -vf \"crop=min(ih*16/9\,iw):ih,scale=-2:\${YPX}:flags=lanczos,pad=x=-2:aspect=16/9\" -c:v libx264 -r 30 -pix_fmt yuv420p \"\$1.\${YPX}p.vrclt.mp4\" && rm -f \"/tmp/\$1/\${YPX}p-*.png\"" > /usr/local/bin/pdf2vrclt && \
echo -e "#!/bin/sh\nYPX=720; if expr \"\$2\" : '\([1-9][0-9]\|[1-9][0-9][0-9]\+\)\$' > /dev/null; then YPX=\$(expr \\( \$2 + 9 \\) / 18 \\* 18 ); fi; rm -f \"/tmp/\$1/\${YPX}p-*.png\" && mkdir -p \"/tmp/\$1\" && pdftoppm -progress -png -scale-to-x -1 -scale-to-y \$YPX \"\$1.pdf\" \"/tmp/\$1/\${YPX}p\" && ffmpeg -y -pattern_type glob -r 1/2 -i \"/tmp/\$1/\${YPX}p-*.png\" -vf \"crop=min(ih*16/9\,iw):ih,scale=-2:\${YPX}:flags=lanczos,pad=x=-2:aspect=16/9\" -c:v libsvtav1 -qp 20 -pix_fmt yuv420p \"\$1.\${YPX}p.vrclt.mkv\" && rm -f \"/tmp/\$1/\${YPX}p-*.png\"" > /usr/local/bin/pdf2mkv && \
echo -e "#!/bin/sh\nYPX=720; if expr \"\$2\" : '\([1-9][0-9]\|[1-9][0-9][0-9]\+\)\$' > /dev/null; then YPX=\$(expr \\( \$2 + 9 \\) / 18 \\* 18 ); fi; rm -f \"/tmp/\$1/\${YPX}p-*.png\" && mkdir -p \"/tmp/\$1\" && pdftoppm -progress -png -scale-to-x -1 -scale-to-y \$YPX \"\$1.pdf\" \"/tmp/\$1/\${YPX}p\" && ffmpeg -y -pattern_type glob -r 1/2 -i \"/tmp/\$1/\${YPX}p-*.png\" -vf \"crop=min(ih*16/9\,iw):ih,scale=-2:\${YPX}:flags=lanczos,pad=x=-2:aspect=16/9\" -c:v libvpx -crf 4 -b:v 5000000 -quality best -speed 4 -pix_fmt yuv420p \"\$1.\${YPX}p.vrclt.webm\" && rm -f \"/tmp/\$1/\${YPX}p-*.png\"" > /usr/local/bin/pdf2vrclt_webm && \
echo -e "#!/bin/sh\nYPX=720; if expr \"\$2\" : '\([1-9][0-9]\|[1-9][0-9][0-9]\+\)\$' > /dev/null; then YPX=\$(expr \\( \$2 + 9 \\) / 18 \\* 18 ); fi; rm -f \"/tmp/\$1/\${YPX}p-*.png\" && mkdir -p \"/tmp/\$1\" && pdftoppm -progress -png -scale-to-x -1 -scale-to-y \$YPX \"\$1.pdf\" \"/tmp/\$1/\${YPX}p\" && ffmpeg -y -pattern_type glob -r 1 -i \"/tmp/\$1/\${YPX}p-*.png\" -vf \"crop=min(ih*16/9\,iw):ih,scale=-2:\${YPX}:flags=lanczos,pad=x=-2:aspect=16/9\" -c:v libx264 -r 30 -pix_fmt yuv420p \"\$1.\${YPX}p.unaslides.mp4\" && rm -f \"/tmp/\$1/\${YPX}p-*.png\"" > /usr/local/bin/pdf2unaslides && \
echo -e "#!/bin/sh\nYPX=720; if expr \"\$2\" : '\([1-9][0-9]\|[1-9][0-9][0-9]\+\)\$' > /dev/null; then YPX=\$(expr \\( \$2 + 9 \\) / 18 \\* 18 ); fi; rm -f \"/tmp/\$1/\${YPX}p-*.png\" && mkdir -p \"/tmp/\$1\" && pdftoppm -progress -png -scale-to-x -1 -scale-to-y \$YPX \"\$1.pdf\" \"/tmp/\$1/\${YPX}p\" && ffmpeg -y -pattern_type glob -r 1 -i \"/tmp/\$1/\${YPX}p-*.png\" -vf \"crop=min(ih*16/9\,iw):ih,scale=-2:\${YPX}:flags=lanczos,pad=x=-2:aspect=16/9\" -c:v libsvtav1 -qp 20 -pix_fmt yuv420p \"\$1.\${YPX}p.unaslides.mkv\" && rm -f \"/tmp/\$1/\${YPX}p-*.png\"" > /usr/local/bin/pdf2unaslides_mkv && \
echo -e "#!/bin/sh\nYPX=720; if expr \"\$2\" : '\([1-9][0-9]\|[1-9][0-9][0-9]\+\)\$' > /dev/null; then YPX=\$(expr \\( \$2 + 9 \\) / 18 \\* 18 ); fi; rm -f \"/tmp/\$1/\${YPX}p-*.png\" && mkdir -p \"/tmp/\$1\" && pdftoppm -progress -png -scale-to-x -1 -scale-to-y \$YPX \"\$1.pdf\" \"/tmp/\$1/\${YPX}p\" && ffmpeg -y -pattern_type glob -r 1 -i \"/tmp/\$1/\${YPX}p-*.png\" -vf \"crop=min(ih*16/9\,iw):ih,scale=-2:\${YPX}:flags=lanczos,pad=x=-2:aspect=16/9\" -c:v libvpx -crf 4 -b:v 5000000 -quality best -speed 4 -pix_fmt yuv420p \"\$1.\${YPX}p.unaslides.webm\" && rm -f \"/tmp/\$1/\${YPX}p-*.png\"" > /usr/local/bin/pdf2unaslides_webm && \
echo -e "#!/bin/sh\n/usr/local/bin/pdf2vrclt \"\$1\" 720" > /usr/local/bin/pdf2vrclt_720p && \
echo -e "#!/bin/sh\n/usr/local/bin/pdf2vrclt \"\$1\" 1080" > /usr/local/bin/pdf2vrclt_1080p && \
echo -e "#!/bin/sh\n/usr/local/bin/pdf2vrclt \"\$1\" 1440" > /usr/local/bin/pdf2vrclt_1440p && \
echo -e "#!/bin/sh\n/usr/local/bin/pdf2vrclt \"\$1\" 2160" > /usr/local/bin/pdf2vrclt_2160p && \
echo -e "#!/bin/sh\n/usr/local/bin/pdf2unaslides \"\$1\" 720" > /usr/local/bin/pdf2unaslides_720p && \
echo -e "#!/bin/sh\n/usr/local/bin/pdf2unaslides \"\$1\" 1080" > /usr/local/bin/pdf2unaslides_1080p && \
echo -e "#!/bin/sh\n/usr/local/bin/pdf2unaslides \"\$1\" 1440" > /usr/local/bin/pdf2unaslides_1440p && \
echo -e "#!/bin/sh\n/usr/local/bin/pdf2unaslides \"\$1\" 2160" > /usr/local/bin/pdf2unaslides_2160p && \
chmod +x /usr/local/bin/allpdf2* /usr/local/bin/pdf2*

WORKDIR /opt/work
