FROM debian:buster

ENV LIBJPEGTURBO_VERSION=2.0.2
ENV CANTALOUPE_VERSION=5.0.3
ENV JAVA_MAX_HEAP=1g

EXPOSE 8182

VOLUME /imageroot

# Update packages and install tools
RUN apt-get update -qy && apt-get dist-upgrade -qy \
  && apt-get install -qy --no-install-recommends curl \
     ffmpeg imagemagick libopenjp2-tools \
     default-jdk unzip \
  && apt-get -qqy autoremove && apt-get -qqy autoclean

# https://cantaloupe-project.github.io/manual/4.1/processors.html#TurboJpegProcessor
RUN cd /tmp && apt-get install -qy cmake g++ make nasm \
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
  && mkdir -p /opt/libjpeg-turbo/lib \
  && ln -s /usr/lib/libturbojpeg.so /opt/libjpeg-turbo/lib/libturbojpeg.so \
  && cd /tmp && rm -Rf libjpeg-turbo-${LIBJPEGTURBO_VERSION}* \
  && apt-get purge -qy cmake g++ make nasm \
  && apt-get autoremove -qy

# Run non privileged
RUN adduser --system cantaloupe

# Get and unpack Cantaloupe release archive
RUN curl --silent --fail -OL https://github.com/cantaloupe-project/cantaloupe/releases/download/v${CANTALOUPE_VERSION}/cantaloupe-${CANTALOUPE_VERSION}.zip \
  && unzip cantaloupe-${CANTALOUPE_VERSION}.zip \
  && ln -s cantaloupe-${CANTALOUPE_VERSION} cantaloupe \
  && rm cantaloupe-${CANTALOUPE_VERSION}.zip \
  && mkdir -p /var/log/cantaloupe /var/cache/cantaloupe \
  && chown -R cantaloupe /cantaloupe /var/log/cantaloupe /var/cache/cantaloupe \
  && cp -rs /cantaloupe/deps/Linux-x86-64/* /usr/

USER cantaloupe
CMD ["sh", "-c", "java -Dcantaloupe.config=/cantaloupe/cantaloupe.properties.sample -Xmx${JAVA_MAX_HEAP} -jar /cantaloupe/cantaloupe-${CANTALOUPE_VERSION}.jar"]
