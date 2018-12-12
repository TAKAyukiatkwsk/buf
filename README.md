# Buff

テンプレートを使ってBufferに投稿するCLIツールです。

## Installation

- Clone this repo.
- run `bundle install`
- In future, we want to distribute as gem

## Requirements

- Get Buffer access token from https://buffer.com/developers/apps/create
    - In future, we want to enable to access with OAuth2.
- Then set access token to `BUFFER_ACCESS_TOKEN` environment variable.

## Usage

```sh
$ mkdir templates
$ touch templates/<template_name>.mustache # and edit mustache file
$ bundle exec bin/buff post <template_name> -d '2018-12-01T19:00:00+09:00' --args 'series_no=76' 'date=2018年12月15日(土)' 'title=年末LT大会＆ビアバッシュ！' 'description=この機会に一年を振り返りましょう。'
```

- `-d` is scheduling date on Buffer (String as ISO 8601)
- `--args` is variables to apply template file. This can be set multiples.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/TAKAyukiatkwsk/buff.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
