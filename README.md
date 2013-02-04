# Carrierwave AWS Storage

Use the officially supported AWS-SDK library for S3 storage rather than relying
on fog. There are several things going for it:

* Full featured, it supports more of the API than Fog
* Significantly smaller footprint
* Fewer dependencies
* Clear documentation

Here is a simple comparison table [02/04/2013]

| Library | Disk Space | Lines of Code | Boot Time | Runtime Deps | Develop Deps |
| ------- | ---------- | ------------- | --------- | ------------ | ------------ |
| fog     | 28.0M      | 133469        | 0.693     | 9            | 11           |
| aws-sdk | 4.4M       |  80017        | 0.098     | 3            | 8            |

## Installation

Add this line to your application's Gemfile:

    gem 'carrierwave-aws'

## Usage

Configure and use it just like you would Fog. The only notable difference is
the use of `aws_bucket` instead of `fog_directory`, and `aws_acl` instead of
`fog_public`.

```ruby
CarrierWave.configure do |config|
  config.storage    = :aws
  config.aws_bucket = ENV['S3_BUCKET_NAME']
  config.aws_acl    = :public_read
  config.aws_authenticated_url_expiration = 60 * 60 * 24 * 365

  config.aws_credentials = {
    access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
    secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
  }
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
