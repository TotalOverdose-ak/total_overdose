# app.py
from flask import Flask, jsonify, request, send_from_directory
import requests
import os

# Point static folder to the parent directory (root)
app = Flask(__name__, static_folder='../', static_url_path='/')

# Get API key from environment variable or use demo key
API_KEY = 'f215342ef6fb31829da6b26256b5d768'

@app.route('/')
def index():
    return app.send_static_file('index.html')

@app.route('/weather', methods=['GET'])
def get_weather():
    city = request.args.get('city')
    if not city:
        return jsonify({"error": "City is required"}), 400

    # Current weather via OpenWeatherMap
    url = f'https://api.openweathermap.org/data/2.5/weather?q={city}&appid={API_KEY}&units=metric'

    try:
        response = requests.get(url)
        if response.status_code == 200:
            data = response.json()

            # Fetch hourly forecast (3-hour intervals)
            forecast_url = f'https://api.openweathermap.org/data/2.5/forecast?q={city}&appid={API_KEY}&units=metric'
            forecast_response = requests.get(forecast_url)
            hourly_data = []

            if forecast_response.status_code == 200:
                forecast_data = forecast_response.json()
                for item in forecast_data.get('list', [])[:8]:  # Next 24 hours (8 * 3h intervals)
                    hourly_data.append({
                        'dt': item['dt'],
                        'temp': item['main']['temp']
                    })

            weather_data = {
                'city': data['name'],
                'temperature': data['main']['temp'],
                'description': data['weather'][0]['description'].title(),
                'icon': data['weather'][0]['icon'],
                'humidity': data['main']['humidity'],
                'wind_speed': data['wind']['speed'],
                'temp_high': data['main']['temp_max'],
                'temp_low': data['main']['temp_min'],
                'hourly': hourly_data
            }
            return jsonify(weather_data)
        else:
            return jsonify({"error": "City not found. Please try again."}), 404
    except Exception as e:
        return jsonify({"error": f"Error connecting to weather service: {str(e)}"}), 500

if __name__ == '__main__':
    app.run(debug=True, port=5000)
