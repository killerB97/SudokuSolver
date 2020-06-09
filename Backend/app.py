import flask
from flask import Flask,request, Response, jsonify, send_from_directory, abort
import numpy as np
from PIL import Image
import tensorflow as tf
import io
import Model
import cv2
from SudokuSolver import SudoSolver

app = Flask(__name__)



@app.route('/sudomagic', methods= ['POST'])
def post():
        sent_data = request.files['images'].read()
        nparr = np.frombuffer(sent_data,np.uint8)
        img = cv2.imdecode(nparr,cv2.IMREAD_COLOR)

        model,graph = Model.buildModel('sudoku.h5')
        with graph.as_default():
            curr_user = SudoSolver(model)
            #print(img.shape)
            answer = curr_user.Solve(img)
        cv2.imwrite('result.jpg',answer)
        response = 'Received'
        try:
            return Response(response=response, status=200, mimetype='image/png')
        except FileNotFoundError:
            abort(404)






if __name__ == "__main__":
    app.run(host='0.0.0.0', debug=True)