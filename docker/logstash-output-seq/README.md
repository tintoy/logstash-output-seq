# Docker container for logstash-output-seq

1. Update the Seq server URL and Seq API key in [sample-config/logstash.conf](sample-config/logstash.conf)
2. `docker run --rm -it -v "$PWD/sample-config":/config-dir logstash-output-seq -f /config-dir/logstash.conf`
3. Type a couple of lines.
4. Go check Seq.
