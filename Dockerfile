FROM bash:5.2
WORKDIR /app
COPY hello.sh .
RUN chmod +x hello.sh
CMD ["bash", "hello.sh"]
