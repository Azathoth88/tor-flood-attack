FROM python:3.8-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Update and install system utils
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    apt-utils \
    software-properties-common \
    iputils-ping \
    nmap \
    netcat-traditional \
    vim \
    wget \
    curl \
    git \
    tor \
    privoxy \
    supervisor \
    procps \
    psmisc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists*

# Verify Privoxy installation
RUN privoxy --version

# Install Python dependencies
RUN pip install --no-cache-dir \
    requests==2.25.1 \
    fastapi==0.63.0 \
    uvicorn==0.13.3 \
    injectable==3.4.4 \
    beautifulsoup4==4.9.3 \
    user-agent==0.1.10 \
    simplestr==0.5.0 \
    tekleo-common-utils==0.0.0.2 \
    omoide-cache==0.1.2 \
    stem==1.8.0 \
    aiohttp==3.8.1

# Copy app
RUN mkdir /tor-flood-attack-service
COPY . /tor-flood-attack-service
WORKDIR /tor-flood-attack-service

# Ensure run.sh is executable
RUN chmod a+x run.sh

# Create supervisord.conf
RUN echo '[supervisord]\n\
nodaemon=true\n\
user=root\n\
\n\
[program:app]\n\
command=/tor-flood-attack-service/run.sh\n\
autostart=true\n\
autorestart=true\n\
stdout_logfile=/var/log/supervisor/app.log\n\
stderr_logfile=/var/log/supervisor/app_err.log' > /etc/supervisor/conf.d/supervisord.conf

# Ensure necessary directories exist with correct permissions
RUN mkdir -p /var/run/tor /var/log/tor /var/lib/tor /var/log/privoxy /var/run/privoxy && \
    chown -R debian-tor:debian-tor /var/run/tor /var/log/tor /var/lib/tor && \
    chmod 700 /var/run/tor /var/log/tor /var/lib/tor && \
    chmod 750 /var/log/privoxy /var/run/privoxy

# Set the entry point to run.sh
CMD ["/tor-flood-attack-service/run.sh"]
