import flask
from flask import Flask,request, Response, jsonify
import numpy as np
from flask import session
from flask_session import Session
import tempfile
import pickle
import shutil
from flask import send_file 
from PIL import Image
import tensorflow as tf
import io
import Model
import cv2
from SudokuSolver import SudoSolver

app = Flask(__name__)
app.secret_key = "secret_key"



@app.route('/sudomagic', methods= ['POST','GET'])
def post():
    if flask.request.method == 'GET':
        #sent_data = request.files['images'].read()
        session['ans'] = 'mold'
        response = 'Received'
        print(session)
        try:
            return Response(response=response, status=200, mimetype='image/png')
        except FileNotFoundError:
            abort(404)




@app.route('/answer', methods= ['GET'])
def get():
        answer = session.get('ans')
        print(answer)
        session.clear()
        try:
            return 'hello'
        except FileNotFoundError:
            abort(404)



if __name__ == "__main__":
    app.run(host='0.0.0.0', debug=True)