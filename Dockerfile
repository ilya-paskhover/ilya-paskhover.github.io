FROM ruby:3.2-slim
RUN apt-get update && apt-get install -y --no-install-recommends build-essential && rm -rf /var/lib/apt/lists/*
WORKDIR /srv/site
ENV LANG=C.UTF-8 JEKYLL_ENV=production PAGES_REPO_NWO=ilya-paskhover/ilya-paskhover.github.io
COPY Gemfile ./
RUN bundle install
COPY . .
RUN bundle exec jekyll build
EXPOSE 4000
CMD ["bundle","exec","jekyll","serve","--host","0.0.0.0","--port","4000","--skip-initial-build","--no-watch"]
