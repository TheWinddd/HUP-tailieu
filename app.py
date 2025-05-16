from flask import Flask, render_template, request, send_file, flash
<<<<<<< HEAD
import os, time
=======
import os, time, io
>>>>>>> 2267be942a33715997f6d581878382a095fede3d
import requests, img2pdf
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager

app = Flask(__name__)
app.secret_key = "your_secret_key"

def init_driver():
    chrome_options = Options()
    chrome_options.add_argument('--headless')
    chrome_options.add_argument('--no-sandbox')
    chrome_options.add_argument('--disable-dev-shm-usage')
    chrome_options.add_argument('--window-size=1200,1600')
    service = Service(ChromeDriverManager().install())
    driver = webdriver.Chrome(service=service, options=chrome_options)
    return driver

def fetch_pages_as_images(driver, url):
    driver.get(url)
    WebDriverWait(driver, 20).until(
        EC.presence_of_element_located((By.ID, "PDFViewerLB_CurrentPageImage"))
    )
    try:
        li_items = driver.find_elements(By.CSS_SELECTOR, "#PDFViewerLB_BookmarkPanel li")
        total_pages = len(li_items) or 1
    except:
        total_pages = 1

    images = []
    for i in range(total_pages):
        img_el = WebDriverWait(driver, 10).until(
            EC.visibility_of_element_located((By.ID, "PDFViewerLB_CurrentPageImage"))
        )
        images.append(img_el.screenshot_as_png)
        if i < total_pages - 1:
            try:
                driver.find_element(By.CSS_SELECTOR, "input[title='Trang sau']").click()
                time.sleep(1)
            except:
                break
    return images

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        doc_url = request.form.get('doc_url')
        filename = request.form.get('filename') or 'output'
        if not doc_url:
            flash("Vui lòng nhập URL tài liệu.")
            return render_template('index.html')

        driver = init_driver()
        try:
            images = fetch_pages_as_images(driver, doc_url)
        except Exception as e:
            flash(f"Lỗi khi xử lý tài liệu: {e}")
            driver.quit()
            return render_template('index.html')
        driver.quit()

        pdf_bytes = img2pdf.convert(images)
        pdf_path = f"{filename}.pdf"
        with open(pdf_path, 'wb') as f:
            f.write(pdf_bytes)

        return send_file(pdf_path, as_attachment=True)

    return render_template('index.html')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)