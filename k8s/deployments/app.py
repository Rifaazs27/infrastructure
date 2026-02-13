from flask import Flask, jsonify
import psycopg2

app = Flask(__name__)

# Connexion à PostgreSQL
def get_db_connection():
    conn = psycopg2.connect(
        host="postgres",        # Nom du service Kubernetes pour PostgreSQL
        database="cloudshop",   # Nom de la base
        user="admin",           # Utilisateur
        password="password"     # Mot de passe
    )
    return conn

# Route principale
@app.route('/')
def home():
    return "<h1>Bienvenue sur CloudShop Backend !</h1>"

# Route API exposée pour l’Ingress
@app.route('/api')
def api():
    data = {
        "message": "Bienvenue sur l’API CloudShop !",
        "status": "ok"
    }
    return jsonify(data)

if __name__ == '__main__':
    # Important : écoute sur 0.0.0.0 pour que Kubernetes puisse y accéder
    app.run(host='0.0.0.0', port=5000)
