FROM python:3.9-slim

<<<<<<< HEAD
RUN apt-get update && apt-get install -y wget gnupg2 unzip &&     wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - &&     echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main"       > /etc/apt/sources.list.d/google.list &&     apt-get update && apt-get install -y google-chrome-stable libnss3 libasound2       fonts-liberation libatk1.0-0 libcups2 libxcomposite1 libxrandr2 libxdamage1       libxfixes3 libxss1 libgbm1 libpango1.0-0 libgtk-3-0 libxext6 lsb-release       xdg-utils &&     rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
=======
RUN apt-get update &&     apt-get install -y wget unzip gnupg2 &&     wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - &&     echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main"          > /etc/apt/sources.list.d/google.list &&     apt-get update &&     apt-get install -y google-chrome-stable &&     CHROME_VERSION=$(google-chrome-stable --version | cut -d" " -f3 | cut -d"." -f1) &&     LATEST=$(wget -qO- https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROME_VERSION}) &&     wget -q "https://chromedriver.storage.googleapis.com/${LATEST}/chromedriver_linux64.zip" &&     unzip chromedriver_linux64.zip -d /usr/local/bin &&     chmod +x /usr/local/bin/chromedriver &&     rm chromedriver_linux64.zip &&     apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

>>>>>>> 2267be942a33715997f6d581878382a095fede3d
COPY . .

ENV PORT=10000
EXPOSE 10000

CMD ["gunicorn", "app:app", "--bind", "0.0.0.0:10000", "--workers", "1"]