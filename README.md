# Carrierwave AWS Storage

[![Build Status](https://travis-ci.org/sorentwo/carrierwave-aws.svg?branch=master)](https://travis-ci.org/sorentwo/carrierwave-aws)
[![Code Climate](https://codeclimate.com/github/sorentwo/carrierwave-aws.svg)](https://codeclimate.com/github/sorentwo/carrierwave-aws)
[![Gem Version](https://badge.fury.io/rb/carrierwave-aws.svg)](http://badge.fury.io/rb/carrierwave-aws)
[![Dependency Status](https://gemnasium.com/sorentwo/carrierwave-aws.svg)](https://gemnasium.com/sorentwo/carrierwave-aws)

Use the officially supported AWS-SDK library for S3 storage rather than relying
on fog. There are several things going for it:

* Full featured, it supports more of the API than Fog
* Significantly smaller footprint
* Fewer dependencies
* Clear documentation

Here is a simple comparison table [07/17/2013]

| Library | Disk Space | Lines of Code | Boot Time | Runtime Deps | Develop Deps |
| ------- | ---------- | ------------- | --------- | ------------ | ------------ |
| fog     | 28.0M      | 133469        | 0.693     | 9            | 11           |
| aws-sdk | 5.4M       |  90290        | 0.098     | 3            | 8            |

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'carrierwave-aws'
```

Run the bundle command from your shell to install it:
```bash
bundle install
```

## Usage

Configure and use it just like you would Fog. The only notable difference is
the use of `aws_bucket` instead of `fog_directory`, and `aws_acl` instead of
`fog_public`.

```ruby
CarrierWave.configure do |config|
  config.storage    = :aws
  config.aws_bucket = ENV.fetch('S3_BUCKET_NAME')
  config.aws_acl    = 'public-read'

  # Optionally define an asset host for configurations that are fronted by a
  # content host, such as CloudFront.
  config.asset_host = 'http://example.com'
  config.asset_public_host = true

  # The maximum period for authenticated_urls is only 7 days.
  config.aws_authenticated_url_expiration = 60 * 60 * 24 * 7

  # Set custom options such as cache control to leverage browser caching
  config.aws_attributes = {
    expires: 1.week.from_now.httpdate,
    cache_control: 'max-age=604800'
  }

  config.aws_credentials = {
    access_key_id:     ENV.fetch('AWS_ACCESS_KEY_ID'),
    secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY'),
    region:            ENV.fetch('AWS_REGION'), # Required
    stub_responses:    Rails.env.test? # Optional, avoid hitting S3 actual during tests
  }

  # Optional: Signing of download urls, e.g. for serving private content through
  # CloudFront. Be sure you have the `cloudfront-signer` gem installed and
  # configured:
  # config.aws_signer = -> (unsigned_url, options) do
  #   Aws::CF::Signer.sign_url(unsigned_url, options)
  # end
end
```

### Custom options for AWS URLs

If you have a custom uploader that specifies additional headers for each URL,
please try the following example:

```ruby
class MyUploader < Carrierwave::Uploader::Base
  # Storage configuration within the uploader supercedes the global CarrierWave
  # config, so either comment out `storage :file`, or remove that line, otherwise
  # AWS will not be used.
  storage :aws

  # You can find a full list of custom headers in AWS SDK documentation on
  # AWS::S3::S3Object
  def download_url(filename)
    url(response_content_disposition: %Q{attachment; filename="#{filename}"})
  end
end
```


## Migrating From Fog

If you migrate from `fog` your uploader may be configured as `storage :fog`,
simply comment out that line, as in the following example, or remove that
specific line.

```ruby
class MyUploader < Carrierwave::Uploader::Base
  # Storage configuration within the uploader supercedes the global CarrierWave
  # config, so adjust accordingly...

  # Choose what kind of storage to use for this uploader:
  # storage :file
  # storage :fog
  storage :aws


  # More comments below in your file....
end
```

Another item particular to fog, you may have `url(query: {'my-header': 'my-value'})`.
With `carrierwave-aws` the `query` part becomes obsolete, just use a hash of
headers. Please read [usage][#Usage] for a more detailed explanation about
configuration.

## Contributing

In order to run the integration specs you will need to configure some
environment variables. A sample file is provided as `.env.sample`. Copy it over
and plug in the appropriate values.

```bash
cp .env.sample .env
```

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
