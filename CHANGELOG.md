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
