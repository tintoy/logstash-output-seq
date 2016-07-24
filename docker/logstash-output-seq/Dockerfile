FROM logstash:2.3.4

MAINTAINER tintoy@tintoy.io

# Install the Seq output plugin.
RUN logstash-plugin install logstash-output-seq

EXPOSE 5000/udp

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["-e", ""]
