FROM alpine:latest AS builder-base

FROM builder-base AS runner

RUN apk add --no-cache \
font-noto \
font-noto-arabic \
font-noto-bengali \
font-noto-cjk \
font-noto-devanagari \
font-noto-emoji \
font-noto-math \
font-noto-music \
font-noto-symbols \
ttf-liberation \
poppler-data

COPY --from=mwader/static-ffmpeg:latest /ffmpeg /usr/local/bin/

RUN apk add --no-cache poppler-utils

# japanese fonts config
RUN \
mkdir -p ~/.config/fontconfig/ &&\
echo -e "<?xml version='1.0'?>\n\
<!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>\n\
<fontconfig>\n\
<alias><family>serif</family><prefer><family>Noto Serif</family><family>Noto Serif CJK JP</family></prefer></alias>\n\
<alias><family>sans-serif</family><prefer><family>Noto Sans</family><family>Noto Sans CJK JP</family></prefer></alias>\n\
<alias><family>monospace</family><prefer><family>Noto Sans Mono</family><family>Noto Sans Mono CJK JP</family></prefer></alias>\n\
<alias><family>Ryumin</family><prefer><family>Noto Serif</family><family>Noto Serif CJK JP</family></prefer></alias>\n\
<alias><family>GothicBBB</family><prefer><family>Noto Sans</family><family>Noto Sans CJK JP</family></prefer></alias>\n\
</fontconfig>" > ~/.config/fontconfig/fonts.conf &&\
fc-cache -f

