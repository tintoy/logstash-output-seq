# Seq output plugin for Logstash

[![Travis Build Status](https://travis-ci.org/tintoy/logstash-output-seq.svg)](https://travis-ci.org/tintoy/logstash-output-seq)
[![Gem Version](https://badge.fury.io/rb/logstash-output-seq.svg)](https://badge.fury.io/rb/logstash-output-seq)
[![Coverage Status (master)](https://coveralls.io/repos/github/tintoy/logstash-output-seq/badge.svg?branch=master)](https://coveralls.io/github/tintoy/logstash-output-seq?branch=master)

This is an output plugin for [Logstash](https://github.com/elastic/logstash) that publishes events to [Seq](https://getseq.net/).

It is fully free and fully open source. The license is MIT, meaning you are pretty much free to use it however you want in whatever way.

## Usage

To install the Seq output plugin for Logstash:

```sh
# Logstash 2.3 and higher
${LOGSTASH_HOME}/bin/logstash-plugin install logstash-output-seq
```

The plugin has the following configuration options:

* `url` (Required) - The Seq server URL (e.g. `http://localhost:5341/`)
* `api_key` (Optional) - The Seq API key (if any) to use for authentication.
* Any parameters from the Logstash HttpClient mix-in (e.g. configuring SSL behaviour, etc).

### Docker

There is also a [docker image](https://hub.docker.com/r/tintoy/logstash-output-seq/) available that has this plugin preinstalled.

## Developing

[Developing](DEVELOPING.md)

## Contributing

All contributions are welcome: ideas, patches, documentation, bug reports, complaints, and even something you drew up on a napkin.

For more information about contributing, see the [CONTRIBUTING](https://github.com/tintoy/logstash-output-seq/blob/master/.github/CONTRIBUTING.md) file.