import flask
from flask import Flask,request, Response, jsonify, send_from_directory, abort
import numpy as np
from flask import send_file 
from PIL import Image
import tensorflow as tf
import io
import Model
import cv2
from SudokuSolver import SudoSolver

app = Flask(__name__)

answer = None

@app.route('/sudomagic', methods= ['POST'])
def post():
        global answer
        sent_data = request.files['images'].read()
        nparr = np.frombuffer(sent_data,np.uint8)
        img = cv2.imdecode(nparr,cv2.IMREAD_COLOR)
        model,graph = Model.buildModel('sudoku_new_trial.h5')
        with graph.as_default():
            curr_user = SudoSolver(model)
            answer = curr_user.Solve(img)
            print(answer.shape)
        response = 'Received'
        try:
            return Response(response=response, status=200, mimetype='image/png')
        except FileNotFoundError:
            abort(404)

@app.route('/answer', methods= ['GET'])
def get():
        global answer
        file_object = io.BytesIO()
        img = cv2.cvtColor(answer, cv2.COLOR_BGR2RGB)
        img = Image.fromarray(img.astype('uint8'))
    # write PNG in file-object
        img.save(file_object, 'PNG')

    # move to beginning of file so `send_file()` it will read from start    
        file_object.seek(0)

        try:
            return send_file(file_object,mimetype='image/PNG')
        except FileNotFoundError:
            abort(404)






if __name__ == "__main__":
    app.run(host='0.0.0.0', debug=True)