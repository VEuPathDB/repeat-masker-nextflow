FROM ubuntu:22.04

MAINTAINER rdemko2332@gmail.com

ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm

RUN apt-get -qq update --fix-missing

RUN apt-get -qq install -y \
  cpanminus \
  bioperl \
  bioperl-run \
  wget \
  gcc \
  g++ \
  make \
  zlib1g-dev \
  libgomp1 \
  perl \
  python3-h5py \
  libfile-which-perl \
  libtext-soundex-perl \
  libjson-perl liburi-perl libwww-perl \
  libdevel-size-perl \
  aptitude && aptitude install -y ~pstandard ~prequired \
  curl wget \
  vim nano \
  procps strace \
  libpam-systemd- \
  python3-setuptools

WORKDIR /opt

RUN wget https://github.com/Benson-Genomics-Lab/TRF/archive/v4.09.1.tar.gz \
    && tar -x -f v4.09.1.tar.gz \
    && cd TRF-4.09.1 \
    && mkdir build && cd build \
    && ../configure && make && cp ./src/trf /opt/trf \
    && cd .. && rm -r build

RUN wget http://www.repeatmasker.org/RepeatMasker/RepeatMasker-4.2.1.tar.gz \
  && tar -zxvf RepeatMasker-4.2.1.tar.gz \
  && rm RepeatMasker-4.2.1.tar.gz

# Extract RMBlast
RUN cd /opt \
    && mkdir rmblast \
    && wget http://www.repeatmasker.org/rmblast/rmblast-2.14.1+-x64-linux.tar.gz \
    && tar --strip-components=1 -x -f rmblast-2.14.1+-x64-linux.tar.gz -C rmblast \
    && rm rmblast-2.14.1+-x64-linux.tar.gz

COPY ./bin/seqCleaner.pl /usr/local/bin/seqCleaner.pl
COPY ./bin/configure /opt/RepeatMasker/configure
COPY ./bin/RepeatMaskerConfig.pm /opt/RepeatMasker/RepeatMaskerConfig.pm

RUN chmod +x /usr/local/bin/seqCleaner.pl

ENV PATH=/opt/:/opt/RepeatMasker/:/usr/bin/:$PATH

WORKDIR /work