## Unreleased

## Version 1.6.0 2023-07-23

* Added: Support setting #aws_acl to nil for bucket-level ACL compatibility
* Added: Support S3 CNAME-style virtual host access for private URLs
* Added: Support dynamic asset host
* Added: Support CarrierWave 3.0
* Changed: Update implementation of `AWSFile#copy_to` to use `S3Object#copy_to` API [Parker Selbert]

## Version 1.5.0 2020-04-01

* Fix Setting `asset_host_public`, which was removed in a recent version of
  CarrierWave.
* Replace `URI.decode` with `CGI.unescape`, as the former is deprecated
* Relax `CarrierWave` version constraint to any major version matching 2.0

## Version 1.4.0 2019-09-03

* Added: Use `aws_options` for copying and moving files [Fabian Schwahn]
* Added: Add support for serving from a private bucket via a public CDN [Rod
  Xavier]
* Changed: Support using a lambda for `aws_attributes` as a collection of options
  [Marcus Ilgner]
* Changed: Enable `multipart_copy` for copying / moving files that are larger
  than 15mb [Fabian Schwahn]
* Changed: Bumpt the CarrierWave version constraint to allow 2.0
* Fixed: URL encode paths when constructing `public_url` for objects

## Version 1.3.0 2017-09-27

* Changed: Rely on the smaller and more specific `aws-sdk-s3` gem.

## Version 1.2.0 2017-07-24

* Changed: Add support for large uploads via `#upload_file` rather than `#put`.
    * Manages multipart uploads for objects larger than 15MB.
    * Correctly opens files in binary mode to avoid encoding issues.
    * Uses multiple threads for uploading parts of large objects in parallel.
  See # #116, thanks to [Ylan Segal](@ylansegal).
* Changed: Upgrade expected `aws-sdk` to `2.1`
* Fixed: Return `nil` rather than raising an error for `File#size` when the file
  can't be found.

## Version 1.1.0 2017-02-24

* Added: Enable using AWS for cache storage, making it easy to do direct file
  uploads. [Fabian Schwahn]
* Added: Block support for reading from AWS files. This prevents dumping the
  entire object into memory, which is a problem with large objects. [Thomas Scholz]
* Fixed: Duplicate the `public_url` before signing. All of the strings are
  frozen, and some cloud signing methods attempt to mutate the url.

## Version 1.0.2 2016-09-26

* Fixed: Use `Aws.eager_load` to bypass autoloading for the `S3` resource. This
  prevents a race condition in multi threaded environments where an undefined
  error is raised for `Aws::S3::Resource` on any request that loads an uploaded
  file.

## Version 1.0.1 2016-05-13

* Fixed: The `copy_to` method of `AWS::File` now uses the same `aws_acl`
  configuration used on original uploads so ACL on copied files matches original
  files. [Olivier Lacan]

## Version 1.0.0 2015-09-18

* Added: ACL options are verified when they are set, and coerced into usable
  values when possible.
* Added: Specify an `aws_signer` lambda for use signing authenticated content
  served through services like CloudFront.

## Version 1.0.0-rc.1 2015-07-02

* Continues where 0.6.0 left off. This wraps AWS-SDK v2 and all of the breaking
  changes that contains. Please see the specific breaking change notes contained
  in `0.6.0` below.

## Version 0.7.0 2015-07-02

* Revert to AWS-SDK v1. There are too many breaking changes between v1 and v2 to
  be wrapped in a minor version change. This effectively reverts all changes
  betwen `0.5.0` and `0.6.0`, restoring the old `0.5.0` behavior.

## Version 0.6.0 2015-06-26

* Breaking Change: Updated to use AWS-SDK v2 [Mark Oleson]
  * You must specify a region in your `aws_credentials` configuration
  * You must use hyphens in ACLs instead of underscores (`:public_read` becomes
    `:'public-read'` or `'public-read'`)
  * Authenticated URL's are now longer than 255 characters. If you are caching
    url values you'll need to ensure columns allow 255+ characters.
  * Authenticated URL expiration has been limited to 7 days.

## Version 0.5.0 2015-01-31

* Change: Nudge the expected AWS-SDK version.
* Fix `exists?` method of AWS::File (previously it always returned true)
  [Felix Bünemann]
* Fix `filename` method of AWS::File for private files and remove url encoding.
  [Felix Bünemann]

## Version 0.4.1 2014-03-28

* Fix regression in `aws_read_options` defaulting to `nil` rather than an empty
  hash. [Johannes Würbach]

## Version 0.4.0 2014-03-20

* Allow custom options for authenticated urls [Filipe Giusti]
* Loosen aws-sdk constraints
* Add `aws_read_options` and `aws_write_options` [Erik Hanson and Greg Woodward]

## Version 0.3.2 2013-08-06

* And we're back to passing the path. An updated integration test confirms it
  is working properly.

## Version 0.3.1 2013-05-23

* Use the "alternate" object writing syntax. The primary method (as documented)
  only uploads the path itself rather than the file.

## Version 0.3.0 2013-05-23

* Pass the file path directly to aws-sdk to prevent upload timeouts stemming
  incorrect `content_length`.

## Version 0.2.1 2013-04-20

* Provide a `to_file` method on AWS::File in an attempt to prevent errors when
  re-uploading a cached file.

## Version 0.2.0 2013-04-19

* Update aws-sdk depdendency to 1.8.5
* Clean up some internal storage object passing

## Version 0.1.1 2013-04-09

* Fix storage bug when if `aws_attributes` is blank [#1]

## Version 0.1.0 2013-02-04

* Initial release, experimental with light expectation based spec coverage.
