FROM dfam/tetools:1.5
MAINTAINER Rich Demko
WORKDIR /work
COPY ./bin/seqCleaner.pl /usr/local/bin/seqCleaner.pl
RUN chmod +x /usr/local/bin/seqCleaner.pl