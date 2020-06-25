import numpy as np
from keras.models import Sequential
from keras.datasets import mnist
import operator
import tensorflow as tf
from operator import itemgetter
import cv2
import math
import copy


class SudoSolver:

  def __init__(self):
      self.answer = None

  def __init__(self,model):
      self.model = model  

  def dist(self,p1, p2):

      a = p2[0] - p1[0]
      b = p2[1] - p1[1]
      return np.sqrt((a ** 2) + (b ** 2))

  def refine(self,sudoku, threshold):
      avg = sum(threshold)/len(threshold) 
      num_avg = [n for n,i in enumerate(threshold) if i<=avg]
      t = 0
      for i in num_avg:
          t = math.floor(i/9)
          sudoku[t][i%9] = 0

  def wrap_img(self,dil,pts):

      points1 = np.float32([pts])
      size = int(max(self.dist(pts[0],pts[1]),self.dist(pts[0],pts[2]), self.dist(pts[2],pts[3]), self.dist(pts[3],pts[0])))
      points2 = np.float32([[0,size],[size,size],[size,0],[0,0]])
      matrix = cv2.getPerspectiveTransform(points1,points2)
      output = cv2.warpPerspective(dil,matrix,(size,size))
      return size,output

  def check_empty(self,output,threshold):
    thresh = np.sum(output)
    threshold.append(thresh)

  def cut_from_rect(self,img, rect):
    """Cuts a rectangle from an image using the top left and bottom right points."""
    return img[int(rect[0][1]):int(rect[1][1]), int(rect[0][0]):int(rect[1][0])]

  def scale_and_centre(self,img, size, margin=0, background=0):
    """Scales and centres an image onto a new background square."""
    h, w = img.shape[:2]

    def centre_pad(length):
        """Handles centering for a given length that may be odd or even."""
        if length % 2 == 0:
            side1 = int((size - length) / 2)
            side2 = side1
        else:
            side1 = int((size - length) / 2)
            side2 = side1 + 1
        return side1, side2

    def scale(r, x):
        return int(r * x)

    if h > w:
        t_pad = int(margin / 2)
        b_pad = t_pad
        ratio = (size - margin) / h
        w, h = scale(ratio, w), scale(ratio, h)
        l_pad, r_pad = centre_pad(w)
    else:
        l_pad = int(margin / 2)
        r_pad = l_pad
        ratio = (size - margin) / w
        w, h = scale(ratio, w), scale(ratio, h)
        t_pad, b_pad = centre_pad(h)

    img = cv2.resize(img, (w, h))
    img = cv2.copyMakeBorder(img, t_pad, b_pad, l_pad, r_pad, cv2.BORDER_CONSTANT, None, background)
    return cv2.resize(img, (size, size))

  def find_largest_feature(self,inp_img, scan_tl=None, scan_br=None):
    """
    Uses the fact the `floodFill` function returns a bounding box of the area it filled to find the biggest
    connected pixel structure in the image. Fills this structure in white, reducing the rest to black.
    """
    img = inp_img.copy()  # Copy the image, leaving the original untouched
    height, width = img.shape[:2]

    max_area = 0
    seed_point = (None, None)

    if scan_tl is None:
        scan_tl = [0, 0]

    if scan_br is None:
        scan_br = [width, height]

    # Loop through the image
    for x in range(scan_tl[0], scan_br[0]):
        for y in range(scan_tl[1], scan_br[1]):
            # Only operate on light or white squares
            if img.item(y, x) == 255 and x < width and y < height:  # Note that .item() appears to take input as y, x
                area = cv2.floodFill(img, None, (x, y), 64)
                if area[0] > max_area:  # Gets the maximum bound area which should be the grid
                    max_area = area[0]
                    seed_point = (x, y)

    # Colour everything grey (compensates for features outside of our middle scanning range
    for x in range(width):
        for y in range(height):
            if img.item(y, x) == 255 and x < width and y < height:
                cv2.floodFill(img, None, (x, y), 64)

    mask = np.zeros((height + 2, width + 2), np.uint8)  # Mask that is 2 pixels bigger than the image

    # Highlight the main feature
    if all([p is not None for p in seed_point]):
        cv2.floodFill(img, mask, seed_point, 255)

    top, bottom, left, right = height, 0, width, 0

    for x in range(width):
        for y in range(height):
            if img.item(y, x) == 64:  # Hide anything that isn't the main feature
                cv2.floodFill(img, mask, (x, y), 0)

            # Find the bounding parameters
            if img.item(y, x) == 255:
                top = y if y < top else top
                bottom = y if y > bottom else bottom
                left = x if x < left else left
                right = x if x > right else right

    bbox = [[left, top], [right, bottom]]
    return img, np.array(bbox, dtype='float32'), seed_point

  def warp_box_ocr(self,dil,start,size,i,f,j,sudoku,threshold):
      points1 = np.float32([[start,f*size],[start+size,f*size],[start+size,i],[start,i]])
      points2 = np.float32([[0,size],[size,size],[size,0],[0,0]])
      matrix = cv2.getPerspectiveTransform(points1,points2)
      output = cv2.warpPerspective(dil,matrix,(size,size))
      
      h, w = output.shape[:2]
      size = output.shape[:2][0]
      margin = int(np.mean([h, w]) / 2.5)
      _,bbox,seed = self.find_largest_feature(output,[margin, margin], [w - margin, h - margin])
      output = self.cut_from_rect(output, bbox)
        # Scale and pad the digit so that it fits a square of the digit size we're using for machine learning
      
      w = bbox[1][0] - bbox[0][0]
      h = bbox[1][1] - bbox[0][1]

        # Ignore any small bounding boxes
      if w > 0 and h > 0 and (w * h) > (size*size)//10 and len(output) > 0:
        output =  self.scale_and_centre(output, size, size//2)
        output = cv2.resize(output, (28,28), interpolation = cv2.INTER_AREA)
        
      else:
        output =  np.zeros((28,28), np.uint8)
      pred = self.model.predict(output.reshape(1, 28, 28, 1))
      self.check_empty(output,threshold)
      if pred.argmax()==10:
        sudoku[j].append(0)
      else:
        sudoku[j].append(pred.argmax())

      
  def get_boards(self,board):

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

  def sqr(self,row,col):
      return math.floor(row/3)*3 + math.floor(col/3)

  def sqc(self,row,col):
      return (row%3)*3 + (col%3)

  def find(self,board):
      for i in range(len(board)):
          for j in range(len(board[0])):
              if board[i][j]==0:
                  return i,j
      return None

  def sudokuSolver(self,board,boxboard,colboard):

      if not self.find(board):
          return True
      else:
          row,j = self.find(board)
      sqrow = self.sqr(row,j)
      sqcol = self.sqc(row,j)
      for k in range(1,10):
          if (k not in board[row]) and (k not in colboard[j]) and (k not in boxboard[sqrow]):
              board[row][j] = k
              colboard[j][row] = k
              boxboard[sqrow][sqcol] = k
              if self.sudokuSolver(board,boxboard,colboard):
                  return True
              board[row][j] = 0
              colboard[j][row] = 0
              boxboard[sqrow][sqcol] = 0


      return False


  def writeToBoard(self,output,sudoku,orig,size):

      start = 0
      m = 0
      f = 1
      j = 0
      size = int(size/9)
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
              coord = (int((2*start+size)//2.05),int((j+f*size)//1.95))
              cv2.putText(output,str(sudoku[m][i%9]),coord,font,1,(255,0,0),2,cv2.LINE_AA)
          start+=size
      return output


  def Solve(self,img):
      x = cv2.cvtColor(img.copy(), cv2.COLOR_BGR2GRAY)
      color_img = img

      #x = cv2.imread(img,0)
      #color_img = cv2.imread(img)

      blur_img = cv2.GaussianBlur(x.copy(), (13, 13), 0)

      # Binary adaptive threshold using 11 nearest neighbour pixels
      t2 = cv2.adaptiveThreshold(blur_img, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY_INV, 9, 2)

      kernel = np.ones((3, 3))
      dilate = cv2.dilate(t2, kernel)

      ctrs, hier = cv2.findContours(dilate.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

      contours = sorted(ctrs, key=cv2.contourArea, reverse=True)  # Sort by area, descending
      polygon = contours[0]

      bottom_right = polygon[max(enumerate([pt[0][0] + pt[0][1] for pt in polygon]), key=itemgetter(1))[0]][0]
      top_left = polygon[min(enumerate([pt[0][0] + pt[0][1] for pt in polygon]), key=itemgetter(1))[0]][0]
      bottom_left = polygon[min(enumerate([pt[0][0] - pt[0][1] for pt in polygon]), key=itemgetter(1))[0]][0]
      top_right = polygon[max(enumerate([pt[0][0] - pt[0][1] for pt in polygon]), key=itemgetter(1))[0]][0]
      pts = [bottom_left, bottom_right, top_right, top_left]

      sudoku1 = [[] for _ in range(9)]
      sudoku2 = [[] for _ in range(9)]
      sudoku3 = [[] for _ in range(9)]
      threshold1 = []
      threshold2 = []
      threshold3 = []

      size, output = self.wrap_img(x.copy(), pts)
      thresh_lvl = output.shape[0]//50
      blur_lvl = output.shape[0]//40
      print(thresh_lvl)
      thresh_lvl += 1 if thresh_lvl%2==0 else 0
      blur_lvl += 1 if blur_lvl%2==0 else 0
      output = cv2.GaussianBlur(output.copy(), (blur_lvl, blur_lvl), 0)
      output1 = cv2.adaptiveThreshold(output, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY_INV, thresh_lvl, 2)
      output2 = cv2.adaptiveThreshold(output, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY_INV, thresh_lvl-6, 2)
      output3 = cv2.adaptiveThreshold(output, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY_INV, thresh_lvl+6, 2)

      start = 0
      f = 1
      j = 0
      size = int(size / 9)
      m = 0
      for i in range(81):
          if i % 9 == 0 and i != 0:
              j += size
              start = 0
              f += 1
              m += 1
          self.warp_box_ocr(output1.copy(), start, size, j, f, m, sudoku1,threshold1)
          self.warp_box_ocr(output2.copy(), start, size, j, f, m, sudoku2,threshold2)
          self.warp_box_ocr(output3.copy(), start, size, j, f, m, sudoku3,threshold3)
          start += size
      

      self.refine(sudoku1, threshold1)
      self.refine(sudoku2, threshold2)
      self.refine(sudoku3, threshold3)

      
      test = [sudoku1,sudoku2,sudoku3]
      
      for sudoku in test:
        orig_sudoku = copy.deepcopy(sudoku)
        colboard, boxboard = self.get_boards(sudoku)
        self.sudokuSolver(sudoku, boxboard, colboard)
        if sudoku==orig_sudoku:
            continue
        else:
            break

      size1, final_out = self.wrap_img(color_img.copy(), pts)
      final_img = self.writeToBoard(final_out.copy(), sudoku, orig_sudoku, size1)
      self.answer = final_img
      return final_img


    # Link with Android app

