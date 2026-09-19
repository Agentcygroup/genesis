FROM python:3.12-slim
WORKDIR /app
COPY app /app/app
RUN useradd -r -u 1001 runner
USER runner
EXPOSE 8080
ENTRYPOINT ["python", "-m", "app"]
