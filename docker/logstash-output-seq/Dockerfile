FROM logstash:2.3.4

MAINTAINER tintoy@tintoy.io

# Install the Seq output plugin.
RUN logstash-plugin install logstash-output-seq

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["-e", ""]
