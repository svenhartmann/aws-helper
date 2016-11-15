# AWS Helper Scripts
### Installation
```sh
$ bundle install --standalone
$ export AWS_ACCESS_KEY_ID=<ID>
$ export AWS_SECRET_ACCESS_KEY=<KEY>
$ export AWS_REGION=<region>
```

[AWS Regions and Endpoints](http://docs.aws.amazon.com/general/latest/gr/rande.html)

### CloudFront
#### Invalidation
```sh
$ bundle exec ruby CloudFront/Distribution/Invalidation.rb -d <Distribution-ID> -p '/path/to/file.css'
```


