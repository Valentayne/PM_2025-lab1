from flask import Flask, request, jsonify
import requests
import psycopg2
import os

app = Flask(__name__)

def get_connection():
    return psycopg2.connect(
        dbname=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASS"),
        host=os.getenv("DB_HOST"),
        port=os.getenv("DB_PORT")
    )

def init_db():
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS nameinfo (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100),
        gender VARCHAR(50),
        probability FLOAT,
        countries TEXT,
        flags TEXT
    );
    """)
    conn.commit()
    cursor.close()
    conn.close()

def save_into_db(data):
    conn = get_connection()
    cursor = conn.cursor()
    sql = """
    INSERT INTO nameinfo (name, gender, probability, countries, flags)
    VALUES (%s, %s, %s, %s, %s)
    """
    cursor.execute(sql, (
        data["name"],
        data["gender"],
        data["probability"],
        str(data["country"]),
        str(data["flags"])
    ))
    conn.commit()
    cursor.close()
    conn.close()

@app.route("/api/nameinfo", methods=["GET"])
def nameinfo():
    name = request.args.get("name")
    if not name:
        return jsonify({"error": "Name is required"}), 400

    try:
        nat_res = requests.get(f"https://api.nationalize.io/?name={name}").json()
        gen_res = requests.get(f"https://api.genderize.io/?name={name}").json()

        flag_array = []
        for country in nat_res.get("country", []):
            country_id = country.get("country_id")
            if country_id:
                flag_array.append(f"https://flagsapi.com/{country_id}/flat/64.png")

        response = {
            "name": name,
            "country": nat_res.get("country", []),
            "gender": gen_res.get("gender"),
            "probability": gen_res.get("probability"),
            "flags": flag_array
        }

        save_into_db(response)

        return jsonify(response)

    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/api/data", methods=["GET"])
def get_data():
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT id, name, gender, probability, countries, flags FROM nameinfo")
        rows = cursor.fetchall()
        cursor.close()
        conn.close()

        data = []
        for row in rows:
            data.append({
                "id": row[0],
                "name": row[1],
                "gender": row[2],
                "probability": row[3],
                "countries": row[4],
                "flags": row[5]
            })

        return jsonify(data)

    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
@app.route("/health", methods=["GET"])
def health():
    return "OK", 200
@app.route("/init-db", methods=["POST"])
def init_route():
    init_db()
    return "DB initialized!", 200


# if __name__ == "__main__":
#     init_db()
#     app.run(host=os.getenv("HOST", "0.0.0.0"), port=int(os.getenv("PORT", os.getenv("PORT"))), debug=True)