# generate shellscripts
RUN \
echo -e "#!/bin/sh\nYPX=720; if expr \"\$1\" : '\([1-9][0-9]\|[1-9][0-9][0-9]\+\)\$' > /dev/null; then YPX=\$(expr \\( \$1 + 9 \\) / 18 \\* 18 ); fi; find *.pdf | sed 's/\\.[^/\\.]*\$//' | xargs -P4 -i sh -c \"rm -f \\\"/tmp/{}/\${YPX}p-*.png\\\" && mkdir -p \\\"/tmp/{}\\\" && pdftoppm -progress -png -scale-to-x -1 -scale-to-y \$YPX \\\"{}.pdf\\\" \\\"/tmp/{}/\${YPX}p\\\" && ffmpeg -y -pattern_type glob -r 1/2 -i \\\"/tmp/{}/\${YPX}p-*.png\\\" -vf \\\"crop=min(ih*16/9\\,iw):ih,scale=-2:\${YPX}:flags=lanczos,pad=x=-2:aspect=16/9\\\" -c:v libx264 -r 6 -bf 0 -force_key_frames \\\"expr:gte(t,n_forced*2)\\\" -pix_fmt yuv420p \\\"{}.\${YPX}p.vrclt.mp4\\\" && rm -f \\\"/tmp/{}/\${YPX}p-*.png\\\"\"" > /usr/local/bin/allpdf2vrclt && \
echo -e "#!/bin/sh\nYPX=720; if expr \"\$1\" : '\([1-9][0-9]\|[1-9][0-9][0-9]\+\)\$' > /dev/null; then YPX=\$(expr \\( \$1 + 9 \\) / 18 \\* 18 ); fi; find *.pdf | sed 's/\\.[^/\\.]*\$//' | xargs -P4 -i sh -c \"rm -f \\\"/tmp/{}/\${YPX}p-*.png\\\" && mkdir -p \\\"/tmp/{}\\\" && pdftoppm -progress -png -scale-to-x -1 -scale-to-y \$YPX \\\"{}.pdf\\\" \\\"/tmp/{}/\${YPX}p\\\" && ffmpeg -y -pattern_type glob -r 1 -i \\\"/tmp/{}/\${YPX}p-*.png\\\" -vf \\\"crop=min(ih*16/9\\,iw):ih,scale=-2:\${YPX}:flags=lanczos,pad=x=-2:aspect=16/9\\\" -c:v libx264 -r 6 -bf 0 -force_key_frames \\\"expr:gte(t,n_forced)\\\" -pix_fmt yuv420p \\\"{}.\${YPX}p.unaslides.mp4\\\" && rm -f \\\"/tmp/{}/\${YPX}p-*.png\\\"\"" > /usr/local/bin/allpdf2unaslides && \
echo -e "#!/bin/sh\n/usr/local/bin/allpdf2vrclt 720" > /usr/local/bin/allpdf2vrclt_720p && \
echo -e "#!/bin/sh\n/usr/local/bin/allpdf2vrclt 1080" > /usr/local/bin/allpdf2vrclt_1080p && \
echo -e "#!/bin/sh\n/usr/local/bin/allpdf2vrclt 1440" > /usr/local/bin/allpdf2vrclt_1440p && \
echo -e "#!/bin/sh\n/usr/local/bin/allpdf2vrclt 2160" > /usr/local/bin/allpdf2vrclt_2160p && \
echo -e "#!/bin/sh\n/usr/local/bin/allpdf2unaslides 720" > /usr/local/bin/allpdf2unaslides_720p && \
echo -e "#!/bin/sh\n/usr/local/bin/allpdf2unaslides 1080" > /usr/local/bin/allpdf2unaslides_1080p && \
echo -e "#!/bin/sh\n/usr/local/bin/allpdf2unaslides 1440" > /usr/local/bin/allpdf2unaslides_1440p && \
echo -e "#!/bin/sh\n/usr/local/bin/allpdf2unaslides 2160" > /usr/local/bin/allpdf2unaslides_2160p && \
echo -e "#!/bin/sh\nYPX=720; if expr \"\$2\" : '\([1-9][0-9]\|[1-9][0-9][0-9]\+\)\$' > /dev/null; then YPX=\$(expr \\( \$2 + 9 \\) / 18 \\* 18 ); fi; rm -f \"/tmp/\$1/\${YPX}p-*.png\" && mkdir -p \"/tmp/\$1\" && pdftoppm -progress -png -scale-to-x -1 -scale-to-y \$YPX \"\$1.pdf\" \"/tmp/\$1/\${YPX}p\" && ffmpeg -y -pattern_type glob -r 1/2 -i \"/tmp/\$1/\${YPX}p-*.png\" -vf \"crop=min(ih*16/9\,iw):ih,scale=-2:\${YPX}:flags=lanczos,pad=x=-2:aspect=16/9\" -c:v libx264 -r 6 -bf 0 -force_key_frames \"expr:gte(t,n_forced*2)\" -pix_fmt yuv420p \"\$1.\${YPX}p.vrclt.mp4\" && rm -f \"/tmp/\$1/\${YPX}p-*.png\"" > /usr/local/bin/pdf2vrclt && \
echo -e "#!/bin/sh\nYPX=720; if expr \"\$2\" : '\([1-9][0-9]\|[1-9][0-9][0-9]\+\)\$' > /dev/null; then YPX=\$(expr \\( \$2 + 9 \\) / 18 \\* 18 ); fi; rm -f \"/tmp/\$1/\${YPX}p-*.png\" && mkdir -p \"/tmp/\$1\" && pdftoppm -progress -png -scale-to-x -1 -scale-to-y \$YPX \"\$1.pdf\" \"/tmp/\$1/\${YPX}p\" && ffmpeg -y -pattern_type glob -r 1 -i \"/tmp/\$1/\${YPX}p-*.png\" -vf \"crop=min(ih*16/9\,iw):ih,scale=-2:\${YPX}:flags=lanczos,pad=x=-2:aspect=16/9\" -c:v libx264 -r 6 -bf 0 -force_key_frames \"expr:gte(t,n_forced)\" -pix_fmt yuv420p \"\$1.\${YPX}p.unaslides.mp4\" && rm -f \"/tmp/\$1/\${YPX}p-*.png\"" > /usr/local/bin/pdf2unaslides && \
echo -e "#!/bin/sh\nYPX=720; if expr \"\$2\" : '\([1-9][0-9]\|[1-9][0-9][0-9]\+\)\$' > /dev/null; then YPX=\$(expr \\( \$2 + 9 \\) / 18 \\* 18 ); fi; rm -f \"/tmp/\$1/\${YPX}p-*.png\" && mkdir -p \"/tmp/\$1\" && pdftoppm -progress -png -scale-to-x -1 -scale-to-y \$YPX \"\$1.pdf\" \"/tmp/\$1/\${YPX}p\" && ffmpeg -y -pattern_type glob -r 1/2 -i \"/tmp/\$1/\${YPX}p-*.png\" -vf \"crop=min(ih*16/9\,iw):ih,scale=-2:\${YPX}:flags=lanczos,pad=x=-2:aspect=16/9\" -c:v libsvtav1 -r 6 -qp 30 -force_key_frames \"expr:gte(t,n_forced*2)\" -pix_fmt yuv420p \"\$1.\${YPX}p.vrclt.av1.webm\" && rm -f \"/tmp/\$1/\${YPX}p-*.png\"" > /usr/local/bin/pdf2vrclt_av1_webm && \
echo -e "#!/bin/sh\nYPX=720; if expr \"\$2\" : '\([1-9][0-9]\|[1-9][0-9][0-9]\+\)\$' > /dev/null; then YPX=\$(expr \\( \$2 + 9 \\) / 18 \\* 18 ); fi; rm -f \"/tmp/\$1/\${YPX}p-*.png\" && mkdir -p \"/tmp/\$1\" && pdftoppm -progress -png -scale-to-x -1 -scale-to-y \$YPX \"\$1.pdf\" \"/tmp/\$1/\${YPX}p\" && ffmpeg -y -pattern_type glob -r 1 -i \"/tmp/\$1/\${YPX}p-*.png\" -vf \"crop=min(ih*16/9\,iw):ih,scale=-2:\${YPX}:flags=lanczos,pad=x=-2:aspect=16/9\" -c:v libsvtav1 -r 6 -qp 30 -force_key_frames \"expr:gte(t,n_forced)\" -pix_fmt yuv420p \"\$1.\${YPX}p.unaslides.av1.webm\" && rm -f \"/tmp/\$1/\${YPX}p-*.png\"" > /usr/local/bin/pdf2unaslides_av1_webm && \
echo -e "#!/bin/sh\nYPX=720; if expr \"\$2\" : '\([1-9][0-9]\|[1-9][0-9][0-9]\+\)\$' > /dev/null; then YPX=\$(expr \\( \$2 + 9 \\) / 18 \\* 18 ); fi; rm -f \"/tmp/\$1/\${YPX}p-*.png\" && mkdir -p \"/tmp/\$1\" && pdftoppm -progress -png -scale-to-x -1 -scale-to-y \$YPX \"\$1.pdf\" \"/tmp/\$1/\${YPX}p\" && ffmpeg -y -pattern_type glob -r 1/2 -i \"/tmp/\$1/\${YPX}p-*.png\" -vf \"crop=min(ih*16/9\,iw):ih,scale=-2:\${YPX}:flags=lanczos,pad=x=-2:aspect=16/9\" -c:v libvpx-vp9 -r 6 -crf 30 -b:v 0 -quality best -speed 4 -force_key_frames \"expr:gte(t,n_forced*2)\" -pix_fmt yuv420p \"\$1.\${YPX}p.vrclt.vp9.webm\" && rm -f \"/tmp/\$1/\${YPX}p-*.png\"" > /usr/local/bin/pdf2vrclt_vp9_webm && \
echo -e "#!/bin/sh\nYPX=720; if expr \"\$2\" : '\([1-9][0-9]\|[1-9][0-9][0-9]\+\)\$' > /dev/null; then YPX=\$(expr \\( \$2 + 9 \\) / 18 \\* 18 ); fi; rm -f \"/tmp/\$1/\${YPX}p-*.png\" && mkdir -p \"/tmp/\$1\" && pdftoppm -progress -png -scale-to-x -1 -scale-to-y \$YPX \"\$1.pdf\" \"/tmp/\$1/\${YPX}p\" && ffmpeg -y -pattern_type glob -r 1 -i \"/tmp/\$1/\${YPX}p-*.png\" -vf \"crop=min(ih*16/9\,iw):ih,scale=-2:\${YPX}:flags=lanczos,pad=x=-2:aspect=16/9\" -c:v libvpx-vp9 -r 6 -crf 30 -b:v 0 -quality best -speed 4 -force_key_frames \"expr:gte(t,n_forced)\" -pix_fmt yuv420p \"\$1.\${YPX}p.unaslides.vp9.webm\" && rm -f \"/tmp/\$1/\${YPX}p-*.png\"" > /usr/local/bin/pdf2unaslides_vp9_webm && \
echo -e "#!/bin/sh\nYPX=720; if expr \"\$2\" : '\([1-9][0-9]\|[1-9][0-9][0-9]\+\)\$' > /dev/null; then YPX=\$(expr \\( \$2 + 9 \\) / 18 \\* 18 ); fi; rm -f \"/tmp/\$1/\${YPX}p-*.png\" && mkdir -p \"/tmp/\$1\" && pdftoppm -progress -png -scale-to-x -1 -scale-to-y \$YPX \"\$1.pdf\" \"/tmp/\$1/\${YPX}p\" && ffmpeg -y -pattern_type glob -r 1/2 -i \"/tmp/\$1/\${YPX}p-*.png\" -vf \"crop=min(ih*16/9\,iw):ih,scale=-2:\${YPX}:flags=lanczos,pad=x=-2:aspect=16/9\" -c:v libvpx -r 6 -crf 4 -b:v 1000000 -quality best -speed 4 -force_key_frames \"expr:gte(t,n_forced*2)\" -pix_fmt yuv420p \"\$1.\${YPX}p.vrclt.vp8.webm\" && rm -f \"/tmp/\$1/\${YPX}p-*.png\"" > /usr/local/bin/pdf2vrclt_vp8_webm && \
echo -e "#!/bin/sh\nYPX=720; if expr \"\$2\" : '\([1-9][0-9]\|[1-9][0-9][0-9]\+\)\$' > /dev/null; then YPX=\$(expr \\( \$2 + 9 \\) / 18 \\* 18 ); fi; rm -f \"/tmp/\$1/\${YPX}p-*.png\" && mkdir -p \"/tmp/\$1\" && pdftoppm -progress -png -scale-to-x -1 -scale-to-y \$YPX \"\$1.pdf\" \"/tmp/\$1/\${YPX}p\" && ffmpeg -y -pattern_type glob -r 1 -i \"/tmp/\$1/\${YPX}p-*.png\" -vf \"crop=min(ih*16/9\,iw):ih,scale=-2:\${YPX}:flags=lanczos,pad=x=-2:aspect=16/9\" -c:v libvpx -r 6 -crf 4 -b:v 2000000 -quality best -speed 4 -force_key_frames \"expr:gte(t,n_forced)\" -pix_fmt yuv420p \"\$1.\${YPX}p.unaslides.vp8.webm\" && rm -f \"/tmp/\$1/\${YPX}p-*.png\"" > /usr/local/bin/pdf2unaslides_vp8_webm && \
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
