# A preinstalled pelican with image optimizer installed
FROM apihackers/python3

# Version change should trigger a rebuild
ENV MOZJPEG_VERSION 3.1
ENV GIFSICLE_VERSION 1.88
ENV PNGQUANT_VERSION 2.5.2

# Install common dependencies
RUN apk --update --no-cache add libpng bash curl yaml gettext cairo libffi libxml2 libxslt

# # Install build dependencies as virtual, build MozJpeg and remove them
RUN apk --update --no-cache add --virtual build-dependencies \
    # Common build tools
    autoconf automake build-base libtool nasm \
    # pngquant
    libpng-dev \
    # Install gifsicle from sources
    && curl -L -O https://www.lcdf.org/gifsicle/gifsicle-$GIFSICLE_VERSION.tar.gz \
    && tar zxf gifsicle-$GIFSICLE_VERSION.tar.gz \
    && cd gifsicle-$GIFSICLE_VERSION \
    && ./configure --prefix=/usr && make && make install \
    && cd .. \
    && cd gifsicle-$GIFSICLE_VERSION \
    # Install pngquant from sources
    && curl -L -O http://pngquant.org/pngquant-$PNGQUANT_VERSION-src.tar.bz2 \
    && tar xjf pngquant-$PNGQUANT_VERSION-src.tar.bz2 \
    && cd pngquant-$PNGQUANT_VERSION \
    && ./configure --prefix=/usr && make && make install \
    && cd .. \
    && rm -fr pngquant-$PNGQUANT_VERSION \
    # Install MozJPEG from sources
    && curl -L -O https://github.com/mozilla/mozjpeg/releases/download/v$MOZJPEG_VERSION/mozjpeg-$MOZJPEG_VERSION-release-source.tar.gz \
    && tar zxf mozjpeg-$MOZJPEG_VERSION-release-source.tar.gz \
    && cd mozjpeg \
    && autoreconf -fiv \
    && ./configure --prefix=/usr && make && make install \
    && cd .. \
    && rm -fr mozjpeg \
    # Uninstall build dependencies
    && apk del build-dependencies

ENV PELICAN_VERSION=3.6.3

# Install commonly used requirements
RUN apk --no-cache add --virtual build-dependencies \
        python3-dev yaml-dev build-base cairo-dev libffi-dev libxml2-dev libxslt-dev\
    && pip3 install -U pip pelican==$PELICAN_VERSION Markdown pyyaml pygments feedparser \
        feedgenerator typogrify awesome-slugify invoke babel weasyprint \
    && apk del build-dependencies \
    && rm -r /root/.cache
