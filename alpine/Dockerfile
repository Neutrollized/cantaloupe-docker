FROM alpine:3.13.5

ENV OPENJDK_VERSION=11
ENV LIBJPEGTURBO_VERSION=2.0.2
ENV CANTALOUPE_VERSION=5.0.3
ENV JAVA_MAX_HEAP=1g

EXPOSE 8182

VOLUME /imageroot

# Update packages and install tools
RUN apk add --no-cache \
    curl unzip \
    ffmpeg openjpeg openjpeg-tools \
    openjdk${OPENJDK_VERSION} \
    msttcorefonts-installer fontconfig \
  && update-ms-fonts

# NOTE: need to set JAVA_HOME, otherwise it won't be able to find the javadoc binary
ENV JAVA_HOME="/usr/lib/jvm/java-${OPENJDK_VERSION}-openjdk"
ENV PATH="${JAVA_HOME}/bin:${PATH}"


# NOTE: can leave out this piece if you don't need the TurboJpegProcessor
# https://cantaloupe-project.github.io/manual/5.0/processors.html#TurboJpegProcessor
RUN cd /tmp && apk add --no-cache --virtual .build-dependencies cmake g++ make nasm \
  && curl --silent --fail -OL https://downloads.sourceforge.net/project/libjpeg-turbo/${LIBJPEGTURBO_VERSION}/libjpeg-turbo-${LIBJPEGTURBO_VERSION}.tar.gz \
  && tar -xpf libjpeg-turbo-${LIBJPEGTURBO_VERSION}.tar.gz \
  && cd libjpeg-turbo-${LIBJPEGTURBO_VERSION} \
  && cmake \
  -DCMAKE_INSTALL_PREFIX=/usr \
  -DCMAKE_INSTALL_LIBDIR=/usr/lib \
  -DBUILD_SHARED_LIBS=True \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_FLAGS="$CFLAGS" \
  -DWITH_JPEG8=1 \
  -DWITH_JAVA=1 \
  && make && make install \
  && apk del .build-dependencies

# Run non privileged
RUN addgroup --system cantaloupe \
  && adduser --system cantaloupe cantaloupe

# Get and unpack Cantaloupe release archive
RUN curl --silent --fail -OL https://github.com/cantaloupe-project/cantaloupe/releases/download/v${CANTALOUPE_VERSION}/cantaloupe-${CANTALOUPE_VERSION}.zip \
  && unzip cantaloupe-${CANTALOUPE_VERSION}.zip \
  && ln -s cantaloupe-${CANTALOUPE_VERSION} cantaloupe \
  && rm cantaloupe-${CANTALOUPE_VERSION}.zip \
  && mkdir -p /var/log/cantaloupe /var/cache/cantaloupe \
  && chown -R cantaloupe /cantaloupe /var/log/cantaloupe /var/cache/cantaloupe

USER cantaloupe

CMD ["sh", "-c", "java -Dcantaloupe.config=/cantaloupe/cantaloupe.properties.sample -Xmx${JAVA_MAX_HEAP} -jar /cantaloupe/cantaloupe-${CANTALOUPE_VERSION}.jar"]
