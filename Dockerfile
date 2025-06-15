FROM python:3.11.0b1-buster

# set work directory
WORKDIR /app

# Install dependencies for psycopg2 and other tools
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        dnsutils \
        libpq-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Install pip
RUN python -m pip install --no-cache-dir pip==22.0.4

# Install python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . /app/

# Expose application port
EXPOSE 8000

# Run migrations
RUN python /app/manage.py migrate

# Set working directory to app subfolder if needed
WORKDIR /app/pygoat/

# Run gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "6", "pygoat.wsgi"]
