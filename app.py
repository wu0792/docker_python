from flask import Flask, send_from_directory

app = Flask(__name__, static_folder="static", static_url_path="")


@app.route("/")
def serve_index():
    return send_from_directory(app.static_folder, "index.html")


@app.route("/static/<path:path>")
def serve_static(path):
    return send_from_directory(app.static_folder, path)


@app.route("/hello")
def hello():
    return "Hello, World!"


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=9000)
