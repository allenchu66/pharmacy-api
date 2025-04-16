FROM ruby:3.2.2

# 裝一些必要套件
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

# 設定工作目錄
WORKDIR /app

# 複製 Gemfile
COPY Gemfile Gemfile.lock ./

# 安裝 gem
RUN gem install bundler && bundle install

# 複製專案所有檔案
COPY . .

# 設定 port
EXPOSE 3000

# 啟動指令
CMD ["rails", "server", "-b", "0.0.0.0"]
