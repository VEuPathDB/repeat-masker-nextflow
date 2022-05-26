FROM dfam/tetools:1.5

MAINTAINER rdemko2332@gmail.com

COPY ./bin/seqCleaner.pl /usr/local/bin/seqCleaner.pl

RUN chmod +x /usr/local/bin/seqCleaner.pl

WORKDIR /work