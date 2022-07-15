FROM dfam/tetools:1.5

MAINTAINER rdemko2332@gmail.com

RUN apt-get -qq update --fix-missing

RUN apt-get install -y \
  cpanminus \
  bioperl \
  bioperl-run 

COPY ./bin/seqCleaner.pl /usr/local/bin/seqCleaner.pl

RUN chmod +x /usr/local/bin/seqCleaner.pl

WORKDIR /work