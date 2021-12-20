FROM amazoncorretto:11

RUN mkdir /app

RUN ./gradlew installDist

COPY ./build/install/com.hamba.dispatcher /app

WORKDIR /app/bin

EXPOSE 8080:8080

CMD ./com.hamba.dispatcher