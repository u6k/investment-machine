FROM ruby:2.6
LABEL maintainer="u6k.apps@gmail.com"

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get clean && \
    { \
      echo "#!/bin/bash -eu"; \
      echo "bundle install"; \
      echo "cp /usr/local/bundle/bundler/gems/crawline-*/db/migrate/* ./db/migrate/"; \
      echo "rake db:migrate"; \
      echo "rm ./db/migrate/*crawline*"; \
      echo "rake spec"; \
      echo "rake build"; \
    } | tee /usr/local/bin/build.sh && \
    chmod +x /usr/local/bin/build.sh

VOLUME /var/myapp
WORKDIR /var/myapp

CMD ["/usr/local/bin/build.sh"]
