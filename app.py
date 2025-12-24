from flask import Flask

app = Flask(__name__)


@app.get("/")  # "/" = トップページ
def index():
    return "Suevey app is running!"  # 起動確認の文字


if __name__ == "__main__":
    app.run(debug=True)
