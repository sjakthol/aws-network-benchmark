
FROM alpine:latest
RUN apk add --no-cache iperf3

USER nobody

CMD ["iperf3", "--server"]