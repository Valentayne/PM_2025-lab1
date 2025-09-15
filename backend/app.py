from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

@app.route("/api/nameinfo", methods=["GET"])
def nameinfo():
    name = request.args.get("name")
    if not name:
        return jsonify({"error": "Name is required"}), 400

    try:
        nat_res = requests.get(f"https://api.nationalize.io/?name={name}").json()
        gen_res = requests.get(f"https://api.genderize.io/?name={name}").json()

        response = {
            "name": "алекс" if name.lower() == "alex" else name,
            "country": nat_res.get("country", []),
            "gender": gen_res.get("gender"),
            "probability": gen_res.get("probability")
        }
        return jsonify(response)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)

