import numpy as np
from keras.models import Sequential
from keras.datasets import mnist
import operator
from operator import itemgetter
from sklearn.model_selection import  train_test_split
from keras.layers import Dense, Conv2D, Dropout, Flatten, MaxPooling2D
import tensorflow as tf
import pandas as pd
import numpy as np
import cv2
import math
import copy

input_shape = (28, 28, 1)

# Creating a Sequential Model and adding the layers
model = Sequential()
model.add(Conv2D(32, kernel_size=(3, 3),activation='relu',input_shape=input_shape))
model.add(Conv2D(64, (3, 3), activation='relu'))
model.add(MaxPooling2D(pool_size=(2, 2)))
model.add(Dropout(0.2))
model.add(Conv2D(32, (5, 5), activation='relu'))
model.add(Conv2D(64, (5, 5), activation='relu'))
model.add(MaxPooling2D(pool_size=(2, 2)))
model.add(Dropout(0.25))
model.add(Flatten())
model.add(Dense(256, activation='relu'))
model.add(Dropout(0.2))
model.add(Dense(128, activation='relu'))
model.add(Dropout(0.5))
model.add(Dense(11, activation='softmax'))

model.load_weights('sudoku.h5')

def dist(p1, p2):
	"""Returns the scalar distance between two points"""
	a = p2[0] - p1[0]
	b = p2[1] - p1[1]
	return np.sqrt((a ** 2) + (b ** 2))
 
def wrap_img(dil,pts):
  points1 = np.float32([pts])
  size = int(max(dist(pts[0],pts[1]),dist(pts[0],pts[2]), dist(pts[2],pts[3]), dist(pts[3],pts[0])))
  points2 = np.float32([[0,size],[size,size],[size,0],[0,0]])
  matrix = cv2.getPerspectiveTransform(points1,points2)
  output = cv2.warpPerspective(dil,matrix,(size,size))
  return size,output

def check_empty(output):
    thresh = np.sum(output)
    if thresh>45000:
      return 1
    else:
      return 0

def warp_box_ocr(dil,start,size,i,f,j):
  global sudoku
  points1 = np.float32([[start,f*size],[start+size,f*size],[start+size,i],[start,i]])
  points2 = np.float32([[0,size],[size,size],[size,0],[0,0]])
  matrix = cv2.getPerspectiveTransform(points1,points2)
  output = cv2.warpPerspective(dil,matrix,(size,size))
  output = cv2.resize(output, (28,28), interpolation = cv2.INTER_AREA)
  pred = model.predict(output.reshape(1, 28, 28, 1))
  r = check_empty(output)
  if pred.argmax()==10 or r==0:
    sudoku[j].append(0)
  else:
    sudoku[j].append(pred.argmax())
  #cv2_imshow(output)
  #print(pred.argmax())


  # Link with Android app
x = cv2.imread('sud4.jpeg',0)
color_img = cv2.imread('sud4.jpeg')

blur_img = cv2.GaussianBlur(x.copy(), (13, 13), 0)

# Binary adaptive threshold using 11 nearest neighbour pixels
t2 = cv2.adaptiveThreshold(blur_img, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY_INV, 11, 2)

kernel = np.ones((3,3))
dilate = cv2.dilate(t2,kernel)

ctrs, hier = cv2.findContours(dilate.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

contours = sorted(ctrs, key=cv2.contourArea, reverse=True)  # Sort by area, descending
polygon = contours[0]

bottom_right = polygon[max(enumerate([pt[0][0] + pt[0][1] for pt in polygon]), key=itemgetter(1))[0]][0]
top_left = polygon[min(enumerate([pt[0][0] + pt[0][1] for pt in polygon]), key=itemgetter(1))[0]][0]
bottom_left = polygon[min(enumerate([pt[0][0] - pt[0][1] for pt in polygon]), key=itemgetter(1))[0]][0]
top_right = polygon[max(enumerate([pt[0][0] - pt[0][1] for pt in polygon]), key=itemgetter(1))[0]][0]
pts = [bottom_left,bottom_right,top_right,top_left]

sudoku = [[] for _ in range(9)]

size,output = wrap_img(dilate.copy(),pts)

start = 0
f = 1
j = 0
size = int(size/9)
m = 0
for i in range(81):
  if i%9==0 and i!=0:
    j+=size
    start=0
    f+=1
    m+=1
  warp_box_ocr(output.copy(),start,size,j,f,m)
  start+=size




def get_boards(board):
  colboard = list(map(list, zip(*board)))
  boxboard = [[] for _ in range(len(board))]
  k = 0
  p = 0
  t = 0
  while k<9:
    for i in range(3):
      for j in range(3):
        boxboard[k].append(board[i+t][j+p])
    k+=1
    p+=3
    if k%3==0:
      p =0
      t+=3
  return colboard,boxboard

def sqr(row,col):
  return math.floor(row/3)*3 + math.floor(col/3)

def sqc(row,col):
  return (row%3)*3 + (col%3)

def find(board):
  for i in range(len(board)):
    for j in range(len(board[0])):
      if board[i][j]==0:
        return i,j
  return None

def sudokuSolver(board,boxboard,colboard):
  if not find(board):
    return True
  else:
    row,j = find(board)
  sqrow = sqr(row,j)
  sqcol = sqc(row,j)
  for k in range(1,10):
      if (k not in board[row]) and (k not in colboard[j]) and (k not in boxboard[sqrow]):
        board[row][j] = k
        colboard[j][row] = k
        boxboard[sqrow][sqcol] = k
        if sudokuSolver(board,boxboard,colboard):
          return True
        board[row][j] = 0
        colboard[j][row] = 0
        boxboard[sqrow][sqcol] = 0     


  return False


orig_img = copy.deepcopy(sudoku)
colboard,boxboard = get_boards(sudoku)
sudokuSolver(sudoku,boxboard,colboard)

print(sudoku)


def writeToBoard(output,sudoku,orig,size):
  start = 0
  m = 0
  f = 1
  j = 0
  size = int(size/9)
  m = 0
  font = cv2.FONT_HERSHEY_COMPLEX
  for i in range(81):
    if i%9==0 and i!=0:
      j+=size
      start=0
      f+=1
      m+=1
    if orig[m][i%9]!=0:
      start+=size
      continue
    else:
      coord = ((2*start+size)//2,(j+f*size)//2)
      cv2.putText(output,str(sudoku[m][i%9]),coord,font,2,(0,255,0),2,cv2.LINE_AA)
    start+=size
  return output

size1,output1 = wrap_img(color_img.copy(),pts)
final_img = writeToBoard(output1.copy(),sudoku,orig_sudoku,size1)