FROM gliderlabs/alpine:latest
RUN apk-install bash curl
ADD ./pullfromvault.sh /pullfromvault.sh
ENTRYPOINT ["/pullfromvault.sh"]
