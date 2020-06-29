import flask
from flask import Flask,request, Response, jsonify, make_response
import numpy as np
from flask import send_file 
from PIL import Image
import tensorflow as tf
import io
import Model
import os
import random
import string
import cv2
import SudokuSolver

app = Flask(__name__)

tokens = {}

def create_token():
    uid = ''.join(random.choices(string.ascii_uppercase +
                             string.digits, k = 10)) 
    if uid not in tokens:
        tokens[uid] = 0
        return uid
    else:
        r = create_token()
        return r

def destroy_token(uid):
    del tokens[uid]
    os.remove('sessions/'+uid+'.png')


@app.route('/sudomagic', methods= ['POST','GET'])
def post():
    sent_data = request.files['images'].read()
    nparr = np.frombuffer(sent_data,np.uint8)
    img = cv2.imdecode(nparr,cv2.IMREAD_COLOR)
    model,graph = Model.buildModel('sudoku_new_trial.h5')
    with graph.as_default():
        curr_user = SudokuSolver.SudoSolver(model)
        answer = curr_user.Solve(img)
    uid = create_token()
    cv2.imwrite('sessions/'+uid+'.png',answer)
    res = make_response('Received')
    res.set_cookie('user_id', uid, max_age=None)
    response = 'Received'
    try:
       return res
       #Response(response=response, status=200,mimetype='image/png')
    except FileNotFoundError:
        abort(404)


@app.route('/answer', methods= ['GET'])
def get():
        uid = request.cookies.get('user_id')
        tokens[uid]+=1
        answer = cv2.imread('sessions/'+uid+'.png',1)
        file_object = io.BytesIO()
        img = cv2.cvtColor(answer, cv2.COLOR_BGR2RGB)
        img = Image.fromarray(img.astype('uint8'))
    # write PNG in file-object
        img.save(file_object, 'PNG')
        file_object.seek(0)
    # Destroys temp file and token
        if tokens[uid]==2:
            destroy_token(uid)
        try:
            return send_file(file_object,mimetype='image/PNG')
        except FileNotFoundError:
            abort(404)



if __name__ == "__main__":
    app.run(host='0.0.0.0', debug=True)