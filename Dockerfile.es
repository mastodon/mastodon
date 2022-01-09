From docker.elastic.co/elasticsearch/elasticsearch-oss:6.8.10
RUN sh -c '/bin/echo -e "y" | ./bin/elasticsearch-plugin install https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v6.8.10/elasticsearch-analysis-ik-6.8.10.zip' \
    && sh -c '/bin/echo -e "y" | ./bin/elasticsearch-plugin install https://github.com/medcl/elasticsearch-analysis-stconvert/releases/download/v6.8.10/elasticsearch-analysis-stconvert-6.8.10.zip'
