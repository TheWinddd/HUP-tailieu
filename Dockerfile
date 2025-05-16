# Dockerfile cho Flask + Selenium trên Render

FROM python:3.9-slim

# Cài Chrome và các thư viện cần thiết
RUN apt-get update && apt-get install -y \
      wget gnupg2 unzip \
      fonts-liberation libatk1.0-0 libcups2 libxcomposite1 libxdamage1 \
      libxfixes3 libxrandr2 libxss1 libgbm1 libpango1.0-0 libgtk-3-0 \
      libnss3 libasound2 lsb-release xdg-utils \
    && wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" \
         > /etc/apt/sources.list.d/google.list \
    && apt-get update && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# Thư mục làm việc
WORKDIR /app

# Copy và cài Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy toàn bộ code
COPY . .

# Expose port mà Render sẽ dùng
ENV PORT=10000
EXPOSE 10000

# Chạy Gunicorn
CMD ["gunicorn", "app:app", "--bind", "0.0.0.0:10000", "--workers", "1"]
