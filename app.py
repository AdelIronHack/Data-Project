import pymysql
import os
from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/states/<state>")
def accidentlocation(state):
    db_conn = pymysql.connect(
        host="localhost",
        user="root",
        password=os.getenv('mysql_adel'),
        database="usaccidents",
        cursorclass=pymysql.cursors.DictCursor
    )

    with db_conn.cursor() as cursor:
        cursor.execute("SELECT count(*) as total_accidents FROM accident a join city c on a.city_id=c.city_id WHERE state=%s", (state,))
        state_info = cursor.fetchone()
    
    state_info['state'] = state

    with db_conn.cursor() as cursor:
        cursor.execute("""SELECT c.city, count(*) as accidents 
                          FROM accident a 
                          join city c on a.city_id=c.city_id 
                          WHERE state=%s
                          group by c.city
                          order by count(*) desc
                          limit 20""", (state,))
        city_info = cursor.fetchall()
    
    db_conn.close()
    state_info['cities'] = city_info
    return jsonify(state_info)

@app.route("/cities/<city>")
def city_accidents(city):
    db_conn = pymysql.connect(
        host="localhost",
        user="root",
        password=os.getenv('mysql_adel'),
        database="usaccidents",
        cursorclass=pymysql.cursors.DictCursor
    )

    with db_conn.cursor() as cursor:
        cursor.execute("""SELECT count(*) as total_accidents 
                          FROM accident a 
                          join city c on a.city_id=c.city_id 
                          WHERE c.city=%s""", (city,))
        city_info = cursor.fetchone()
    
    city_info['city'] = city

    with db_conn.cursor() as cursor:
        cursor.execute("""SELECT state, count(*) as accidents 
                          FROM accident a 
                          join city c on a.city_id=c.city_id 
                          WHERE c.city=%s
                          group by state
                          order by count(*) desc""", (city,))
        state_info = cursor.fetchall()
    
    db_conn.close()
    city_info['states'] = state_info
    return jsonify(city_info)

@app.route("/top-states")
def top_states():
    db_conn = pymysql.connect(
        host="localhost",
        user="root",
        password=os.getenv('mysql_adel'),
        database="usaccidents",
        cursorclass=pymysql.cursors.DictCursor
    )

    with db_conn.cursor() as cursor:
        cursor.execute("""SELECT state, count(*) as total_accidents 
                          FROM accident a 
                          join city c on a.city_id=c.city_id 
                          group by state
                          order by count(*) desc
                          limit 10""")
        top_states_info = cursor.fetchall()
    
    db_conn.close()
    return jsonify(top_states_info)

@app.route("/weather-conditions/<condition>")
def weather_conditions(condition):
    db_conn = pymysql.connect(
        host="localhost",
        user="root",
        password=os.getenv('mysql_adel'),
        database="usaccidents",
        cursorclass=pymysql.cursors.DictCursor
    )

    with db_conn.cursor() as cursor:
        cursor.execute("""SELECT count(*) as total_accidents 
                          FROM accidents 
                          WHERE Weather_Condition=%s""", (condition,))
        condition_info = cursor.fetchone()
    
    condition_info['Weather_Condition'] = condition

    with db_conn.cursor() as cursor:
        cursor.execute("""SELECT state, count(*) as accidents 
                          FROM accidents a 
                          join city c on a.city_id=c.city_id 
                          WHERE a.Weather_Condition=%s
                          group by state
                          order by count(*) desc""", (condition,))
        state_info = cursor.fetchall()
    
    db_conn.close()
    condition_info['states'] = state_info
    return jsonify(condition_info)

if __name__ == "__main__":
    app.run(debug=True)
